//
//  TransactionReceipt.swift
//
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation
import BigInt

public struct TransactionReceipt {
    public var transactionHash: Data
    public var blockHash: Data
    public var blockNumber: BigUInt
    public var transactionIndex: BigUInt
    public var contractAddress: EthereumAddress?
    public var cumulativeGasUsed: BigUInt
    public var gasUsed: BigUInt
    public var effectiveGasPrice: BigUInt
    public var logs: [EventLog]
    public var status: TXStatus
    public var logsBloom: EthereumBloomFilter?

    static func notProcessed(transactionHash: Data) -> TransactionReceipt {
        TransactionReceipt(transactionHash: transactionHash, blockHash: Data(), blockNumber: 0, transactionIndex: 0, contractAddress: nil, cumulativeGasUsed: 0, gasUsed: 0, effectiveGasPrice: 0, logs: [], status: .notYetProcessed, logsBloom: nil)
    }
}

extension TransactionReceipt {
    public enum TXStatus {
        case ok
        case failed
        case notYetProcessed
    }
}

extension TransactionReceipt: Decodable {
    enum CodingKeys: String, CodingKey {
        case blockHash
        case blockNumber
        case transactionHash
        case transactionIndex
        case contractAddress
        case cumulativeGasUsed
        case gasUsed
        case logs
        case logsBloom
        case status
        case effectiveGasPrice
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.blockNumber = try container.decodeHex(BigUInt.self, forKey: .blockNumber)

        self.blockHash = try container.decodeHex(Data.self, forKey: .blockHash)

        self.transactionIndex = try container.decodeHex(BigUInt.self, forKey: .transactionIndex)

        self.transactionHash = try container.decodeHex(Data.self, forKey: .transactionHash)

        self.contractAddress = try? container.decodeIfPresent(EthereumAddress.self, forKey: .contractAddress)

        self.cumulativeGasUsed = try container.decodeHex(BigUInt.self, forKey: .cumulativeGasUsed)

        self.gasUsed = try container.decodeHex(BigUInt.self, forKey: .gasUsed)

        self.effectiveGasPrice = (try? container.decodeHex(BigUInt.self, forKey: .effectiveGasPrice)) ?? 0

        let status = try? container.decodeHex(BigUInt.self, forKey: .status)
        switch status {
        case nil: self.status = .notYetProcessed
        case 1: self.status = .ok
        default: self.status = .failed
        }

        self.logs = try container.decode([EventLog].self, forKey: .logs)

        if let hexBytes = try? container.decodeHex(Data.self, forKey: .logsBloom) {
            self.logsBloom = EthereumBloomFilter(hexBytes)
        }
    }
}

extension TransactionReceipt: APIResultType { }
