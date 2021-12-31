//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
import Foundation
import BigInt
import Starscream

public enum BlockNumber {
    case pending
    case latest
    case earliest
    case exact(BigUInt)
    
    public var stringValue: String {
        switch self {
        case .pending:
            return "pending"
        case .latest:
            return "latest"
        case .earliest:
            return "earliest"
        case .exact(let number):
            return String(number, radix: 16).addHexPrefix()
        }
    }
}

/// Custom Web3 HTTP provider of Infura nodes.
public final class InfuraProvider: Web3HttpProvider {
    public init?(_ net:Networks, accessToken token: String? = nil) {
        var requestURLstring = "https://" + net.name + Constants.infuraHttpScheme
        requestURLstring += token != nil ? token! : Constants.infuraToken
        let providerURL = URL(string: requestURLstring)
        super.init(providerURL!, network: net)
    }
}

/// Custom Websocket provider of Infura nodes.
public final class InfuraWebsocketProvider: WebsocketProvider {
    public var filterID: String?
    public var subscriptions = [String: (sub: WebsocketSubscription, cb: (Result<Decodable, Error>) -> Void)]()
    private var requests = [UInt32: (Result<Decodable, Error>) -> Void]()
    private var filterTimer: Timer?
    
    /// if set debugMode True then show websocket events logs in the console
    public var debugMode: Bool = false
    
    public init?(_ network: Networks,
                 delegate: Web3SocketDelegate,
                 projectId: String? = nil) {
        guard network == Networks.Kovan
            || network == Networks.Rinkeby
            || network == Networks.Ropsten
            || network == Networks.Mainnet else {return nil}
        let networkName = network.name
        let urlString = "wss://" + networkName + Constants.infuraWsScheme
        guard URL(string: urlString) != nil else {return nil}
        super.init(urlString,
                   delegate: delegate,
                   projectId: projectId,
                   network: network)
    }
    
    public init?(_ endpoint: String,
                 delegate: Web3SocketDelegate,
                 projectId: String? = nil) {
        guard URL(string: endpoint) != nil else {return nil}
        super.init(endpoint,
                   delegate: delegate,
                   projectId: projectId)
    }
    
    public init?(_ endpoint: URL,
                 delegate: Web3SocketDelegate,
                 projectId: String? = nil) {
        super.init(endpoint,
                   delegate: delegate,
                   projectId: projectId)
    }
    
    override public class func connectToSocket(_ endpoint: String,
                                               delegate: Web3SocketDelegate,
                                               projectId: String? = nil,
                                               network net: Networks? = nil) -> WebsocketProvider? {
        guard let socketProvider = InfuraWebsocketProvider(endpoint,
                                                           delegate: delegate,
                                                           projectId: projectId) else {return nil}
        socketProvider.connectSocket()
        return socketProvider
    }
    
    override public class func connectToSocket(_ endpoint: URL,
                                               delegate: Web3SocketDelegate,
                                               projectId: String? = nil,
                                               network net: Networks? = nil) -> WebsocketProvider? {
        guard let socketProvider = InfuraWebsocketProvider(endpoint,
                                                           delegate: delegate,
                                                           projectId: projectId) else {return nil}
        socketProvider.connectSocket()
        return socketProvider
    }
    
    public static func connectToInfuraSocket(_ network: Networks,
                                             delegate: Web3SocketDelegate,
                                             projectId: String? = nil) -> InfuraWebsocketProvider? {
        guard let socketProvider = InfuraWebsocketProvider(network,
                                                           delegate: delegate,
                                                           projectId: projectId) else {return nil}
        socketProvider.connectSocket()
        return socketProvider
    }
    
    public func writeMessage(method: InfuraWebsocketMethod, params: [Encodable]) throws {
        let request = JSONRPCRequestFabric.prepareRequest(method, parameters: params)
        let encoder = JSONEncoder()
        let requestData = try encoder.encode(request)
        print(String(decoding: requestData, as: UTF8.self))
        writeMessage(requestData)
    }
    
    private func send(id: UInt32, method: InfuraWebsocketMethod, params: [Encodable], cb: @escaping (Result<Decodable, Error>) -> Void) {
        do {
            try writeMessage(method: method, params: params)
        } catch {
            cb(.failure(error))
            return
        }
        requests[id] = cb
    }
    
    public func setFilterAndGetChanges(method: InfuraWebsocketMethod, params: [Encodable]? = nil) throws {
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
    
    public func setFilterAndGetChanges(method: InfuraWebsocketMethod, address: EthereumAddress? = nil, fromBlock: BlockNumber? = nil, toBlock: BlockNumber? = nil, topics: [String]? = nil) throws {
        let filterParams = EventFilterParameters(fromBlock: fromBlock?.stringValue, toBlock: toBlock?.stringValue, topics: [topics], address: [address?.address])
        try setFilterAndGetChanges(method: method, params: [filterParams])
    }
    
    public func setFilterAndGetLogs(method: InfuraWebsocketMethod, params: [Encodable]? = nil) throws {
        filterTimer?.invalidate()
        filterID = nil
        let params = params ?? []
        let paramsCount = params.count
        guard method.requiredNumOfParameters == paramsCount || method.requiredNumOfParameters == nil else {
            throw Web3Error.inputError(desc: "Wrong number of params: need - \(method.requiredNumOfParameters!), got - \(paramsCount)")
        }
        try writeMessage(method: method, params: params)
        filterTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(getFilterLogs), userInfo: nil, repeats: true)
    }
    
