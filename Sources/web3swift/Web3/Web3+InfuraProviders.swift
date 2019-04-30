//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
import Foundation
import BigInt
import Starscream

/// Custom Web3 HTTP provider of Infura nodes.
public final class InfuraProvider: Web3HttpProvider {
    public init?(_ net:Networks, accessToken token: String? = nil, keystoreManager manager: KeystoreManager? = nil) {
        var requestURLstring = "https://" + net.name + ".infura.io/"
        if token != nil {
            requestURLstring = requestURLstring + token!
        }
        let providerURL = URL(string: requestURLstring)
        super.init(providerURL!, network: net, keystoreManager: manager)
    }
}

/// Custom Websocket provider of Infura nodes.
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
        guard URL(string: urlString) != nil else {return nil}
        super.init(urlString,
                   delegate: delegate,
                   keystoreManager: manager,
                   network: network)
    }
    
    public init?(_ endpoint: String,
                 delegate: Web3SocketDelegate,
                 keystoreManager manager: KeystoreManager? = nil) {
        guard URL(string: endpoint) != nil else {return nil}
        super.init(endpoint,
                   delegate: delegate,
                   keystoreManager: manager)
    }
    
    public init?(_ endpoint: URL,
                 delegate: Web3SocketDelegate,
                 keystoreManager manager: KeystoreManager? = nil) {
        super.init(endpoint,
                   delegate: delegate,
                   keystoreManager: manager)
    }
    
    override public class func connectToSocket(_ endpoint: String,
                                               delegate: Web3SocketDelegate,
                                               keystoreManager manager: KeystoreManager? = nil,
                                               network net: Networks? = nil) -> WebsocketProvider? {
        guard let socketProvider = InfuraWebsocketProvider(endpoint,
                                                           delegate: delegate,
                                                           keystoreManager: manager) else {return nil}
        socketProvider.connectSocket()
        return socketProvider
    }
    
    override public class func connectToSocket(_ endpoint: URL,
                                               delegate: Web3SocketDelegate,
                                               keystoreManager manager: KeystoreManager? = nil,
                                               network net: Networks? = nil) -> WebsocketProvider? {
        guard let socketProvider = InfuraWebsocketProvider(endpoint,
                                                           delegate: delegate,
                                                           keystoreManager: manager) else {return nil}
        socketProvider.connectSocket()
        return socketProvider
    }
    
    public static func connectToInfuraSocket(_ network: Networks,
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
        writeMessage(requestData)
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
