//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension TransactionOptions: Decodable {
    enum CodingKeys: String, CodingKey {
        case to
        case from
        case gasPrice
        case gas
        case value
        case nonce
        case callOnBlock
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let gasLimit = try? container.decodeHex(to: BigUInt.self, key: .gas) {
            self.gasLimit = .manual(gasLimit)
        } else {
            self.gasLimit = .automatic
        }

        if let gasPrice = try? container.decodeHex(to: BigUInt.self, key: .gasPrice) {
            self.gasPrice = .manual(gasPrice)
        } else {
            self.gasPrice = .automatic
        }

        let toString = try container.decode(String?.self, forKey: .to)
        var to: EthereumAddress?
        if toString == nil || toString == "0x" || toString == "0x0" {
            to = EthereumAddress.contractDeploymentAddress()
        } else {
            guard let addressString = toString else {throw Web3Error.dataError}
            guard let ethAddr = EthereumAddress(addressString) else {throw Web3Error.dataError}
            to = ethAddr
        }
        self.to = to
        let from = try container.decodeIfPresent(EthereumAddress.self, forKey: .to)
        //        var from: EthereumAddress?
        //        if fromString != nil {
        //            guard let ethAddr = EthereumAddress(toString) else {throw Web3Error.dataError}
        //            from = ethAddr
        //        }
        self.from = from

        self.value = try container.decodeHex(to: BigUInt.self, key: .value)

        if let nonce = try? container.decodeHex(to: BigUInt.self, key: .nonce) {
            self.nonce = .manual(nonce)
        } else {
            self.nonce = .pending
        }

        if let callOnBlock = try? container.decodeHex(to: BigUInt.self, key: .callOnBlock) {
            self.callOnBlock = .exactBlockNumber(callOnBlock)
        } else {
            self.callOnBlock = .pending
        }
    }
}

extension EthereumTransaction: Decodable {
    enum CodingKeys: String, CodingKey {
        case to
        case data
        case input
        case nonce
        case v
        case r
        case s
        case value
        case type  // present in EIP-1559 transaction objects
    }

    public init(from decoder: Decoder) throws {
        let options = try TransactionOptions(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // test to see if it is a EIP-1559 wrapper
        if let envelope = try? container.decodeHex(to: BigUInt.self, key: .type) {
            // if present and non-sero we are a new wrapper we can't decode
            if envelope != BigInt(0) { throw Web3Error.dataError }
        }

        if let data = try? container.decodeHex(to: Data.self, key: .data) {
            self.data = data
        } else {
            guard let data = try? container.decodeHex(to: Data.self, key: .input) else { throw Web3Error.dataError }
            self.data = data
        }

        nonce = try container.decodeHex(to: BigUInt.self, key: .nonce)
        v = try container.decodeHex(to: BigUInt.self, key: .v)
        r = try container.decodeHex(to: BigUInt.self, key: .r)
        s = try container.decodeHex(to: BigUInt.self, key: .s)

        guard let to = options.to,
            let gasLimit = options.gasLimit,
            let gasPrice = options.gasPrice else { throw Web3Error.dataError }

        self.to = to
        self.value = options.value

        switch gasPrice {
        case let .manual(gasPriceValue):
            self.gasPrice = gasPriceValue
        default:
            self.gasPrice = 5000000000
        }

        switch gasLimit {
        case let .manual(gasLimitValue):
            self.gasLimit = gasLimitValue
        default:
            self.gasLimit = 21000
        }

        let inferedChainID = self.inferedChainID
        if self.inferedChainID != nil && self.v >= BigUInt(37) {
            self.chainID = inferedChainID
        }
    }
}

public struct TransactionDetails: Decodable {
    public var blockHash: Data?
    public var blockNumber: BigUInt?
    public var transactionIndex: BigUInt?
    public var transaction: EthereumTransaction

