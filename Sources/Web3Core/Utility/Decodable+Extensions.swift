//
//  DecodingContainer+AnyCollection.swift
//  AnyDecodable
//
//  Created by levantAJ on 1/18/19.
//  Copyright © 2019 levantAJ. All rights reserved.
//
import BigInt
import Foundation

struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }
}

extension KeyedDecodingContainer {
    /// Decodes a value of the given key from Hex to `DecodableFromHex`
    ///
    /// Currently this method supports only `Data.Type`, `BigUInt.Type`, `Date.Type`, `UInt.Type`
    ///
    /// - Parameter type: Generic type `T` which conforms to `DecodableFromHex` protocol
    /// - Parameter key: The key that the decoded value is associated with.
    /// - Returns: A decoded value of type `T`
    /// - throws: `Web3Error.dataError` if value associated with key are unable to be initialized as `DecodableFromHex`.
    public func decodeHex<T: DecodableFromHex>(_ type: T.Type, forKey: KeyedDecodingContainer<K>.Key) throws -> T {
        let hexString = try self.decode(String.self, forKey: forKey)
        guard let value = T(from: hexString) else { throw Web3Error.dataError }
        return value
    }

    /// Decodes a value of the given key from Hex to `[DecodableFromHex]`
    ///
    /// Currently this method supports only `Data.Type`, `BigUInt.Type`, `Date.Type`, `UInt.Type`
    ///
    /// - Parameter type: Array of a generic type `T` which conforms to `DecodableFromHex` protocol
    /// - Parameter key: The key that the decoded value is associated with.
    /// - Returns: A decoded value of type `[T]`
    /// - throws: `Web3Error.dataError` if value associated with key are unable to be initialized as `[[DecodableFromHex]]`.
    public func decodeHex<T: DecodableFromHex>(_ type: [T].Type, forKey: KeyedDecodingContainer<K>.Key) throws -> [T] {
        var container = try nestedUnkeyedContainer(forKey: forKey)
        guard let array = try? container.decodeHex(type) else { throw Web3Error.dataError }
        return array
    }

    /// Decodes a value of the given key from Hex to `[[DecodableFromHex]]`
    ///
    /// Currently this method supports only `Data.Type`, `BigUInt.Type`, `Date.Type`, `EthereumAddress`, `UInt.Type`
    ///
    /// - Parameter type: Array of a generic type `T` which conforms to `DecodableFromHex` protocol
    /// - Parameter key: The key that the decoded value is associated with.
    /// - Returns: A decoded value of type `[[T]]`
    /// - throws: `Web3Error.dataError` if value associated with key are unable to be initialized as `[[DecodableFromHex]]`.
    public func decodeHex<T: DecodableFromHex>(_ type: [[T]].Type, forKey: KeyedDecodingContainer<K>.Key) throws -> [[T]] {
        var container = try nestedUnkeyedContainer(forKey: forKey)
        guard let array = try? container.decodeHex(type) else { throw Web3Error.dataError }
        return array
    }

    /// Decodes a value of the given key from Hex to `DecodableFromHex`
    ///
    /// Currently this method supports only `Data.Type`, `BigUInt.Type`, `Date.Type`, `UInt.Type`
    ///
    /// - Parameter type: Generic type `T` which conforms to `DecodableFromHex` protocol
    /// - Parameter key: The key that the decoded value is associated with.
    /// - Returns: A decoded value of type `T`, or nil if key is not present
    /// - throws: `Web3Error.dataError` if value associated with key are unable to be initialized as `DecodableFromHex`.
    public func decodeHexIfPresent<T: DecodableFromHex>(_ type: T.Type, forKey: KeyedDecodingContainer<K>.Key) throws -> T? {
        guard contains(forKey) else { return nil }
        return try decodeHex(type, forKey: forKey)
    }
}

extension UnkeyedDecodingContainer {
    /// Decodes a unkeyed value from hex to `[DecodableFromHex]`
    ///
    /// Currently this method supports only `Data.Type`, `BigUInt.Type`, `Date.Type`, `EthereumAddress`
    ///
    /// - Parameter type: Generic type `T` which conforms to `DecodableFromHex` protocol
    /// - Parameter key: The key that the decoded value is associated with.
    /// - Returns: A decoded value of type `BigUInt`
    /// - throws: `Web3Error.dataError` if value associated with key are unable to be initialized as `[DecodableFromHex]`.
    mutating func decodeHex<T: DecodableFromHex>(_ type: [T].Type) throws -> [T] {
        var array: [T] = []
        while !isAtEnd {
            let hexString = try decode(String.self)
            guard let item = T(from: hexString) else { continue }
            array.append(item)
        }
        return array
    }

    /// Decodes a unkeyed value from Hex to `DecodableFromHex`
    ///
    /// Currently this method supports only `Data.Type`, `BigUInt.Type`, `Date.Type`, `EthereumAddress`
    ///
    /// - Parameter type: Generic type `T` which conforms to `DecodableFromHex` protocol
    /// - Parameter key: The key that the decoded value is associated with.
    /// - Returns: A decoded value of type `BigUInt`
    /// - throws: `Web3Error.dataError` if value associated with key are unable to be initialized as `[[DecodableFromHex]]`.
    mutating func decodeHex<T: DecodableFromHex>(_ type: [[T]].Type) throws -> [[T]] {
        var array: [[T]] = []
        while !isAtEnd {
            var container = try nestedUnkeyedContainer()
            let intArr = try container.decodeHex([T].self)
            array.append(intArr)
        }
        return array
    }
}

public protocol DecodableFromHex: Decodable {
    init?(from hexString: String)
}

extension Data: DecodableFromHex {
    public init?(from hexString: String) {
        self.init()
        guard let tmp = Self.fromHex(hexString) else { return nil }
        self = tmp
    }
}

extension UInt: DecodableFromHex {
    public init?(from hexString: String) {
        self.init(hexString.stripHexPrefix(), radix: 16)
    }
}

extension BigUInt: DecodableFromHex {
    public init?(from hexString: String) {
        self.init(hexString.stripHexPrefix(), radix: 16)
    }
}

extension Date: DecodableFromHex {
    public init?(from hexString: String) {
        self.init()
        let stripedHexString = hexString.stripHexPrefix()
        guard let timestampInt = UInt(stripedHexString, radix: 16) else { return nil }
        self = Date(timeIntervalSince1970: TimeInterval(timestampInt))
    }
}

extension EthereumAddress: DecodableFromHex {
    public init?(from hexString: String) {
        self.init(hexString, ignoreChecksum: true)
    }
}
