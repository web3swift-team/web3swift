//
//  Web3+Structures.swift
//  Alamofire
//
//  Created by Alexander Vlasov on 26.12.2017.
//

import Foundation
import BigInt

public struct TransactionDetails {
    public var hash: String
    public var nonce: BigUInt
    public var blockHash: String?
    public var blockNumber: BigUInt?
    public var transactionIndex: BigUInt?
    public var from: EthereumAddress
    public var to: EthereumAddress
    public var value: BigUInt
    public var gas: BigUInt
    public var gasPrice: BigUInt
    public var input: Data
}

public struct TransactionReceipt {
    public var hash: String
    public var nonce: BigUInt
    public var blockHash: String?
    public var blockNumber: BigUInt?
    public var transactionIndex: BigUInt?
    public var contractAddress: EthereumAddress
    public var cumulativeGasUsed: BigUInt
    public var gasUsed: BigUInt
    public var logs: [Data] = [Data]()
    public var status: TXStatus
    public var transactionHash: String {
        return self.hash
    }
    public enum TXStatus {
        case ok
        case failed
    }
}
