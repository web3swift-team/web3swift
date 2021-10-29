//
//  EncodingContainer+AnyCollection.swift
//  AnyDecodable
//
//  Created by ShopBack on 1/19/19.
//  Copyright © 2019 levantAJ. All rights reserved.
//
import Foundation

extension KeyedEncodingContainer {
    /// Encodes the given value for the given key.
    ///
    /// - parameter value: The value to encode.
    /// - parameter key: The key to associate the value with.
    /// - throws: `EncodingError.invalidValue` if the given value is invalid in
    ///   the current context for this format.
    public mutating func encode(_ value: [String: Any], forKey key: KeyedEncodingContainer<K>.Key) throws {
        var container = nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
        try container.encode(value)
    }
    
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
    
    /// Encodes the given value for the given key if it is not `nil`.
    ///
    /// - parameter value: The value to encode.
    /// - parameter key: The key to associate the value with.
    /// - throws: `EncodingError.invalidValue` if the given value is invalid in
    ///   the current context for this format.
    public mutating func encodeIfPresent(_ value: [String: Any]?, forKey key: KeyedEncodingContainer<K>.Key) throws {
        if let value = value {
            var container = nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
            try container.encode(value)
        } else {
            try encodeNil(forKey: key)
        }
    }
    
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

private extension KeyedEncodingContainer where K == AnyCodingKey {
    mutating func encode(_ value: [String: Any]) throws {
        for (k, v) in value {
            let key = AnyCodingKey(stringValue: k)!
            switch v {
            case is NSNull:
                try encodeNil(forKey: key)
            case let string as String:
                try encode(string, forKey: key)
            case let int as Int:
                try encode(int, forKey: key)
            case let bool as Bool:
                try encode(bool, forKey: key)
            case let double as Double:
                try encode(double, forKey: key)
            case let dict as [String: Any]:
                try encode(dict, forKey: key)
            case let array as [Any]:
                try encode(array, forKey: key)
            default:
                debugPrint("⚠️ Unsuported type!", v)
                continue
            }
        }
    }
}

private extension UnkeyedEncodingContainer {
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
            case let dict as [String: Any]:
                try encode(dict)
            case let array as [Any]:
                var values = nestedUnkeyedContainer()
                try values.encode(array)
            default:
                debugPrint("⚠️ Unsuported type!", v)
            }
        }
    }
    
    /// Encodes the given value.
    ///
    /// - parameter value: The value to encode.
    /// - throws: `EncodingError.invalidValue` if the given value is invalid in
    ///   the current context for this format.
    mutating func encode(_ value: [String: Any]) throws {
        var container = self.nestedContainer(keyedBy: AnyCodingKey.self)
        try container.encode(value)
    }
}
