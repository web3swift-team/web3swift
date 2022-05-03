//
//  EncodingContainer+AnyCollection.swift
//  AnyDecodable
//
//  Created by ShopBack on 1/19/19.
//  Copyright © 2019 levantAJ. All rights reserved.
//
import Foundation
import BigInt

public extension KeyedEncodingContainer {
//    /// Encodes the given value for the given key.
//    ///
//    /// - parameter value: The value to encode.
//    /// - parameter key: The key to associate the value with.
//    /// - throws: `EncodingError.invalidValue` if the given value is invalid in
//    ///   the current context for this format.
//    public mutating func encode(_ value: [String: Any], forKey key: KeyedEncodingContainer<K>.Key) throws {
//        var container = nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
//        try container.encode(value)
//    }

    /// Encodes the given value for the given key.
    ///
    /// - parameter value: The value to encode.
    /// - parameter key: The key to associate the value with.
    /// - throws: `EncodingError.invalidValue` if the given value is invalid in
    ///   the current context for this format.
    public mutating func encode(_ value: [Any], forKey key: KeyedEncodingContainer<K>.Key) throws {
        var container = nestedUnkeyedContainer(forKey: key)
        try container.encode(value)
    }


    public mutating func encodeHex<T: EncodableToHex>(_ value: T, forKey key: KeyedEncodingContainer<K>.Key) throws {
        try encode(value.hexString, forKey: key)
    }

    public mutating func encodeHex<T: EncodableToHex>(_ value: [T], forKey key: KeyedEncodingContainer<K>.Key) throws {
        var container = nestedUnkeyedContainer(forKey: key)
        try container.encodeHex(value)
    }

//    /// Encodes the given value for the given key if it is not `nil`.
//    ///
//    /// - parameter value: The value to encode.
//    /// - parameter key: The key to associate the value with.
//    /// - throws: `EncodingError.invalidValue` if the given value is invalid in
//    ///   the current context for this format.
//    public mutating func encodeIfPresent(_ value: [String: Any]?, forKey key: KeyedEncodingContainer<K>.Key) throws {
//        if let value = value {
//            var container = nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
//            try container.encode(value)
//        } else {
//            try encodeNil(forKey: key)
//        }
//    }

    /// Encodes the given value for the given key if it is not `nil`.
    ///
    /// - parameter value: The value to encode.
    /// - parameter key: The key to associate the value with.
    /// - throws: `EncodingError.invalidValue` if the given value is invalid in
    ///   the current context for this format.
    public mutating func encodeIfPresent(_ value: [Any]?, forKey key: KeyedEncodingContainer<K>.Key) throws {
        if let value = value {
            var container = nestedUnkeyedContainer(forKey: key)
            try container.encode(value)
        } else {
            try encodeNil(forKey: key)
        }
    }
}

private extension UnkeyedEncodingContainer {

    public mutating func encodeHex<T: EncodableToHex>(_ value: T) throws {
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

    /// Encodes the given value.
    ///
    /// - parameter value: The value to encode.
    /// - throws: `EncodingError.invalidValue` if the given value is invalid in
    ///   the current context for this format.
    mutating func encode(_ value: [Any]) throws {
        for v in value {
            switch v {
            case is NSNull:
                try encodeNil()
            case let string as String:
                try encode(string)
            case let int as Int:
                try encode(int)
            case let bool as Bool:
                try encode(bool)
            case let double as Double:
                try encode(double)
//            case let dict as [String: Any]:
//                try encode(dict)
            case let array as [Any]:
                var values = nestedUnkeyedContainer()
                try values.encode(array)
            default:
                debugPrint("⚠️ Unsuported type!", v)
            }
        }
    }

//    /// Encodes the given value.
//    ///
//    /// - parameter value: The value to encode.
//    /// - throws: `EncodingError.invalidValue` if the given value is invalid in
//    ///   the current context for this format.
//    mutating func encode(_ value: [String: Any]) throws {
//        var container = self.nestedContainer(keyedBy: AnyCodingKey.self)
//        try container.encode(value)
//    }
}


public protocol EncodableToHex: Encodable {
    var hexString: String { get }
}

public extension EncodableToHex where Self: BinaryInteger {
    var hexString: String { "0x" + String(self, radix: 16) }
}

extension BigUInt: EncodableToHex { }

extension UInt: EncodableToHex { }
