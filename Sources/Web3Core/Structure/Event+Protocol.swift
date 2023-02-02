//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

// FIXME: Make me work or delete
/// Protocol for generic Ethereum event parsing results
public protocol EventParserResultProtocol {
    var eventName: String {get}
    var decodedResult: [String: Any] {get}
    var contractAddress: EthereumAddress {get}
    var transactionReceipt: TransactionReceipt? {get}
    var eventLog: EventLog? {get}
}

public struct EventParserResult: EventParserResultProtocol {
    public var eventName: String
    public var transactionReceipt: TransactionReceipt?
    public var contractAddress: EthereumAddress
    public var decodedResult: [String: Any]
    public var eventLog: EventLog?

    public init(eventName: String, transactionReceipt: TransactionReceipt? = nil, contractAddress: EthereumAddress, decodedResult: [String: Any], eventLog: EventLog? = nil) {
        self.eventName = eventName
        self.transactionReceipt = transactionReceipt
        self.contractAddress = contractAddress
        self.decodedResult = decodedResult
        self.eventLog = eventLog
    }
}

/// Protocol for generic Ethereum event parser
public protocol EventParserProtocol {
    func parseTransaction(_ transaction: CodableTransaction) async throws -> [EventParserResultProtocol]
    func parseTransactionByHash(_ hash: Data) async throws -> [EventParserResultProtocol]
    func parseBlock(_ block: Block) async throws -> [EventParserResultProtocol]
    func parseBlockByNumber(_ blockNumber: BigUInt) async throws -> [EventParserResultProtocol]
    func parseTransactionPromise(_ transaction: CodableTransaction) async throws -> [EventParserResultProtocol]
    func parseTransactionByHashPromise(_ hash: Data) async throws -> [EventParserResultProtocol]
    func parseBlockByNumberPromise(_ blockNumber: BigUInt) async throws -> [EventParserResultProtocol]
    func parseBlockPromise(_ block: Block) async throws -> [EventParserResultProtocol]
}

/// Enum for the most-used Ethereum networks. Network ID is crucial for EIP155 support
public enum Networks {
    case Goerli
    case Rinkeby
    case Mainnet
    case Ropsten
    case Kovan
    case Custom(networkID: BigUInt)

    public var name: String {
        switch self {
        case .Goerli: return "goerli"
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
        case .Goerli: return BigUInt(5)
        case .Kovan: return BigUInt(42)
        }
    }

    static let allValues = [Mainnet, Ropsten, Kovan, Rinkeby]

    public static func fromInt(_ networkID: UInt) -> Networks {
        switch networkID {
        case 1:
            return Networks.Mainnet
        case 3:
            return Networks.Ropsten
        case 4:
            return Networks.Rinkeby
        case 5:
            return Networks.Goerli
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
    func functionToRun() async
}
