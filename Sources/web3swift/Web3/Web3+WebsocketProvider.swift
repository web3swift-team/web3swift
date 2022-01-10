//
//  Web3+WebsocketProvider.swift
//  web3swift-iOS
//
//  Created by Anton on 01/04/2019.
//  Copyright © 2019 The Matter Inc. All rights reserved.
//
import Starscream
import PromiseKit
import BigInt
import Foundation

public protocol Web3SocketDelegate {
    func socketConnected(_ headers: [String:String])
    func gotError(error: Error)
}

public struct DefaultWeb3SocketDelegate: Web3SocketDelegate {
    public func socketConnected(_ headers: [String : String]) {
        print("DefaultWeb3SocketDelegate.socketConnected: \(headers)")
    }
    
    public func gotError(error: Error) {
        print("DefaultWeb3SocketDelegate.gotError: \(error)")
    }
}

public struct WebsocketSubscription: Subscription {
    public var id: String? = nil
    private let unsubscribeCallback: (Self) -> Void
    
    public init(unsubscribeCallback: @escaping (Self) -> Void) {
        self.unsubscribeCallback = unsubscribeCallback
    }
    
    public func unsubscribe() {
        unsubscribeCallback(self)
    }
}

public struct JSONRPCSubscriptionEvent<R: Decodable>: Decodable {
    public struct Params: Decodable {
        public let result: R
        public let subscription: String
    }
    
    public let jsonrpc: String
    public let method: String
    public let params: Params
}

/// The default websocket provider.
public class WebsocketProvider: Web3SubscriptionProvider, WebSocketDelegate {

    public func sendAsync(_ request: JSONRPCrequest, queue: DispatchQueue) -> Promise<JSONRPCresponse> {
        guard let method = request.method else {
            return Promise(error: Web3Error.inputError(desc: "No method in request: \(request)"))
        }
        guard [.subscribe, .unsubscribe].contains(method) else {
            return Promise(error: Web3Error.inputError(desc: "Unsupported method: \(method)"))
        }
        return Promise { resolver in
            queue.async {
                let requestData: Data
                do {
                    requestData = try JSONEncoder().encode(request)
                } catch {
                    resolver.reject(error)
                    return
                }
                print(String(decoding: requestData, as: UTF8.self))
                self.writeMessage(requestData)
                self.internalQueue.sync {
                    self.requests[request.id] = { result in
                        switch result {
                        case .success(let response): resolver.fulfill(response)
                        case .failure(let error): resolver.reject(error)
                        }
                    }
                }
            }
        }
    }
    
    public func sendAsync(_ requests: JSONRPCrequestBatch, queue: DispatchQueue) -> Promise<JSONRPCresponseBatch> {
        when(fulfilled: requests.requests.map { sendAsync($0, queue: queue) }).map { responses in
            JSONRPCresponseBatch(responses: responses)
        }
    }
    
