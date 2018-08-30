//
//  Web3+Protocols.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import Result
import class PromiseKit.Promise

/// Protocol for generic Ethereum event parsing results
public protocol EventParserResultProtocol {
    var eventName: String {get}
    var decodedResult: [String:Any] {get}
    var contractAddress: EthereumAddress {get}
    var transactionReceipt: TransactionReceipt? {get}
    var eventLog: EventLog? {get}
}

/// Protocol for generic Ethereum event parser
public protocol EventParserProtocol {
    func parseTransaction(_ transaction: EthereumTransaction) -> Result<[EventParserResultProtocol], Web3Error>
    func parseTransactionByHash(_ hash: Data) -> Result<[EventParserResultProtocol], Web3Error>
    func parseBlock(_ block: Block) -> Result<[EventParserResultProtocol], Web3Error>
    func parseBlockByNumber(_ blockNumber: UInt64) -> Result<[EventParserResultProtocol], Web3Error>
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
    
    var name: String {
        switch self {
        case .Rinkeby: return "rinkeby"
        case .Ropsten: return "ropsten"
        case .Mainnet: return "mainnet"
        case .Kovan: return "kovan"
        case .Custom: return ""
        }
    }
    
    var chainID: BigUInt {
        switch self {
        case .Custom(let networkID): return networkID
        case .Mainnet: return BigUInt(1)
        case .Ropsten: return BigUInt(3)
        case .Rinkeby: return BigUInt(4)
        case .Kovan: return BigUInt(42)
        }
    }
    
    static let allValues = [Mainnet, Ropsten, Kovan, Rinkeby]
    
    static func fromInt(_ networkID:Int) -> Networks? {
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
