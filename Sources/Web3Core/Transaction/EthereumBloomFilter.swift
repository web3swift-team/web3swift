//
//  EthereumBloomFilter.swift
//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift

/// A wrapper around a set of bytes that represent a Bloom filter.
/// Similar implementation in Go language can be found [here in bloom9.go](https://github.com/ethereum/go-ethereum/blob/master/core/types/bloom9.go).
///
/// Bloom filter is used to reduce the cost in terms of memory consumption during the process of searching
/// Bloom filter can be calculated for any set of data. In case of Ethereum blockchain it could be a set of addresses, event topics  etc.
///
/// A definition of [Bloom filter](https://en.wikipedia.org/wiki/Bloom_filter#:~:text=A%20Bloom%20filter%20is%20a,a%20member%20of%20a%20set.).
public struct EthereumBloomFilter {
    static let mask = BigUInt(2047)
    /// Bloom filter.
    public var bytes = Data(repeatElement(UInt8(0), count: 256))
    public init?(_ biguint: BigUInt) {
        guard let data = biguint.serialize().setLengthLeft(256) else { return nil }
        bytes = data
    }
    public init() {}
    public init(_ data: Data) {
        let padding = Data(repeatElement(UInt8(0), count: 256 - data.count))
        bytes = padding + data
    }
    public func asBigUInt() -> BigUInt {
        BigUInt(bytes)
    }
}

extension EthereumBloomFilter {

    // MARK: - Bloom filter calculation functions
    /// Calculates Bloom filter from Keccak-256 calculated from given `number`.
    /// - Parameter number: some number to calculate filter from.
    /// - Returns: Bloom filter.
    static func bloom9(_ number: BigUInt) -> BigUInt {
        bloom9(number.serialize())
    }

    /// Calculates Bloom filter from Keccak-256 calculated from given `data`.
    /// - Parameter data: some data to calculate filter from, e.g. event's topic or address of a smart contract.
    /// - Returns: Bloom filter.
    static func bloom9(_ data: Data) -> BigUInt {
        // TODO: update to match this implementation https://manbytesgnu.com/eth-log-bloom.html
        // TODO: it will increase performance.
        let b = data.sha3(.keccak256)
        var result = BigUInt(1) <<
            ((BigUInt(b[1]) + (BigUInt(b[0]) << 8)) & EthereumBloomFilter.mask)
        var nextPoint = BigUInt(1) <<
            ((BigUInt(b[3]) + (BigUInt(b[2]) << 8)) & EthereumBloomFilter.mask)
        result = result | nextPoint
        nextPoint = BigUInt(1) <<
            ((BigUInt(b[5]) + (BigUInt(b[4]) << 8)) & EthereumBloomFilter.mask)
        return result | nextPoint
    }

    // MARK: - Bloom filter match functions
    public static func bloomLookup(_ bloom: EthereumBloomFilter, topic: Data) -> Bool {
        bloom.test(topic: topic)
    }

    public static func bloomLookup(_ bloom: EthereumBloomFilter, topic: BigUInt) -> Bool {
        EthereumBloomFilter.bloomLookup(bloom, topic: topic.serialize())
    }

    /// Check if topic is in the bloom filter.
    /// - Parameter topic: topic of an event as bytes;
    /// - Returns: `true` if topic is possibly in set, `false` if definitely not in set.
    public func test(topic: Data) -> Bool {
        let bin = asBigUInt()
        let comparison = EthereumBloomFilter.bloom9(topic)
        return bin & comparison == comparison
    }

    /// Check if topic is in the bloom filter.
    /// - Parameter topic: topic of an event in `BigUInt`;
    /// - Returns: `true` if topic is possibly in set, `false` if definitely not in set.
    public func test(topic: BigUInt) -> Bool {
        test(topic: topic.serialize())
    }

    public func lookup(_ topic: Data) -> Bool {
        EthereumBloomFilter.bloomLookup(self, topic: topic)
    }

    // MARK: - Create Bloom filter from a list of logs
    /// Creates a bloom filter from ``EventLog/address`` and ``EventLog/topics``.
    /// - Parameter logs: event logs to create filter from.
    /// - Returns: calculated bloom filter represented as `BigUInt`.
    public static func logsToBloom(_ logs: [EventLog]) -> BigUInt {
        var bin = BigUInt(0)
        for log in logs {
            bin = bin | bloom9(log.address.addressData)
            for topic in log.topics {
                bin = bin | bloom9(topic)
            }
        }
        return bin
    }

    /// Creates a bloom filter from arrays of logs from each ``TransactionReceipt``.
    /// ``TransactionReceipt/logs`` from each entry in `receipts` array are combined to create a bloom filter
    /// using ``EthereumBloomFilter/logsToBloom(_:)``.
    /// - Parameter receipts: an array of receipts to create bloom filter from.
    /// - Returns: bloom filter.
    public static func createBloom(_ receipts: [TransactionReceipt]) -> EthereumBloomFilter {
        var bin = BigUInt(0)
        for receipt in receipts {
            bin = bin | logsToBloom(receipt.logs)
        }
        return EthereumBloomFilter(bin)!
    }

    // MARK: - Mutating functions
    public mutating func add(_ biguint: BigUInt) {
        let newBloomFilter = asBigUInt() | EthereumBloomFilter.bloom9(biguint)
        setBytes(newBloomFilter.serialize())
    }

    public mutating func add(_ data: Data) {
        let newBloomFilter = asBigUInt() | EthereumBloomFilter.bloom9(data)
        setBytes(newBloomFilter.serialize())
    }

    mutating func setBytes(_ data: Data) {
        if bytes.count < data.count {
            fatalError("bloom bytes are too big")
        }
        bytes = bytes[0 ..< data.count] + data
    }
}
