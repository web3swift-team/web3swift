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
    public init(_ net:Networks, accessToken token: String? = nil, keystoreManager manager: KeystoreManager? = nil) throws {
        var requestURLstring = "https://" + net.name + Constants.infuraHttpScheme
        requestURLstring += token ?? Constants.infuraToken
        guard let providerURL = URL(string: requestURLstring) else {
            throw Web3Error.connectionError
        }
        try super.init(providerURL, network: net, keystoreManager: manager)
    }
}

/// Custom Websocket provider of Infura nodes.
public final class InfuraWebsocketProvider: WebsocketProvider {
    public var filterID: String?
    public var subscriptionIDs = Set<String>()
    private var subscriptionIDforUnsubscribing: String? = nil
    private var filterTimer: Timer?
    
    /// if set debugMode True then show websocket events logs in the console
    public var debugMode: Bool = false
    
    public init(_ network: Networks,
                 delegate: Web3SocketDelegate,
                 projectId: String? = nil,
                 keystoreManager manager: KeystoreManager? = nil) throws {
        guard network == Networks.Kovan
            || network == Networks.Rinkeby
            || network == Networks.Ropsten
                || network == Networks.Mainnet else {throw Web3Error.connectionError}
        let networkName = network.name
        let urlString = "wss://" + networkName + Constants.infuraWsScheme
        guard URL(string: urlString) != nil else {throw Web3Error.connectionError}
        try super.init(urlString,
                   delegate: delegate,
                   projectId: projectId,
                   keystoreManager: manager,
                   network: network)
    }
    
    public init(_ endpoint: String,
                 delegate: Web3SocketDelegate,
                 projectId: String? = nil,
                 keystoreManager manager: KeystoreManager? = nil) throws {
        guard URL(string: endpoint) != nil else {throw Web3Error.connectionError}
        try super.init(endpoint,
                   delegate: delegate,
                   projectId: projectId,
                   keystoreManager: manager)
    }
    
    public init(_ endpoint: URL,
                 delegate: Web3SocketDelegate,
                 projectId: String? = nil,
                 keystoreManager manager: KeystoreManager? = nil) throws {
        try super.init(endpoint,
                   delegate: delegate,
                   projectId: projectId,
                   keystoreManager: manager)
    }
    
    override public class func connectToSocket(_ endpoint: String,
                                               delegate: Web3SocketDelegate,
                                               projectId: String? = nil,
                                               keystoreManager manager: KeystoreManager? = nil,
                                               network net: Networks? = nil) -> WebsocketProvider? {
        guard let socketProvider = try? InfuraWebsocketProvider(endpoint,
                                                           delegate: delegate,
                                                           projectId: projectId,
                                                           keystoreManager: manager) else {return nil}
        socketProvider.connectSocket()
        return socketProvider
    }
    
    override public class func connectToSocket(_ endpoint: URL,
                                               delegate: Web3SocketDelegate,
                                               projectId: String? = nil,
                                               keystoreManager manager: KeystoreManager? = nil,
                                               network net: Networks? = nil) -> WebsocketProvider? {
        guard let socketProvider = try? InfuraWebsocketProvider(endpoint,
                                                           delegate: delegate,
                                                           projectId: projectId,
                                                           keystoreManager: manager) else {return nil}
        socketProvider.connectSocket()
        return socketProvider
    }
    
    public static func connectToInfuraSocket(_ network: Networks,
                                             delegate: Web3SocketDelegate,
                                             projectId: String? = nil,
                                             keystoreManager manager: KeystoreManager? = nil) -> InfuraWebsocketProvider? {
        guard let socketProvider = try? InfuraWebsocketProvider(network,
                                                           delegate: delegate,
                                                           projectId: projectId,
                                                           keystoreManager: manager) else {return nil}
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
    
    public func setFilterAndGetChanges(method: InfuraWebsocketMethod, params: [Encodable]? = nil) throws {
        filterTimer?.invalidate()
        filterID = nil
        let params = params ?? []
        let paramsCount = params.count
        guard method.requiredNumOfParameters == paramsCount || method.requiredNumOfParameters == nil else {
            throw Web3Error.inputError(desc: "Wrong number of params: need - \(method.requiredNumOfParameters ?? 0), got - \(paramsCount)")
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
            throw Web3Error.inputError(desc: "Wrong number of params: need - \(method.requiredNumOfParameters ?? 0), got - \(paramsCount)")
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
    
    public func subscribeOnLogs(addresses: [EthereumAddress]? = nil, topics: [String]? = nil) throws {
        let method = InfuraWebsocketMethod.subscribe
        var stringAddresses = [String]()
        if let addrs = addresses {
            for addr in addrs {
                stringAddresses.append(addr.address)
            }
        }
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
            if let error = error {
                delegate.gotError(error: error)
            }
        }
    }
    
    private func websocketDidReceiveMessage(text: String) {
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
