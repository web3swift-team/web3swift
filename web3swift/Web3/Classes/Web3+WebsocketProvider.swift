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
    var socket: WebSocket? {get set}
    var delegate: Web3SocketDelegate? {get set}
    static func connectToSocket(_ provider: Web3Provider, delegate: Web3SocketDelegate) -> Web3SocketProvider?
    func subscribeOn(method: WebsocketMethod, params: JSONRPCparams?) throws
    func disconnectSocket() throws
}

public enum WebsocketMethod {
    case pendingTransactions
    
    public var getJSONRPCmethod: JSONRPCmethod {
        switch self {
        case .pendingTransactions:
            return .newPendingTransactionFilter
        }
    }
}

public protocol Web3SocketDelegate {
    func received(message: Any)
}

/// The default websocket provider.
public class Web3SocketProvider: WebsocketProvider {
    
    public var socket: WebSocket?
    public var delegate: Web3SocketDelegate?
    public var subscriptionKey: String?
    
    private var subscriptionTimer: Timer?
    
    private init() {}
    
    public static func connectToSocket(_ provider: Web3Provider, delegate: Web3SocketDelegate) -> Web3SocketProvider? {
        let socketProvider = Web3SocketProvider()
        
        guard let network = provider.network else {return nil}
        guard network == Networks.Kovan
            || network == Networks.Rinkeby
            || network == Networks.Ropsten
            || network == Networks.Mainnet else {return nil}
        let networkName = network.name
        let urlString = "wss://\(networkName).infura.io/ws"
        guard let socketURL = URL(string: urlString) else {return nil}
        
        socketProvider.socket = WebSocket(url: socketURL)
        socketProvider.socket?.delegate = socketProvider
        socketProvider.socket?.connect()
        socketProvider.delegate = delegate
        return socketProvider
    }
    
    public func disconnectSocket() throws {
        guard let socket = self.socket else {
            throw Web3Error.connectionError
        }
        socket.disconnect()
    }
    
    public func subscribeOn(method: WebsocketMethod, params: JSONRPCparams? = nil) throws {
        do {
            subscriptionTimer?.invalidate()
            guard let socket = self.socket else {
                throw Web3Error.connectionError
            }
            let jsonrpcMethod = method.getJSONRPCmethod
            let paramsCount = params == nil
                ? 0
                : params!.params.count
            guard jsonrpcMethod.requiredNumOfParameters == paramsCount else {
                throw Web3Error.inputError(desc: "Wrong number of params: need - \(jsonrpcMethod.requiredNumOfParameters), got - \(paramsCount)")
            }
            let request = JSONRPCRequestFabric.prepareRequest(jsonrpcMethod, parameters: [])
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
            if let key = self.subscriptionKey,
                let socket = self.socket {
                //                self.subscriptionTimer?.invalidate()
                //                let method = JSONRPCmethod.getFilterChanges
                //                let request = JSONRPCRequestFabric.prepareRequest(method, parameters: ["\(key)"])
                //                let encoder = JSONEncoder()
                //                if let requestData = try? encoder.encode(request) {
                //                    socket.write(data: requestData)
                //                }
                
                // TODO: - This should be in another way, but only this works
                socket.write(string: "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getFilterChanges\",\"params\":[\"\(key)\"],\"id\":1}")
                self.subscriptionTimer?.invalidate()
            }
        }
    }
}

extension Web3SocketProvider: WebSocketDelegate {
    public func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected with \(error?.localizedDescription ?? "no error")")
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("got some text: \(text)")
        if let data = text.data(using: String.Encoding.utf8),
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] {
            if subscriptionKey == nil,
                let result = dictionary["result"] as? String {
                subscriptionKey = result
            } else {
                let result = dictionary["result"] as Any
                delegate?.received(message: result)
            }
        }
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data.count)")
    }
    
    public func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
        print("Got pong! Maybe some data: \(data?.count)")
    }
}