    enum CodingKeys: String, CodingKey {
        case blockHash
        case blockNumber
        case transactionIndex
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.blockNumber = try? container.decodeHex(to: BigUInt.self, key: .blockNumber)
        self.blockHash = try?  container.decodeHex(to: Data.self, key: .blockHash)
        self.transactionIndex = try? container.decodeHex(to: BigUInt.self, key: .blockNumber)
        self.transaction = try EthereumTransaction(from: decoder)
    }
}

public struct TransactionReceipt: Decodable {
    public var transactionHash: Data
    public var blockHash: Data
    public var blockNumber: BigUInt
    public var transactionIndex: BigUInt
    public var contractAddress: EthereumAddress?
    public var cumulativeGasUsed: BigUInt
    public var gasUsed: BigUInt
    public var logs: [EventLog]
    public var status: TXStatus
    public var logsBloom: EthereumBloomFilter?

    public enum TXStatus {
        case ok
        case failed
        case notYetProcessed
    }

    enum CodingKeys: String, CodingKey
    {
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
    }

    static func notProcessed(transactionHash: Data) -> TransactionReceipt {
        TransactionReceipt(transactionHash: transactionHash, blockHash: Data(), blockNumber: BigUInt(0), transactionIndex: BigUInt(0), contractAddress: nil, cumulativeGasUsed: BigUInt(0), gasUsed: BigUInt(0), logs: [EventLog](), status: .notYetProcessed, logsBloom: nil)
    }
}

extension TransactionReceipt {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.blockNumber = try container.decodeHex(to: BigUInt.self, key: .blockNumber)

        self.blockHash = try container.decodeHex(to: Data.self, key: .blockHash)

        self.transactionIndex = try container.decodeHex(to: BigUInt.self, key: .transactionIndex)

        self.transactionHash = try container.decodeHex(to: Data.self, key: .transactionHash)

        self.contractAddress = try? container.decodeIfPresent(EthereumAddress.self, forKey: .contractAddress)

        self.cumulativeGasUsed = try container.decodeHex(to: BigUInt.self, key: .cumulativeGasUsed)

        self.gasUsed = try container.decodeHex(to: BigUInt.self, key: .gasUsed)

        let status = try? container.decodeHex(to: BigUInt.self, key: .status)
        switch status {
            case nil: self.status = .notYetProcessed
            case 1: self.status = .ok
            default: self.status = .failed
        }

        self.logs = try container.decode([EventLog].self, forKey: .logs)
    }
}

extension EthereumAddress: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        self.init(stringValue)!
    }

    public func encode(to encoder: Encoder) throws {
        let value = self.address.lowercased()
        var signleValuedCont = encoder.singleValueContainer()
        try signleValuedCont.encode(value)
    }
}

public struct EventLog : Decodable {
    public var address: EthereumAddress
    public var blockHash: Data
    public var blockNumber: BigUInt
    public var data: Data
    public var logIndex: BigUInt
    public var removed: Bool
    public var topics: [Data]
    public var transactionHash: Data
    public var transactionIndex: BigUInt


//    address = 0x53066cddbc0099eb6c96785d9b3df2aaeede5da3;
//    blockHash = 0x779c1f08f2b5252873f08fd6ec62d75bb54f956633bbb59d33bd7c49f1a3d389;
//    blockNumber = 0x4f58f8;
//    data = 0x0000000000000000000000000000000000000000000000004563918244f40000;
//    logIndex = 0x84;
//    removed = 0;
//    topics =     (
//    0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef,
//    0x000000000000000000000000efdcf2c36f3756ce7247628afdb632fa4ee12ec5,
//    0x000000000000000000000000d5395c132c791a7f46fa8fc27f0ab6bacd824484
//    );
//    transactionHash = 0x9f7bb2633abb3192d35f65e50a96f9f7ca878fa2ee7bf5d3fca489c0c60dc79a;
//    transactionIndex = 0x99;