    public var network: Networks?
    public var url: URL
    public var session: URLSession = {() -> URLSession in
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config)
        return urlSession
    }()
    
    public var socket: WebSocket
    public var delegate: Web3SocketDelegate
    private var queue: DispatchQueue!
    /// A flag that is true if socket connected or false if socket doesn't connected.
    public var websocketConnected: Bool = false
    
    private var writeTimer: Timer? = nil
    private var messagesStringToWrite: [String] = []
    private var messagesDataToWrite: [Data] = []
    
    /// if set debugMode True then show websocket events logs in the console
    public var debugMode: Bool = false
    
    private var subscriptions = [String: (sub: WebsocketSubscription, cb: (Swift.Result<Data, Error>) -> Void)]()
    private var requests = [UInt64: (Swift.Result<JSONRPCresponse, Error>) -> Void]()
    private var internalQueue: DispatchQueue
    
    public init?(_ endpoint: URL,
                 delegate wsdelegate: Web3SocketDelegate? = nil,
                 projectId: String? = nil,
                 network net: Networks? = nil) {
        websocketConnected = false
        var endpointString = endpoint.absoluteString
        if !(endpointString.hasPrefix("wss://") || endpointString.hasPrefix("ws://")) {
            return nil
        }
        if endpointString.hasPrefix("wss://") && endpointString.hasSuffix(Constants.infuraWsScheme) {
            if net == nil {
                let networkString = endpointString.replacingOccurrences(of: "wss://", with: "")
                    .replacingOccurrences(of: Constants.infuraWsScheme, with: "")
                switch networkString {
                case "mainnet":
                    network = Networks.Mainnet
                case "rinkeby":
                    network = Networks.Rinkeby
                case "ropsten":
                    network = Networks.Ropsten
                case "kovan":
                    network = Networks.Kovan
                default:
                    break
                }
            } else {
                network = net
            }
            if network != nil {
                endpointString += projectId ?? Constants.infuraToken
            }
        }
        url = URL(string: endpointString)!
        delegate = wsdelegate ?? DefaultWeb3SocketDelegate()
        let request = URLRequest(url: url)
        internalQueue = DispatchQueue(
            label: "web3swift.websocketProvider.internalQueue",
            target: .global()
        )
        socket = WebSocket(request: request)
        socket.delegate = self
    }
    
    public init?(_ endpoint: String,
                 delegate wsdelegate: Web3SocketDelegate? = nil,
                 projectId: String? = nil,
                 network net: Networks? = nil) {
        guard URL(string: endpoint) != nil else {return nil}
        var finalEndpoint = endpoint
        websocketConnected = false
        if !(endpoint.hasPrefix("wss://") || endpoint.hasPrefix("ws://")) {
            return nil
        }
        if endpoint.hasPrefix("wss://") && endpoint.hasSuffix(Constants.infuraWsScheme) {
            if net == nil {
                let networkString = endpoint.replacingOccurrences(of: "wss://", with: "")
                    .replacingOccurrences(of: Constants.infuraWsScheme, with: "")
                switch networkString {
                case "mainnet":
                    network = Networks.Mainnet
                case "rinkeby":
                    network = Networks.Rinkeby
                case "ropsten":
                    network = Networks.Ropsten
                case "kovan":
                    network = Networks.Kovan
                default:
                    break
                }
            } else {
                network = net
            }
            if network != nil {
                finalEndpoint += projectId ?? Constants.infuraToken
            }
        }
        url = URL(string: finalEndpoint)!
        delegate = wsdelegate ?? DefaultWeb3SocketDelegate()
        let request = URLRequest(url: url)
        internalQueue = DispatchQueue(
            label: "web3swift.websocketProvider.internalQueue",
            target: .global()
        )
        socket = WebSocket(request: request)
        socket.delegate = self
    }
    
    deinit {
        writeTimer?.invalidate()
    }
    
    public func setQueue(queue: DispatchQueue) {
        self.queue = queue
    }
    
    public func subscribe<R>(filter: SubscribeEventFilter,
                             listener: @escaping Web3SubscriptionListener<R>) -> Subscription {
        internalQueue.sync {
            let params: [Encodable]
            switch filter {
            case .newHeads:
                params = ["newHeads"]
            case .logs(let logsParam):
                params = ["logs", logsParam]
            case .newPendingTransactions:
                params = ["newPendingTransactions"]
            case .syncing:
                params = ["syncing"]
            }
            var subscription = WebsocketSubscription(unsubscribeCallback: { subscription in
                guard let id = subscription.id else {
                    return
                }
                let request = JSONRPCRequestFabric.prepareRequest(JSONRPCmethod.unsubscribe, parameters: [id])
                self.sendAsync(request, queue: self.queue).pipe { result in
                    switch result {
                    case .fulfilled(let response):
                        guard let unsubscribed = response.result as? Bool else {
                            self.delegate.gotError(error: Web3Error.processingError(desc: "Wrong result in response: \(response)"))
                            return
                        }
                        if unsubscribed {
                            self.subscriptions.removeValue(forKey: id)
                        } else {
                            self.delegate.gotError(error: Web3Error.processingError(desc: "Can\'t unsubscribe \(id)"))
                        }
                    case .rejected(let error):
                        self.delegate.gotError(error: error)
                    }
                }
            })
            let request = JSONRPCRequestFabric.prepareRequest(JSONRPCmethod.subscribe, parameters: params)
            sendAsync(request, queue: queue).pipe { result in
                switch result {
                case .fulfilled(let response):
                    guard let subscriptionID = response.result as? String else {
                        self.delegate.gotError(error: Web3Error.processingError(desc: "Wrong result in response: \(response)"))
                        return
                    }
                    subscription.id = subscriptionID
                    self.subscriptions[subscriptionID] = (subscription, { result in
                        listener(result.flatMap { eventData in
                            Swift.Result {
                                try JSONDecoder().decode(JSONRPCSubscriptionEvent<R>.self, from: eventData)
                            }
                        }.map { $0.params.result })
                    })
                case .rejected(let error):
                    listener(.failure(error))
                }
            }
            return subscription
        }
    }
    
    public func connectSocket() {
        writeTimer?.invalidate()
        socket.connect()
    }
    
    public func disconnectSocket() {
        writeTimer?.invalidate()
        socket.disconnect()
    }
    
    public func isConnect() -> Bool {
        return websocketConnected
    }
    
    public class func connectToSocket(_ endpoint: String,
                                      delegate: Web3SocketDelegate? = nil,
                                      projectId: String? = nil,
                                      network net: Networks? = nil) -> WebsocketProvider? {
        guard let socketProvider = WebsocketProvider(endpoint,
                                                     delegate: delegate,
                                                     projectId: projectId,
                                                     network: net) else {
                                                return nil
        }
        socketProvider.connectSocket()
        return socketProvider
    }
    
    public class func connectToSocket(_ endpoint: URL,
                                      delegate: Web3SocketDelegate? = nil,
                                      projectId: String? = nil,
                                      network net: Networks? = nil) -> WebsocketProvider? {
        guard let socketProvider = WebsocketProvider(endpoint,
                                                     delegate: delegate,
                                                     projectId: projectId,
                                                     network: net) else {
                                                        return nil
        }
        socketProvider.connectSocket()
        return socketProvider
    }
    
    public func writeMessage<T>(_ message: T) {
        var sMessage: String? = nil
        var dMessage: Data? = nil
        if !(message.self is String) && !(message.self is Data) {
            sMessage = "\(message)"
        } else if message.self is String {
            sMessage = message as? String
        } else if message.self is Data {
            dMessage = message as? Data
        }
        if sMessage != nil {
            self.messagesStringToWrite.append(sMessage!)
        } else if dMessage != nil {
            self.messagesDataToWrite.append(dMessage!)
        }
        writeTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(performWriteOperations), userInfo: nil, repeats: true)
    }
    
    public func writeMessage(method: JSONRPCmethod, params: [Encodable]) throws {
        let request = JSONRPCRequestFabric.prepareRequest(method, parameters: params)
        let encoder = JSONEncoder()
        let requestData = try encoder.encode(request)
        print(String(decoding: requestData, as: UTF8.self))
        writeMessage(requestData)
    }
    
    @objc private func performWriteOperations() {
        if websocketConnected {
            writeTimer?.invalidate()
            for s in messagesStringToWrite {
                socket.write(string: s)
            }
            for d in messagesDataToWrite {
                socket.write(data: d)
            }
        }
    }
    
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            debugMode ? print("websocket is connected, headers:\n \(headers)") : nil
            websocketConnected = true
            delegate.socketConnected(headers)
        case .disconnected(let reason, let code):
            debugMode ? print("websocket is disconnected: \(reason) with code: \(code)") : nil
            websocketConnected = false
            delegate.gotError(error: Web3Error.connectionError)
        case .text(let string):
            debugMode ? print("received text: \(string)") : nil
            websocketDidReceiveMessage(text: string)
            break
        case .binary(let data):
            debugMode ? print("received text: \(String(data: data, encoding: .utf8) ?? "empty")") : nil
            delegate.gotError(error: Web3Error.processingError(desc: "Unsupported data type"))
        case .ping(_):
            debugMode ? print("ping") : nil
            break
        case .pong(_):
            debugMode ? print("pong") : nil
            break
        case .viabilityChanged(_):
            debugMode ? print("viabilityChanged") : nil
            break
        case .reconnectSuggested(_):
            debugMode ? print("reconnectSuggested") : nil
            break
        case .cancelled:
            debugMode ? print("cancelled") : nil
            websocketConnected = false
            delegate.gotError(error: Web3Error.nodeError(desc: "socket cancelled"))
        case .error(let error):
            debugMode ? print("error: \(String(describing: error))") : nil
            websocketConnected = false
            delegate.gotError(error: error!)
        }
    }
    
    private func websocketDidReceiveMessage(text: String) {
        if let data = text.data(using: String.Encoding.utf8),
           let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            if let _ = dictionary["id"] as? UInt64 {
                let response: JSONRPCresponse
                do {
                    response = try JSONDecoder().decode(JSONRPCresponse.self, from: data)
                } catch {
                    delegate.gotError(error: Web3Error.processingError(desc: "Cannot parse JSON-RPC response. Error: \(String(describing: error)). Response: \(text)"))
                    return
                }
                internalQueue.sync {
                    if let request = requests.removeValue(forKey: UInt64(response.id)) {
                        if let error = response.error {
                            request(.failure(Web3Error.nodeError(desc: "Received an error message\n" + String(describing: error))))
                        } else {
                            request(.success(response))
                        }
                    } else {
                        delegate.gotError(error: Web3Error.processingError(desc: "Unknown response id. Message is: \(text)"))
                    }
                }
            } else if let params = dictionary["params"] as? [String: Any],
                      let subscriptionID = params["subscription"] as? String {
                guard let subscription = subscriptions[subscriptionID] else {
                    delegate.gotError(error: Web3Error.processingError(desc: "Unknown subscription id: \(subscriptionID)"))
                    return
                }
                subscription.cb(.success(data))
            } else {
                delegate.gotError(error: Web3Error.processingError(desc: "Can\'t get known result. Message is: \(text)"))
            }
        }
    }
}
