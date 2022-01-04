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
    private var filterTimer: Timer?
    
    public init?(_ network: Networks,
                 delegate: Web3SocketDelegate? = nil,
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
                 delegate: Web3SocketDelegate? = nil,
                 projectId: String? = nil) {
        guard URL(string: endpoint) != nil else {return nil}
        super.init(endpoint,
                   delegate: delegate,
                   projectId: projectId)
    }
    
    public init?(_ endpoint: URL,
                 delegate: Web3SocketDelegate? = nil,
                 projectId: String? = nil) {
        super.init(endpoint,
                   delegate: delegate,
                   projectId: projectId)
    }
    
    override public class func connectToSocket(_ endpoint: String,
                                               delegate: Web3SocketDelegate? = nil,
                                               projectId: String? = nil,
                                               network net: Networks? = nil) -> WebsocketProvider? {
        guard let socketProvider = InfuraWebsocketProvider(endpoint,
                                                           delegate: delegate,
                                                           projectId: projectId) else {return nil}
        socketProvider.connectSocket()
        return socketProvider
    }
    
    override public class func connectToSocket(_ endpoint: URL,
                                               delegate: Web3SocketDelegate? = nil,
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
    
    public func setFilterAndGetChanges(method: WebsocketMethod, params: [Encodable]? = nil) throws {
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
    
    public func setFilterAndGetChanges(method: WebsocketMethod, address: EthereumAddress? = nil, fromBlock: BlockNumber? = nil, toBlock: BlockNumber? = nil, topics: [String]? = nil) throws {
        let filterParams = EventFilterParameters(fromBlock: fromBlock?.stringValue, toBlock: toBlock?.stringValue, topics: [topics], address: [address?.address])
        try setFilterAndGetChanges(method: method, params: [filterParams])
    }
    
    public func setFilterAndGetLogs(method: WebsocketMethod, params: [Encodable]? = nil) throws {
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
    
    public func setFilterAndGetLogs(method: WebsocketMethod, address: EthereumAddress? = nil, fromBlock: BlockNumber? = nil, toBlock: BlockNumber? = nil, topics: [String]? = nil) throws {
        let filterParams = EventFilterParameters(fromBlock: fromBlock?.stringValue, toBlock: toBlock?.stringValue, topics: [topics], address: [address?.address])
        try setFilterAndGetLogs(method: method, params: [filterParams])
    }
    
    @objc public func getFilterChanges() throws {
        if let id = filterID {
            filterTimer?.invalidate()
            let method = WebsocketMethod.getFilterChanges
            try writeMessage(method: method, params: [id])
        }
    }
    
    @objc public func getFilterLogs() throws {
        if let id = filterID {
            filterTimer?.invalidate()
            let method = WebsocketMethod.getFilterLogs
            try writeMessage(method: method, params: [id])
        }
    }
    
    public func getFilterLogs(address: EthereumAddress? = nil, fromBlock: BlockNumber? = nil, toBlock: BlockNumber? = nil, topics: [String]? = nil) throws {
        if let id = filterID {
            let filterParams = EventFilterParameters(fromBlock: fromBlock?.stringValue, toBlock: toBlock?.stringValue, topics: [topics], address: [address?.address])
            let method = WebsocketMethod.getFilterLogs
            try writeMessage(method: method, params: [id, filterParams])
        }
    }
    
    public func unistallFilter() throws {
        if let id = filterID {
            filterID = nil
            let method = WebsocketMethod.uninstallFilter
            try writeMessage(method: method, params: [id])
        } else {
            throw Web3Error.nodeError(desc: "No filter set")
        }
    }
    
    public func subscribeOnNewHeads() throws {
        let method = WebsocketMethod.subscribe
        let params = ["newHeads"]
        try writeMessage(method: method, params: params)
    }
    
    public func subscribeOnLogs(addresses: [EthereumAddress]? = nil, topics: [String]? = nil) throws {
        let method = WebsocketMethod.subscribe
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
        let method = WebsocketMethod.subscribe
        let params = ["newPendingTransactions"]
        try writeMessage(method: method, params: params)
    }
    
    public func subscribeOnSyncing() throws {
        guard network != Networks.Kovan else {
            throw Web3Error.inputError(desc: "Can't sync on Kovan")
        }
        let method = WebsocketMethod.subscribe
        let params = ["syncing"]
        try writeMessage(method: method, params: params)
    }
}
