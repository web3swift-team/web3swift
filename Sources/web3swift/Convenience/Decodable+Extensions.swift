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
    /// Decodes a value of the given type for the given key.
    ///
    /// - parameter type: The type of value to decode.
    /// - parameter key: The key that the decoded value is associated with.
    /// - returns: A value of the requested type, if present for the given key
    ///   and convertible to the requested type.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to the requested type.
    /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry
    ///   for the given key.
    /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for
    ///   the given key.
    @available(*, deprecated, message: "Use decodeHex insetad")
    public func decode(_ type: [Any].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [Any] {
        var values = try nestedUnkeyedContainer(forKey: key)
        return try values.decode(type)
    }

    /// Decodes a value of the given type for the given key.
    ///
    /// - parameter type: The type of value to decode.
    /// - parameter key: The key that the decoded value is associated with.
    /// - returns: A value of the requested type, if present for the given key
    ///   and convertible to the requested type.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to the requested type.
    /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry
    ///   for the given key.
    /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for
    ///   the given key.
    @available(*, deprecated, message: "Use decodeHex() insetad")
    public func decode(_ type: [String: Any].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [String: Any] {
        let values = try nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
        return try values.decode(type)
    }

    /// Decodes a value of the given type for the given key, if present.
    ///
    /// This method returns `nil` if the container does not have a value
    /// associated with `key`, or if the value is null. The difference between
    /// these states can be distinguished with a `contains(_:)` call.
    ///
    /// - parameter type: The type of value to decode.
    /// - parameter key: The key that the decoded value is associated with.
    /// - returns: A decoded value of the requested type, or `nil` if the
    ///   `Decoder` does not have an entry associated with the given key, or if
    ///   the value is a null value.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to the requested type.
    @available(*, deprecated, message: "In next version Will be replaced by decodeHexIfPresent() insetad")
    public func decodeIfPresent(_ type: [Any].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [Any]? {
        guard contains(key),
            try decodeNil(forKey: key) == false else { return nil }
        return try decode(type, forKey: key)
    }

    /// Decodes a value of the given type for the given key, if present.
    ///
    /// This method returns `nil` if the container does not have a value
    /// associated with `key`, or if the value is null. The difference between
    /// these states can be distinguished with a `contains(_:)` call.
    ///
    /// - parameter type: The type of value to decode.
    /// - parameter key: The key that the decoded value is associated with.
    /// - returns: A decoded value of the requested type, or `nil` if the
    ///   `Decoder` does not have an entry associated with the given key, or if
    ///   the value is a null value.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to the requested type.
    @available(*, deprecated, message: "In next version Will be replaced by decodeHexIfPresent() insetad")
    public func decodeIfPresent(_ type: [String: Any].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [String: Any]? {
        guard contains(key),
            try decodeNil(forKey: key) == false else { return nil }
        return try decode(type, forKey: key)
    }

    /// Decodes a value of the given key from Hex to `DecodableFromHex`
    ///
    /// Currently this method supports only `Data.Type`, `BigUInt.Type`, `Date.Type`, `UInt.Type`
    ///
    /// - Parameter type: Generic type `T` wich conforms to `DecodableFromHex` protocol
    /// - Parameter key: The key that the decoded value is associated with.
    /// - Returns: A decoded value of type `T`
    /// - throws: `Web3Error.dataError` if value associated with key are unable to be initialized as `DecodableFromHex`.
    public func decodeHex<T: DecodableFromHex>(_ type: T.Type, forKey: KeyedDecodingContainer<K>.Key) throws -> T {
        let hexString = try self.decode(String.self, forKey: forKey)
        guard let number = T(fromHex: hexString) else { throw Web3Error.dataError }
        return number
    }

    /// Decodes a value of the given key from Hex to `[DecodableFromHex]`
    ///
    /// Currently this method supports only `Data.Type`, `BigUInt.Type`, `Date.Type`, `UInt.Type`
    ///
    /// - Parameter type: Array of a generic type `T` wich conforms to `DecodableFromHex` protocol
    /// - Parameter key: The key that the decoded value is associated with.
    /// - Returns: A decoded value of type `T`
    /// - throws: `Web3Error.dataError` if value associated with key are unable to be initialized as `[[DecodableFromHex]]`.
    public func decodeHex<T: DecodableFromHex>(_ type: [T].Type, forKey: KeyedDecodingContainer<K>.Key) throws -> [T] {
        var container = try nestedUnkeyedContainer(forKey: forKey)
        guard let array = try? container.decodeHex(type) else { throw Web3Error.dataError }
        return array
    }

    /// Decodes a value of the given key from Hex to `[DecodableFromHex]`
    ///
    /// Currently this method supports only `Data.Type`, `BigUInt.Type`, `Date.Type`, `EthereumAddress`, `UInt.Type`
    ///
    /// - Parameter type: Array of a generic type `T` wich conforms to `DecodableFromHex` protocol
    /// - Parameter key: The key that the decoded value is associated with.
    /// - Returns: A decoded value of type `T`
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
    /// - Parameter type: Generic type `T` wich conforms to `DecodableFromHex` protocol
    /// - Parameter key: The key that the decoded value is associated with.
    /// - Returns: A decoded value of type `T`, or nil if key is not present
    /// - throws: `Web3Error.dataError` if value associated with key are unable to be initialized as `DecodableFromHex`.
    public func decodeHexIfPresent<T: DecodableFromHex>(_ type: T.Type, forKey: KeyedDecodingContainer<K>.Key) throws -> T? {
        guard contains(forKey) else { return nil }
        return try decodeHex(type, forKey: forKey)
    }

}

public extension UnkeyedDecodingContainer {
    /// Decodes a unkeyed value from hex to `[DecodableFromHex]`
    ///
    /// Currently this method supports only `Data.Type`, `BigUInt.Type`, `Date.Type`, `EthereumAddress`
    ///
    /// - Parameter type: Generic type `T` wich conforms to `DecodableFromHex` protocol
    /// - Parameter key: The key that the decoded value is associated with.
    /// - Returns: A decoded value of type `BigUInt`
    /// - throws: `Web3Error.dataError` if value associated with key are unable to be initialized as `[DecodableFromHex]`.
    mutating func decodeHex<T: DecodableFromHex>(_ type: [T].Type) throws -> [T] {
        var array: [T] = []
        while !isAtEnd {
            let hexString = try decode(String.self)
            guard let item = T(fromHex: hexString) else { continue }
            array.append(item)
        }
        return array
    }


    /// Decodes a unkeyed value from Hex to `DecodableFromHex`
    ///
    /// Currently this method supports only `Data.Type`, `BigUInt.Type`, `Date.Type`, `EthereumAddress`
    ///
    /// - Parameter type: Generic type `T` wich conforms to `DecodableFromHex` protocol
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
    init?(fromHex hexString: String)
}

extension Data: DecodableFromHex {
    public init?(fromHex hexString: String) {
        self.init()
        guard let tmp = Self.fromHex(hexString) else { return nil }
        self = tmp
    }
}

extension UInt: DecodableFromHex {
    public init?(fromHex hexString: String) {
        self.init(hexString.stripHexPrefix(), radix: 16)
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

// deprecated, should be removed in 3.0.0
private extension KeyedDecodingContainer {
    func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        var dictionary: [String: Any] = [:]
        for key in allKeys {
            if try decodeNil(forKey: key) {
                dictionary[key.stringValue] = NSNull()
            } else if let bool = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = bool
            } else if let string = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = string
            } else if let int = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = int
            } else if let double = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = double
            } else if let dict = try? decode([String: Any].self, forKey: key) {
                dictionary[key.stringValue] = dict
            } else if let array = try? decode([Any].self, forKey: key) {
                dictionary[key.stringValue] = array
            }
        }
        return dictionary
    }
}

// deprecated, should be removed in 3.0.0
private extension UnkeyedDecodingContainer {
    mutating func decode(_ type: [Any].Type) throws -> [Any] {
        var elements: [Any] = []
        while !isAtEnd {
            if try decodeNil() {
                elements.append(NSNull())
            } else if let int = try? decode(Int.self) {
                elements.append(int)
            } else if let bool = try? decode(Bool.self) {
                elements.append(bool)
            } else if let double = try? decode(Double.self) {
                elements.append(double)
            } else if let string = try? decode(String.self) {
                elements.append(string)
            } else if let values = try? nestedContainer(keyedBy: AnyCodingKey.self),
                let element = try? values.decode([String: Any].self) {
                elements.append(element)
            } else if var values = try? nestedUnkeyedContainer(),
                let element = try? values.decode([Any].self) {
                elements.append(element)
            }
        }
        return elements
    }
}
