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

public enum InfuraWebsocketMethod: String, Encodable {

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

public struct InfuraWebsocketRequest: Encodable {
    public var jsonrpc: String = "2.0"
    public var method: InfuraWebsocketMethod?
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
    func socketConnected(_ headers: [String: String])
    func received(message: Any)
    func gotError(error: Error)
}

/// The default websocket provider.
public class WebsocketProvider: Web3Provider, IWebsocketProvider, WebSocketDelegate {

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
    public var attachedKeystoreManager: KeystoreManager? = nil

    public var socket: WebSocket
    public var delegate: Web3SocketDelegate
    /// A flag that is true if socket connected or false if socket doesn't connected.
    public var websocketConnected: Bool = false

    private var writeTimer: Timer? = nil
    private var messagesStringToWrite: [String] = []
    private var messagesDataToWrite: [Data] = []

    public init?(_ endpoint: URL,
                 delegate wsdelegate: Web3SocketDelegate,
                 projectId: String? = nil,
                 keystoreManager manager: KeystoreManager? = nil,
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
        delegate = wsdelegate
        attachedKeystoreManager = manager
        let request = URLRequest(url: url)
        socket = WebSocket(request: request)
        socket.delegate = self
    }

    public init?(_ endpoint: String,
                 delegate wsdelegate: Web3SocketDelegate,
                 projectId: String? = nil,
                 keystoreManager manager: KeystoreManager? = nil,
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
        delegate = wsdelegate
        attachedKeystoreManager = manager
        let request = URLRequest(url: url)
        socket = WebSocket(request: request)
        socket.delegate = self
    }

    deinit {
        writeTimer?.invalidate()
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
                                      delegate: Web3SocketDelegate,
                                      projectId: String? = nil,
                                      keystoreManager manager: KeystoreManager? = nil,
                                      network net: Networks? = nil) -> WebsocketProvider? {
        guard let socketProvider = WebsocketProvider(endpoint,
                                                     delegate: delegate,
                                                     projectId: projectId,
                                                     keystoreManager: manager,
                                                     network: net) else {
                                                return nil
        }
        socketProvider.connectSocket()
        return socketProvider
    }

    public class func connectToSocket(_ endpoint: URL,
                                      delegate: Web3SocketDelegate,
                                      projectId: String? = nil,
                                      keystoreManager manager: KeystoreManager? = nil,
                                      network net: Networks? = nil) -> WebsocketProvider? {
        guard let socketProvider = WebsocketProvider(endpoint,
                                                     delegate: delegate,
                                                     projectId: projectId,
                                                     keystoreManager: manager,
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
            websocketConnected = true
            delegate.socketConnected(headers)
        case .disconnected(let reason, let code):
            print("socket disconnected: \(reason) , code: \(code)")
            websocketConnected = false
            delegate.gotError(error: Web3Error.connectionError)
        case .text(let string):
            delegate.received(message: string)
            break
        case .binary(let data):
            delegate.received(message: data)
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            websocketConnected = false
            delegate.gotError(error: Web3Error.nodeError(desc: "socket cancelled"))
        case .error(let error):
            websocketConnected = false
            delegate.gotError(error: error!)
        }
    }
}