    enum CodingKeys: String, CodingKey
    {
        case address
        case blockHash
        case blockNumber
        case data
        case logIndex
        case removed
        case topics
        case transactionHash
        case transactionIndex
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let address = try container.decode(EthereumAddress.self, forKey: .address)
        self.address = address

        self.blockNumber = try container.decodeHex(to: BigUInt.self, key: .blockNumber)

        self.blockHash = try container.decodeHex(to: Data.self, key: .blockHash)

        self.transactionIndex = try container.decodeHex(to: BigUInt.self, key: .transactionIndex)

        self.transactionHash = try container.decodeHex(to: Data.self, key: .transactionHash)

        self.data = try container.decodeHex(to: Data.self, key: .data)

        self.logIndex = try container.decodeHex(to: BigUInt.self, key: .logIndex)

        let removed = try? container.decodeHex(to: BigUInt.self, key: .removed)
        self.removed = removed == 1 ? true : false

        let topicsStrings = try container.decode([String].self, forKey: .topics)

        self.topics = try topicsStrings.map {
            guard let topic = Data.fromHex($0) else { throw Web3Error.dataError }
            return topic
        }
    }
}

public enum TransactionInBlock: Decodable {
    case hash(Data)
    case transaction(EthereumTransaction)
    case null

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        if let string = try? value.decode(String.self) {
            guard let d = Data.fromHex(string) else {throw Web3Error.dataError}
            self = .hash(d)
        } else if let transaction = try? value.decode(EthereumTransaction.self) {
            self = .transaction(transaction)
        } else {
            self = .null
        }
    }
}

/// Ethereum Block
///
/// Official specification: [](https://github.com/ethereum/execution-apis/blob/main/src/schemas/block.json)
public struct Block: Decodable {

    public var number: BigUInt // MARK: This is optional in web3js, but required in Ethereum JSON-RPC
    public var hash: Data // MARK: This is optional in web3js, but required in Ethereum JSON-RPC
    public var parentHash: Data
    public var nonce: Data? // MARK: This is optional in web3js but required in Ethereum JSON-RPC
    public var sha3Uncles: Data
    public var logsBloom: EthereumBloomFilter? = nil // MARK: This is optional in web3js but required in Ethereum JSON-RPC
    public var transactionsRoot: Data
    public var stateRoot: Data
    public var receiptsRoot: Data
    public var miner: EthereumAddress? = nil // MARK: This is NOT optional in web3js
    public var difficulty: BigUInt
    public var totalDifficulty: BigUInt
    public var extraData: Data
    public var size: BigUInt
    public var gasLimit: BigUInt
    public var gasUsed: BigUInt
    public var baseFeePerGas: BigUInt
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

extension Block {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.number = try container.decodeHex(to: BigUInt.self, key: .number)
        self.hash = try container.decodeHex(to: Data.self, key: .hash)
        self.parentHash = try container.decodeHex(to: Data.self, key: .parentHash)
        self.nonce = try? container.decodeHex(to: Data.self, key: .nonce)
        self.sha3Uncles = try container.decodeHex(to: Data.self, key: .sha3Uncles)

        if let logsBloomData = try? container.decodeHex(to: Data.self, key: .logsBloom) {
            self.logsBloom = EthereumBloomFilter(logsBloomData)
        }

        self.transactionsRoot = try container.decodeHex(to: Data.self, key: .transactionsRoot)
        self.stateRoot = try container.decodeHex(to: Data.self, key: .stateRoot)
        self.receiptsRoot = try container.decodeHex(to: Data.self, key: .receiptsRoot)

        if let minerAddress = try? container.decode(String.self, forKey: .miner) {
            self.miner = EthereumAddress(minerAddress)
        }

