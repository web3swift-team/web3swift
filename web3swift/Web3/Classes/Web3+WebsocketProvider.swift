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
    func writeMessage(_ string: String)
    func writeMessage(_ data: Data)
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
    
    public init?(_ endpoint: URL,
                 delegate wsdelegate: Web3SocketDelegate,
                 keystoreManager manager: KeystoreManager? = nil,
                 network net: Networks? = nil) {
        delegate = wsdelegate
        attachedKeystoreManager = manager
        url = endpoint
        socket = WebSocket(url: endpoint)
        socket.delegate = self
        let endpointString = endpoint.absoluteString
        if !(endpointString.hasPrefix("wss://") || endpointString.hasPrefix("ws://")) {
            return nil
        }
        if net == nil {
            if endpointString.hasPrefix("wss://") && endpointString.hasSuffix(".infura.io/ws") {
                let networkString = endpointString.replacingOccurrences(of: "wss://", with: "")
                    .replacingOccurrences(of: ".infura.io/ws", with: "")
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
            }
        } else {
            network = net
        }
    }
    
    public init?(_ endpoint: String,
                 delegate wsdelegate: Web3SocketDelegate,
                 keystoreManager manager: KeystoreManager? = nil,
                 network net: Networks? = nil) {
        guard let endpointUrl = URL(string: endpoint) else {return nil}
        delegate = wsdelegate
        attachedKeystoreManager = manager
        url = endpointUrl
        socket = WebSocket(url: endpointUrl)
        socket.delegate = self
        let endpointString = endpointUrl.absoluteString
        if !(endpointString.hasPrefix("wss://") || endpointString.hasPrefix("ws://")) {
            return nil
        }
        if net == nil {
            if endpointString.hasPrefix("wss://") && endpointString.hasSuffix(".infura.io/ws") {
                let networkString = endpointString.replacingOccurrences(of: "wss://", with: "")
                    .replacingOccurrences(of: ".infura.io/ws", with: "")
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
            }
        } else {
            network = net
        }
    }
    
    public func connectSocket() {
        socket.connect()
    }
    
    public func disconnectSocket() {
        socket.disconnect()
    }
    
    public class func connectToSocket(_ endpoint: String,
                                      delegate: Web3SocketDelegate,
                                      keystoreManager manager: KeystoreManager? = nil,
                                      network net: Networks? = nil) -> WebsocketProvider? {
        guard let socketProvider = WebsocketProvider(endpoint,
                                                     delegate: delegate,
                                                     keystoreManager: manager,
                                                     network: net) else {
                                                return nil
        }
        socketProvider.connectSocket()
        return socketProvider
    }
    
    public class func connectToSocket(_ endpoint: URL,
                                      delegate: Web3SocketDelegate,
                                      keystoreManager manager: KeystoreManager? = nil,
                                      network net: Networks? = nil) -> WebsocketProvider? {
        guard let socketProvider = WebsocketProvider(endpoint,
                                                     delegate: delegate,
                                                     keystoreManager: manager,
                                                     network: net) else {
                                                        return nil
        }
        socketProvider.connectSocket()
        return socketProvider
    }
    
    public func writeMessage(_ string: String) {
        socket.write(string: string)
    }
    
    public func writeMessage(_ data: Data) {
        socket.write(data: data)
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("got some text: \(text)")
        delegate.received(message: text)
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data.count)")
        delegate.received(message: data)
    }
    
    public func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected with \(error?.localizedDescription ?? "no error")")
    }
    
    public func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
        print("Got pong! Maybe some data: \(String(describing: data?.count))")
    }
}
