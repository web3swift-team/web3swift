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
import EthereumAddress

extension web3.Eth {
    
    public func getWebsocketProvider(forDelegate delegate: Web3SocketDelegate) throws -> InfuraWebsocketProvider {
        var infuraWSProvider: InfuraWebsocketProvider
        if !(provider is InfuraWebsocketProvider) {
            guard let infuraNetwork = provider.network else {
                throw Web3Error.processingError(desc: "Wrong network")
            }
            guard let infuraProvider = InfuraWebsocketProvider(infuraNetwork, delegate: delegate, keystoreManager: provider.attachedKeystoreManager) else {
                throw Web3Error.processingError(desc: "Wrong network")
            }
            infuraWSProvider = infuraProvider
        } else {
            infuraWSProvider = provider as! InfuraWebsocketProvider
        }
        infuraWSProvider.connectSocket()
        return infuraWSProvider
    }
    
    public func getLatestPendingTransactions(forDelegate delegate: Web3SocketDelegate) throws {
        let provider = try getWebsocketProvider(forDelegate: delegate)
        try provider.filter(method: .newPendingTransactionFilter)
    }
    
    public func subscribeOnPendingTransactions(forDelegate delegate: Web3SocketDelegate) throws {
        let provider = try getWebsocketProvider(forDelegate: delegate)
        try provider.subscribeOnNewPendingTransactions()
    }
}

public protocol IWebsocketProvider {
    var socket: WebSocket {get}
    var delegate: Web3SocketDelegate {get set}
    func connectSocket() throws
    func disconnectSocket() throws
    func writeMessage(string: String)
    func writeMessage(data: Data)
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

public final class InfuraWebsocketProvider: WebsocketProvider {
    public var filterID: String?
    public var subscriptionIDs = Set<String>()
    private var subscriptionIDforUnsubscribing: String? = nil
    private var filterTimer: Timer?
    
    public init?(_ network: Networks,
                 delegate: Web3SocketDelegate,
                 keystoreManager manager: KeystoreManager? = nil) {
        guard network == Networks.Kovan
            || network == Networks.Rinkeby
            || network == Networks.Ropsten
            || network == Networks.Mainnet else {return nil}
        let networkName = network.name
        let urlString = "wss://\(networkName).infura.io/ws"
        guard let socketURL = URL(string: urlString) else {return nil}
        super.init(endpoint: socketURL,
                   delegate: delegate,
                   keystoreManager: manager)
    }
    
    public static func connectToSocket(_ network: Networks,
                                       delegate: Web3SocketDelegate,
                                       keystoreManager manager: KeystoreManager? = nil) -> InfuraWebsocketProvider? {
        guard let socketProvider = InfuraWebsocketProvider(network,
                                                            delegate: delegate,
                                                            keystoreManager: manager) else {return nil}
        socketProvider.connectSocket()
        return socketProvider
    }
    
    public func writeMessage(method: InfuraWebsocketMethod, params: [Encodable]) throws {
        let request = JSONRPCRequestFabric.prepareRequest(method, parameters: params)
        let encoder = JSONEncoder()
        let requestData = try encoder.encode(request)
        writeMessage(data: requestData)
    }
    
    public func filter(method: InfuraWebsocketMethod, params: [Encodable]? = nil) throws {
        filterTimer?.invalidate()
        filterID = nil
        let params = params ?? []
        let paramsCount = params.count
        guard method.requiredNumOfParameters == paramsCount || method.requiredNumOfParameters == nil else {
            throw Web3Error.inputError(desc: "Wrong number of params: need - \(method.requiredNumOfParameters!), got - \(paramsCount)")
        }
        try writeMessage(method: method, params: params)
        filterTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(getFilterChanges), userInfo: nil, repeats: true)
    }
    
    @objc public func getFilterChanges() throws {
        if let id = self.filterID {
            filterTimer?.invalidate()
            let method = InfuraWebsocketMethod.getFilterChanges
            try writeMessage(method: method, params: [id])
        }
    }
    
    public func getFilterLogs() throws {
        if let id = self.filterID {
            let method = InfuraWebsocketMethod.getFilterLogs
            try writeMessage(method: method, params: [id])
        }
    }
    
    public func unistallFilter() throws {
        if let id = self.filterID {
            let method = InfuraWebsocketMethod.uninstallFilter
            try writeMessage(method: method, params: [id])
        }
    }
    
    public func subscribe(params: [Encodable]) throws {
        let method = InfuraWebsocketMethod.subscribe
        try writeMessage(method: method, params: params)
    }
    
    public func unsubscribe(subscriptionID: String) throws {
        let method = InfuraWebsocketMethod.unsubscribe
        subscriptionIDforUnsubscribing = subscriptionID
        try writeMessage(method: method, params: [subscriptionID])
    }
    
    public func subscribeOnNewHeads() throws {
        let method = InfuraWebsocketMethod.subscribe
        let params = ["newHeads"]
        try writeMessage(method: method, params: params)
    }
    
    public func subscribeOnNewPendingTransactions() throws {
        let method = InfuraWebsocketMethod.subscribe
        let params = ["newPendingTransactions"]
        try writeMessage(method: method, params: params)
    }
    
    public func subscribeOnSyncing() throws {
        guard network != Networks.Kovan else {
            throw Web3Error.inputError(desc: "Can't sync on Kovan")
        }
        let method = InfuraWebsocketMethod.subscribe
        let params = ["syncing"]
        try writeMessage(method: method, params: params)
    }
    
    override public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if let data = text.data(using: String.Encoding.utf8),
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            if filterID == nil,
                let result = dictionary["result"] as? String {
                // setting filter id
                filterID = result
            } else if let params = dictionary["params"] as? [String: Any],
                let subscription = params["subscription"] as? String,
                let result = params["result"] {
                // subscription result
                subscriptionIDs.insert(subscription)
                delegate.received(message: result)
            } else if let unsubscribed = dictionary["result"] as? Bool {
                // unsubsribe result
                if unsubscribed == true, let id = subscriptionIDforUnsubscribing {
                    subscriptionIDs.remove(id)
                } else if let id = subscriptionIDforUnsubscribing {
                    delegate.gotError(error: Web3Error.processingError(desc: "Can\'t unsubscribe \(id)"))
                } else {
                    delegate.received(message: unsubscribed)
                }
            } else if let message = dictionary["result"] {
                // filter result
                delegate.received(message: message)
            } else {
                delegate.gotError(error: Web3Error.processingError(desc: "Can\'t get known result. Message is: \(text)"))
            }
        }
    }
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
    
    public init(endpoint: URL,
                delegate wsdelegate: Web3SocketDelegate,
                keystoreManager manager: KeystoreManager? = nil,
                network net: Networks? = nil) {
        delegate = wsdelegate
        attachedKeystoreManager = manager
        url = endpoint
        socket = WebSocket(url: endpoint)
        socket.delegate = self
        if net == nil {
            let endpointString = endpoint.absoluteString
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
    
    public static func connectToSocket(endpoint: URL,
                                       delegate: Web3SocketDelegate,
                                       keystoreManager manager: KeystoreManager? = nil,
                                       network net: Networks? = nil) -> WebsocketProvider {
        let socketProvider = WebsocketProvider(endpoint: endpoint,
                                               delegate: delegate,
                                               keystoreManager: manager,
                                               network: net)
        socketProvider.connectSocket()
        return socketProvider
    }
    
    public func writeMessage(string: String) {
        socket.write(string: string)
    }
    
    public func writeMessage(data: Data) {
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
        print("Got pong! Maybe some data: \(data?.count)")
    }
}