        self.difficulty = try container.decodeHex(to: BigUInt.self, key: .difficulty)
        self.totalDifficulty = try container.decodeHex(to: BigUInt.self, key: .totalDifficulty)
        self.extraData = try container.decodeHex(to: Data.self, key: .extraData)
        self.size = try container.decodeHex(to: BigUInt.self, key: .size)
        self.gasLimit = try container.decodeHex(to: BigUInt.self, key: .gasLimit)
        self.gasUsed = try container.decodeHex(to: BigUInt.self, key: .gasUsed)
        self.baseFeePerGas = try container.decodeHex(to: BigUInt.self, key: .baseFeePerGas)

        self.timestamp = try container.decodeHex(to: Date.self, key: .timestamp)

        self.transactions = try container.decode([TransactionInBlock].self, forKey: .transactions)

        let unclesStrings = try container.decode([String].self, forKey: .uncles)
        self.uncles = try unclesStrings.map {
            guard let data = Data.fromHex($0) else { throw Web3Error.dataError }
            return data
        }
    }
}

public struct EventParserResult:EventParserResultProtocol {
    public var eventName: String
    public var transactionReceipt: TransactionReceipt?
    public var contractAddress: EthereumAddress
    public var decodedResult: [String:Any]
    public var eventLog: EventLog? = nil
}

public struct TransactionSendingResult {
    public var transaction: EthereumTransaction
    public var hash: String
}

public struct TxPoolStatus : Decodable {
    public var pending: BigUInt
    public var queued: BigUInt

    enum CodingKeys: String, CodingKey {
        case pending
        case queued
    }
}

public extension TxPoolStatus {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pending = try container.decodeHex(to: BigUInt.self, key: .pending)
        self.queued = try container.decodeHex(to: BigUInt.self, key: .queued)
    }
}

public struct TxPoolContent : Decodable {
    public var pending: [EthereumAddress: [TxPoolContentForNonce]]
    public var queued: [EthereumAddress: [TxPoolContentForNonce]]

    enum CodingKeys: String, CodingKey {
        case pending
        case queued
    }

    fileprivate static func decodePoolContentForKey<T>(container: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key) throws -> [EthereumAddress: [TxPoolContentForNonce]] {
        let raw = try container.nestedContainer(keyedBy: AdditionalDataCodingKeys.self, forKey: key)
        var result = [EthereumAddress: [TxPoolContentForNonce]]()
        for addressKey in raw.allKeys {
            let addressString = addressKey.stringValue
            guard let address = EthereumAddress(addressString, type: .normal, ignoreChecksum: true) else {
                throw Web3Error.dataError
            }
            let nestedContainer = try raw.nestedContainer(keyedBy: AdditionalDataCodingKeys.self, forKey: addressKey)
            var perNonceInformation = [TxPoolContentForNonce]()
            perNonceInformation.reserveCapacity(nestedContainer.allKeys.count)
            for nonceKey in nestedContainer.allKeys {
                guard let nonce = BigUInt(nonceKey.stringValue) else {
                    throw Web3Error.dataError
                }
                let n = try? nestedContainer.nestedUnkeyedContainer(forKey: nonceKey)
                if n != nil {
                    let details = try nestedContainer.decode([TransactionDetails].self, forKey: nonceKey)
                    let content = TxPoolContentForNonce(nonce: nonce, details: details)
                    perNonceInformation.append(content)
                } else {
                    let detail = try nestedContainer.decode(TransactionDetails.self, forKey: nonceKey)
                    let content = TxPoolContentForNonce(nonce: nonce, details: [detail])
                    perNonceInformation.append(content)
                }
            }
            result[address] = perNonceInformation
        }
        return result
    }


    fileprivate struct AdditionalDataCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
}

extension TxPoolContent {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pending = try TxPoolContent.decodePoolContentForKey(container: container, key: .pending)
        self.queued = try TxPoolContent.decodePoolContentForKey(container: container, key: .queued)
    }
}

public struct TxPoolContentForNonce {
    public var nonce: BigUInt
    public var details: [TransactionDetails]
}
