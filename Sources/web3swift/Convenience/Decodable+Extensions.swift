//
//  DecodingContainer+AnyCollection.swift
//  AnyDecodable
//
//  Created by levantAJ on 1/18/19.
//  Copyright © 2019 levantAJ. All rights reserved.
//
import BigInt
import Foundation

extension KeyedDecodingContainer {
    /// Decodes a value of the given key from Hex to `DecodableFromHex`
    ///
    /// Currently this method supports only `Data.Type`, `BigUInt.Type`, `Date.Type`
    ///
    /// - Parameter type: Generic type `T` wich conforms to `DecodableFromHex` protocol
    /// - Parameter key: The key that the decoded value is associated with.
    /// - Returns: A decoded value of type `BigUInt`
    /// - throws: `Web3Error.dataError` if value associated with key are unable to be initialized as `DecodableFromHex`.
    public func decodeHex<T: DecodableFromHex>(_ type: T.Type, forKey: KeyedDecodingContainer<K>.Key) throws -> T {
        let string = try self.decode(String.self, forKey: forKey)
        guard let number = T(fromHex: string) else { throw Web3Error.dataError }
        return number
    }

    /// Decodes a value of the given key from Hex to `[DecodableFromHex]`
    ///
    /// Currently this method supports only `Data.Type`, `BigUInt.Type`, `Date.Type`
    ///
    /// - Parameter type: Array of a generic type `T` wich conforms to `DecodableFromHex` protocol
    /// - Parameter key: The key that the decoded value is associated with.
    /// - Returns: A decoded value of type `BigUInt`
    /// - throws: `Web3Error.dataError` if value associated with key are unable to be initialized as `[DecodableFromHex]`.
    public func decodeHex<T: DecodableFromHex>(_ type: Array<T>.Type, forKey: KeyedDecodingContainer<K>.Key) throws -> Array<T> {
        var container = try self.nestedUnkeyedContainer(forKey: forKey)
        guard let array = try? container.decode(type) else { throw Web3Error.dataError }
        return array
    }

    /// Decodes a value of the given key from Hex to `[DecodableFromHex]`
    ///
    /// Currently this method supports only `Data.Type`, `BigUInt.Type`, `Date.Type`
    ///
    /// - Parameter type: Array of a generic type `T` wich conforms to `DecodableFromHex` protocol
    /// - Parameter key: The key that the decoded value is associated with.
    /// - Returns: A decoded value of type `BigUInt`
    /// - throws: `Web3Error.dataError` if value associated with key are unable to be initialized as `[DecodableFromHex]`.
    public func decodeHex<T: DecodableFromHex>(_ type: Array<Array<T>>.Type, forKey: KeyedDecodingContainer<K>.Key) throws -> Array<Array<T>> {
        var container = try self.nestedUnkeyedContainer(forKey: forKey)
        guard let array = try? container.decode(type) else { throw Web3Error.dataError }
        return array
    }
}

public protocol DecodableFromHex: Decodable {
    init?(fromHex hexString: String)
}

extension Data: DecodableFromHex {
    public init?(fromHex hexString: String) {
        self.init()
        guard let tmp = Self.fromHex(hexString) else { return nil }
        self = tmp
    }
}

extension BigUInt: DecodableFromHex {
    public init?(fromHex hexString: String) {
        self.init(hexString.stripHexPrefix(), radix: 16)
    }
}

extension Date: DecodableFromHex {
    public init?(fromHex hexString: String) {
        self.init()
        let stripedHexString = hexString.stripHexPrefix()
        guard let timestampInt = UInt64(stripedHexString, radix: 16) else { return nil }
        self = Date(timeIntervalSince1970: TimeInterval(timestampInt))
    }
}

extension EthereumAddress: DecodableFromHex {
    public init?(fromHex hexString: String) {
        self.init(hexString, ignoreChecksum: true)
    }
}
