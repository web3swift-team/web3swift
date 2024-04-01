//
//  Block.swift
//
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation
import BigInt

/// Ethereum Block
///
/// Official specification: [](https://github.com/ethereum/execution-apis/blob/main/src/schemas/block.json)
public struct Block {

    public var number: BigUInt // MARK: This is optional in web3js, but required in Ethereum JSON-RPC
    public var hash: Data // MARK: This is optional in web3js, but required in Ethereum JSON-RPC
    public var parentHash: Data
    public var nonce: Data? // MARK: This is optional in web3js but required in Ethereum JSON-RPC
    public var sha3Uncles: Data
    public var logsBloom: EthereumBloomFilter? // MARK: This is optional in web3js but required in Ethereum JSON-RPC
    public var transactionsRoot: Data
    public var stateRoot: Data
    public var receiptsRoot: Data
    public var miner: EthereumAddress? // MARK: This is NOT optional in web3js
    public var difficulty: BigUInt
    public var totalDifficulty: BigUInt
    public var extraData: Data
    public var size: BigUInt
    public var gasLimit: BigUInt
    public var gasUsed: BigUInt
    public var baseFeePerGas: BigUInt?
    public var timestamp: Date
    public var transactions: [TransactionInBlock]
    public var uncles: [Data]

    enum CodingKeys: String, CodingKey {
        case number
        case hash
        case parentHash
        case nonce
        case sha3Uncles
        case logsBloom
        case transactionsRoot
        case stateRoot
        case receiptsRoot
        case miner
        case difficulty
        case totalDifficulty
        case extraData
        case size

        case gasLimit
        case gasUsed
        case baseFeePerGas

        case timestamp
        case transactions
        case uncles
    }
}

extension Block: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.number = try container.decodeHex(BigUInt.self, forKey: .number)
        self.hash = try container.decodeHex(Data.self, forKey: .hash)
        self.parentHash = try container.decodeHex(Data.self, forKey: .parentHash)
        self.nonce = try? container.decodeHex(Data.self, forKey: .nonce)
        self.sha3Uncles = try container.decodeHex(Data.self, forKey: .sha3Uncles)

        if let logsBloomData = try? container.decodeHex(Data.self, forKey: .logsBloom) {
            self.logsBloom = EthereumBloomFilter(logsBloomData)
        }

        self.transactionsRoot = try container.decodeHex(Data.self, forKey: .transactionsRoot)
        self.stateRoot = try container.decodeHex(Data.self, forKey: .stateRoot)
        self.receiptsRoot = try container.decodeHex(Data.self, forKey: .receiptsRoot)

        if let minerAddress = try? container.decode(String.self, forKey: .miner) {
            self.miner = EthereumAddress(minerAddress)
        }

        self.difficulty = try container.decodeHex(BigUInt.self, forKey: .difficulty)
        self.totalDifficulty = try container.decodeHex(BigUInt.self, forKey: .totalDifficulty)
        self.extraData = try container.decodeHex(Data.self, forKey: .extraData)
        self.size = try container.decodeHex(BigUInt.self, forKey: .size)
        self.gasLimit = try container.decodeHex(BigUInt.self, forKey: .gasLimit)
        self.gasUsed = try container.decodeHex(BigUInt.self, forKey: .gasUsed)

        // optional, since pre EIP-1559 block haven't such property.
        self.baseFeePerGas = try? container.decodeHex(BigUInt.self, forKey: .baseFeePerGas)

        self.timestamp = try container.decodeHex(Date.self, forKey: .timestamp)

        self.transactions = try container.decode([TransactionInBlock].self, forKey: .transactions)

        let unclesStrings = try container.decode([String].self, forKey: .uncles)
        self.uncles = try unclesStrings.map {
            guard let data = Data.fromHex($0) else { throw Web3Error.dataError }
            return data
        }
    }
}

extension Block: APIResultType { }
