//
//  EncodingContainer+AnyCollection.swift
//  AnyDecodable
//
//  Created by ShopBack on 1/19/19.
//  Copyright © 2019 levantAJ. All rights reserved.
//
import Foundation
import BigInt

extension KeyedEncodingContainer {
    mutating func encodeHex<T: EncodableToHex>(_ value: T, forKey key: KeyedEncodingContainer<K>.Key) throws {
        try encode(value.hexString, forKey: key)
    }

    mutating func encodeHex<T: EncodableToHex>(_ value: [T], forKey key: KeyedEncodingContainer<K>.Key) throws {
        var container = nestedUnkeyedContainer(forKey: key)
        try container.encodeHex(value)
    }

    /// Encodes the given value for the given key if it is not `nil`.
    ///
    /// - parameter value: The value to encode.
    /// - parameter key: The key to associate the value with.
    /// - throws: `EncodingError.invalidValue` if the given value is invalid in
    ///   the current context for this format.
    mutating func encodeIfPresent<T: EncodableToHex>(_ value: [T]?, forKey key: KeyedEncodingContainer<K>.Key) throws {
        if let value = value {
            var container = nestedUnkeyedContainer(forKey: key)
            try container.encode(value)
        } else {
            try encodeNil(forKey: key)
        }
    }
}

extension UnkeyedEncodingContainer {
    mutating func encodeHex<T: EncodableToHex>(_ value: T) throws {
        try encode(value.hexString)
    }

    mutating func encodeHex<T: EncodableToHex>(_ value: [T]) throws {
        try value.forEach { try encode($0.hexString) }
    }

    mutating func encodeHex<T: EncodableToHex>(_ value: [[T]]) throws {
        try value.forEach {
            try $0.forEach {
                try encode($0.hexString)
            }
        }
    }
}

public protocol EncodableToHex: Encodable {
    var hexString: String { get }
}

public extension EncodableToHex where Self: BinaryInteger {
    var hexString: String { "0x" + String(self, radix: 16) }
}

extension BigUInt: EncodableToHex { }

extension UInt: EncodableToHex { }