    public func setFilterAndGetLogs(method: InfuraWebsocketMethod, address: EthereumAddress? = nil, fromBlock: BlockNumber? = nil, toBlock: BlockNumber? = nil, topics: [String]? = nil) throws {
        let filterParams = EventFilterParameters(fromBlock: fromBlock?.stringValue, toBlock: toBlock?.stringValue, topics: [topics], address: [address?.address])
        try setFilterAndGetLogs(method: method, params: [filterParams])
    }
    
    @objc public func getFilterChanges() throws {
        if let id = filterID {
            filterTimer?.invalidate()
            let method = InfuraWebsocketMethod.getFilterChanges
            try writeMessage(method: method, params: [id])
        }
    }
    
    @objc public func getFilterLogs() throws {
        if let id = filterID {
            filterTimer?.invalidate()
            let method = InfuraWebsocketMethod.getFilterLogs
            try writeMessage(method: method, params: [id])
        }
    }
    
    public func getFilterLogs(address: EthereumAddress? = nil, fromBlock: BlockNumber? = nil, toBlock: BlockNumber? = nil, topics: [String]? = nil) throws {
        if let id = filterID {
            let filterParams = EventFilterParameters(fromBlock: fromBlock?.stringValue, toBlock: toBlock?.stringValue, topics: [topics], address: [address?.address])
            let method = InfuraWebsocketMethod.getFilterLogs
            try writeMessage(method: method, params: [id, filterParams])
        }
    }
    
    public func unistallFilter() throws {
        if let id = filterID {
            filterID = nil
            let method = InfuraWebsocketMethod.uninstallFilter
            try writeMessage(method: method, params: [id])
        } else {
            throw Web3Error.nodeError(desc: "No filter set")
        }
    }
    
    override public func subscribe<R>(filter: SubscribeEventFilter,
                                      listener: @escaping Web3SubscriptionListener<R>) throws -> Subscription {
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
        let method = InfuraWebsocketMethod.subscribe
        try writeMessage(method: method, params: params)
        let subscription = WebsocketSubscription(unsubscribeCallback: { subscription in
            let method = InfuraWebsocketMethod.unsubscribe
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
                    // TODO: handle error
                    fatalError("Not implemented")
                }
            }
        })
        let handler = { (result: Result<Decodable, Error>) in
            listener(result.map { $0 as! R })
        }
        send(id: newID(), method: method, params: params) { result in
            switch result {
            case .success(let data):
                let subscriptionID = data as! String
                self.subscriptions[subscriptionID] = (subscription, handler)
            case .failure(let error):
                handler(.failure(error))
            }
        }
        fatalError()
    }
    
    public func subscribeOnNewHeads() throws {
        let method = InfuraWebsocketMethod.subscribe
        let params = ["newHeads"]
        try writeMessage(method: method, params: params)
    }
    
    public func subscribeOnLogs(addresses: [EthereumAddress]? = nil, topics: [String]? = nil) throws {
        let method = InfuraWebsocketMethod.subscribe
        var stringAddresses = [String]()
        if let addrs = addresses {
            for addr in addrs {
                stringAddresses.append(addr.address)
            }
        }
//        let ts = topics == nil ? nil : [topics!]
        let filterParams = EventFilterParameters(fromBlock: nil, toBlock: nil, topics: [topics], address: stringAddresses)
        try writeMessage(method: method, params: ["logs", filterParams])
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
    
    /// override WebsocketDelegate
    override public func didReceive(event: WebSocketEvent, client: WebSocket) {
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
            delegate.received(message: data)
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
            if filterID == nil,
                let result = dictionary["result"] as? String {
                // setting filter id
                filterID = result
            } else if let id = dictionary["id"] as? UInt32 {
                if let request = requests.removeValue(forKey: id) {
                    request(.success(dictionary["result"] as! Decodable))
                }
            } else if let params = dictionary["params"] as? [String: Any],
                let subscriptionID = params["subscription"] as? String,
                let result = params["result"] {
                if let subscription = subscriptions[subscriptionID] {
                    subscription.cb(.success(result as! Decodable))
                }
                delegate.received(message: result)
            } else if let message = dictionary["result"] {
                // filter result
                delegate.received(message: message)
            } else {
                delegate.gotError(error: Web3Error.processingError(desc: "Can\'t get known result. Message is: \(text)"))
            }
        }
    }
}
