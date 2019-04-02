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

public protocol WebsocketProvider {
    var socket: WebSocket {get}
    var delegate: Web3SocketDelegate {get set}
    static func connectToSocket(endpoint: URL,
                                delegate: Web3SocketDelegate,
                                keystoreManager manager: KeystoreManager?) -> Web3SocketProvider
    func connectSocket() throws
    func disconnectSocket() throws
}

public enum InfuraWebsocketMethod: String, Encodable {
    
    case newPendingTransactionFilter = "eth_newPendingTransactionFilter"
    case getFilterChanges = "eth_getFilterChanges"
    
    public var requiredNumOfParameters: Int {
        get {
            switch self {
            case .newPendingTransactionFilter:
                return 0
            case .getFilterChanges:
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
}

public final class InfuraWeb3SocketProvider: Web3SocketProvider {
    public var subscriptionKey: String?
    private var subscriptionTimer: Timer?
    
    public init?(_ network: Networks,
                 delegate: Web3SocketDelegate,
                 keystoreManager manager: KeystoreManager?) {
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
                                       keystoreManager manager: KeystoreManager?) -> Web3SocketProvider? {
        guard let socketProvider = InfuraWeb3SocketProvider(network,
                                                            delegate: delegate,
                                                            keystoreManager: manager) else {return nil}
        socketProvider.socket.connect()
        return socketProvider
    }
    
    public func subscribeOn(method: InfuraWebsocketMethod, params: [Encodable]? = nil) throws {
        do {
            subscriptionTimer?.invalidate()
            subscriptionKey = nil
            let params = params ?? []
            let paramsCount = params.count
            guard method.requiredNumOfParameters == paramsCount else {
                throw Web3Error.inputError(desc: "Wrong number of params: need - \(method.requiredNumOfParameters), got - \(paramsCount)")
            }
            let request = JSONRPCRequestFabric.prepareRequest(method, parameters: params)
            let encoder = JSONEncoder()
            let requestData = try encoder.encode(request)
            socket.write(data: requestData)
            subscriptionTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.getSubscriptionChanges), userInfo: nil, repeats: true)
        } catch {
            throw Web3Error.connectionError
        }
    }
    
    @objc public func getSubscriptionChanges() {
        DispatchQueue.global().async { [unowned self] in
            if let key = self.subscriptionKey {
                self.subscriptionTimer?.invalidate()
                let method = InfuraWebsocketMethod.getFilterChanges
                let request = JSONRPCRequestFabric.prepareRequest(method, parameters: [key])
                let encoder = JSONEncoder()
                if let requestData = try? encoder.encode(request) {
                    self.socket.write(data: requestData)
                }
                
//                // TODO: - This should be in another way, but only this works
//                self.socket.write(string: "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getFilterChanges\",\"params\":[\"\(key)\"],\"id\":1}")
//                self.subscriptionTimer?.invalidate()
            }
        }
    }
    
    override public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if let data = text.data(using: String.Encoding.utf8),
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] {
            if subscriptionKey == nil,
                let result = dictionary["result"] as? String {
                subscriptionKey = result
            } else {
                let result = dictionary["result"] as Any
                delegate.received(message: result)
            }
        }
    }
}

/// The default websocket provider.
public class Web3SocketProvider: Web3Provider, WebsocketProvider, WebSocketDelegate {
    public func sendAsync(_ request: JSONRPCrequest, queue: DispatchQueue) -> Promise<JSONRPCresponse> {
        if request.method == nil {
            return Promise(error: Web3Error.nodeError(desc: "RPC method is nil"))
        }
        
        return Web3HttpProvider.post(request, providerURL: self.url, queue: queue, session: self.session)
    }
    
    public func sendAsync(_ requests: JSONRPCrequestBatch, queue: DispatchQueue) -> Promise<JSONRPCresponseBatch> {
        return Web3HttpProvider.post(requests, providerURL: self.url, queue: queue, session: self.session)
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
                keystoreManager manager: KeystoreManager?,
                network net: Networks? = nil) {
        delegate = wsdelegate
        attachedKeystoreManager = manager
        url = endpoint
        socket = WebSocket(url: endpoint)
        socket.delegate = self
        if net == nil {
            let request = JSONRPCRequestFabric.prepareRequest(.getNetwork, parameters: [])
            
            if let response = try? Web3HttpProvider.post(request,
                                                            providerURL: endpoint,
                                                            queue: DispatchQueue.global(qos: .userInteractive),
                                                            session: session).wait(),
                response.error == nil,
                let result: String = response.getValue(),
                let intNetworkNumber = Int(result) {
                network = Networks.fromInt(intNetworkNumber)
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
                                       keystoreManager manager: KeystoreManager?) -> Web3SocketProvider {
        let socketProvider = Web3SocketProvider(endpoint: endpoint,
                                                delegate: delegate,
                                                keystoreManager: manager)
        socketProvider.connectSocket()
        return socketProvider
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

