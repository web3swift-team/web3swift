//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import class PromiseKit.Promise

/// Protocol for generic Ethereum event parsing results
public protocol EventParserResultProtocol {
    var eventName: String {get}
    var decodedResult: [String: Any] {get}
    var contractAddress: EthereumAddress {get}
    var transactionReceipt: TransactionReceipt? {get}
    var eventLog: EventLog? {get}
}

/// Protocol for generic Ethereum event parser
public protocol EventParserProtocol {
    func parseTransaction(_ transaction: EthereumTransaction) throws -> [EventParserResultProtocol]
    func parseTransactionByHash(_ hash: Data) throws -> [EventParserResultProtocol]
    func parseBlock(_ block: Block) throws -> [EventParserResultProtocol]
    func parseBlockByNumber(_ blockNumber: UInt64) throws -> [EventParserResultProtocol]
    func parseTransactionPromise(_ transaction: EthereumTransaction) -> Promise<[EventParserResultProtocol]>
    func parseTransactionByHashPromise(_ hash: Data) -> Promise<[EventParserResultProtocol]>
    func parseBlockByNumberPromise(_ blockNumber: UInt64) -> Promise<[EventParserResultProtocol]>
    func parseBlockPromise(_ block: Block) -> Promise<[EventParserResultProtocol]>
}

/// Enum for the most-used Ethereum networks. Network ID is crucial for EIP155 support
public enum Networks {
    case Rinkeby
    case Mainnet
    case Ropsten
    case Kovan
    case Custom(networkID: BigUInt)

    public var name: String {
        switch self {
        case .Rinkeby: return "rinkeby"
        case .Ropsten: return "ropsten"
        case .Mainnet: return "mainnet"
        case .Kovan: return "kovan"
        case .Custom: return ""
        }
    }

    public var chainID: BigUInt {
        switch self {
        case .Custom(let networkID): return networkID
        case .Mainnet: return BigUInt(1)
        case .Ropsten: return BigUInt(3)
        case .Rinkeby: return BigUInt(4)
        case .Kovan: return BigUInt(42)
        }
    }

    static let allValues = [Mainnet, Ropsten, Kovan, Rinkeby]

    static func fromInt(_ networkID: Int) -> Networks? {
        switch networkID {
        case 1:
            return Networks.Mainnet
        case 3:
            return Networks.Ropsten
        case 4:
            return Networks.Rinkeby
        case 42:
            return Networks.Kovan
        default:
            return Networks.Custom(networkID: BigUInt(networkID))
        }
    }
}

extension Networks: Equatable {
    public static func ==(lhs: Networks, rhs: Networks) -> Bool {
        return lhs.chainID == rhs.chainID
            && lhs.name == rhs.name
    }
}

public protocol EventLoopRunnableProtocol {
    var name: String {get}
    var queue: DispatchQueue {get}
    func functionToRun()
}
