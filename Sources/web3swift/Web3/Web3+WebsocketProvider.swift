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

public protocol IWebsocketProvider {
    var socket: WebSocket {get}
    var delegate: Web3SocketDelegate {get set}
    func connectSocket() throws
    func disconnectSocket() throws
    func writeMessage<T>(_ message: T)
}

public enum WebsocketMethod: String, Encodable {
    
    case newPendingTransactionFilter = "eth_newPendingTransactionFilter"
    case getFilterChanges = "eth_getFilterChanges"
    case newFilter = "eth_newFilter"
    case newBlockFilter = "eth_newBlockFilter"
    case getFilterLogs = "eth_getFilterLogs"
    case uninstallFilter = "eth_uninstallFilter"
    case subscribe = "eth_subscribe"
    case unsubscribe = "eth_unsubscribe"
    
    public var requiredNumOfParameters: Int? {
        get {
            switch self {
            case .newPendingTransactionFilter:
                return 0
            case .getFilterChanges:
                return 1
            case .newFilter:
                return nil
            case .newBlockFilter:
                return 0
            case .getFilterLogs:
                return nil
            case .uninstallFilter:
                return 1
            case .subscribe:
                return nil
            case .unsubscribe:
                return 1
            }
        }
    }
}

public struct WebsocketRequest: Encodable {
    public var jsonrpc: String = "2.0"
    public var method: WebsocketMethod?
    public var params: JSONRPCparams?
    public var id: UInt64 = Counter.increment()
    
    enum CodingKeys: String, CodingKey {
        case jsonrpc
        case method
        case params
        case id
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encode(method?.rawValue, forKey: .method)
        try container.encode(params, forKey: .params)
        try container.encode(id, forKey: .id)
    }
    
    public var isValid: Bool {
        get {
            if self.method == nil {
                return false
            }
            guard let method = self.method else {return false}
            return method.requiredNumOfParameters == self.params?.params.count
        }
    }
}

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
    public var id = ""
    private let unsubscribeCallback: (Self) -> Void
    
    public init(unsubscribeCallback: @escaping (Self) -> Void) {
        self.unsubscribeCallback = unsubscribeCallback
    }
    
    public func unsubscribe() {
        unsubscribeCallback(self)
    }
}

/// The default websocket provider.
public class WebsocketProvider: Web3SubscriptionProvider, IWebsocketProvider, WebSocketDelegate {

    public func sendAsync(_ request: JSONRPCrequest, queue: DispatchQueue) -> Promise<JSONRPCresponse> {
        return Promise(error: Web3Error.inputError(desc: "Sending is unsupported for Websocket provider. Please, use \'sendMessage\'"))
    }
    
    public func sendAsync(_ requests: JSONRPCrequestBatch, queue: DispatchQueue) -> Promise<JSONRPCresponseBatch> {
        return Promise(error: Web3Error.inputError(desc: "Sending is unsupported for Websocket provider. Please, use \'sendMessage\'"))
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
    /// A flag that is true if socket connected or false if socket doesn't connected.
    public var websocketConnected: Bool = false
    
    private var writeTimer: Timer? = nil
    private var messagesStringToWrite: [String] = []
    private var messagesDataToWrite: [Data] = []
    
    /// if set debugMode True then show websocket events logs in the console
    public var debugMode: Bool = false
    
    private var subscriptions = [String: (sub: WebsocketSubscription, cb: (Swift.Result<Decodable, Error>) -> Void)]()
    private var requests = [UInt32: (Swift.Result<Decodable, Error>) -> Void]()
    
    private var currentID: UInt32 = 0
    
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
        socket = WebSocket(request: request)
        socket.delegate = self
    }
    
    deinit {
        writeTimer?.invalidate()
    }
    
    private func newID() -> UInt32 {
        currentID = currentID == UInt32.max ? 1 : currentID + 1
        return currentID
    }
    
    public func subscribe<R>(filter: SubscribeEventFilter,
                             listener: @escaping Web3SubscriptionListener<R>) -> Subscription {
        let params: [Encodable]
        switch filter {
        case .newHeads:
            params = ["newHeads"]
        case .logs(let p):
            params = ["logs", p]
        case .newPendingTransactions:
            params = ["newPendingTransactions"]
        case .syncing:
            params = ["syncing"]
        }
        let method = WebsocketMethod.subscribe
        var subscription = WebsocketSubscription(unsubscribeCallback: { subscription in
            let method = WebsocketMethod.unsubscribe
            self.send(id: self.newID(), method: method, params: [subscription.id]) { result in
                switch result {
                case .success(let data):
                    let unsubscribed = data as! Bool
                    if unsubscribed {
                        self.subscriptions.removeValue(forKey: subscription.id)
                    } else {
                        self.delegate.gotError(error: Web3Error.processingError(desc: "Can\'t unsubscribe \(subscription.id)"))
                    }
                case .failure(let error):
                    self.delegate.gotError(error: error)
                }
            }
        })
        let handler = { (result: Swift.Result<Decodable, Error>) in
            listener(result.map { $0 as! R })
        }
        send(id: newID(), method: method, params: params) { result in
            switch result {
            case .success(let data):
                let subscriptionID = data as! String
                subscription.id = subscriptionID
                self.subscriptions[subscriptionID] = (subscription, handler)
            case .failure(let error):
                handler(.failure(error))
            }
        }
        return subscription
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
    
    public func writeMessage(method: WebsocketMethod, params: [Encodable]) throws {
        let request = JSONRPCRequestFabric.prepareRequest(method, parameters: params)
        let encoder = JSONEncoder()
        let requestData = try encoder.encode(request)
        print(String(decoding: requestData, as: UTF8.self))
        writeMessage(requestData)
    }
    
    private func send(id: UInt32,
                      method: WebsocketMethod,
                      params: [Encodable],
                      cb: @escaping (Swift.Result<Decodable, Error>) -> Void) {
        do {
            try writeMessage(method: method, params: params)
        } catch {
            cb(.failure(error))
            return
        }
        requests[id] = cb
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
            // TODO: filterID
//            if filterID == nil,
//                let result = dictionary["result"] as? String {
//                // setting filter id
//                filterID = result
//            } else
            if let id = dictionary["id"] as? UInt32,
                      let result = dictionary["result"] as? Decodable {
                guard let request = requests.removeValue(forKey: id) else {
                    return
                }
                request(.success(result))
            } else if let params = dictionary["params"] as? [String: Any],
                let subscriptionID = params["subscription"] as? String,
                let result = params["result"] as? Decodable {
                guard let subscription = subscriptions[subscriptionID] else {
                    return
                }
                subscription.cb(.success(result))
            } else if let message = dictionary["result"] {
                // filter result
                // TODO: process filter result
            } else {
                delegate.gotError(error: Web3Error.processingError(desc: "Can\'t get known result. Message is: \(text)"))
            }
        }
    }
}
