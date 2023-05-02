//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
//  Additions to support new transaction types by Mark Loit March 2022
//
//  Made most structs generics by Yaroslav Yashin 2022

import Foundation
import BigInt

/// Global counter object to enumerate JSON RPC requests.
public struct Counter {
    public static var counter: UInt = 1
    public static var lockQueue = DispatchQueue(label: "counterQueue")
    public static func increment() -> UInt {
        defer {
            lockQueue.sync {
                Counter.counter += 1
            }
        }
        return counter
    }
}

/// Event filter parameters JSON structure for interaction with Ethereum node.
public struct EventFilterParameters: Encodable {
    public var fromBlock: BlockNumber
    public var toBlock: BlockNumber
    public var address: [EthereumAddress]
    public var topics: [Topic?]

    public init(fromBlock: BlockNumber = .latest, toBlock: BlockNumber = .latest, address: [EthereumAddress] = [], topics: [Topic?] = []) {
        self.fromBlock = fromBlock
        self.toBlock = toBlock
        self.topics = topics
        self.address = address
    }
}

extension EventFilterParameters {
    enum CodingKeys: String, CodingKey {
        case fromBlock
        case toBlock
        case address
        case topics
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fromBlock.description, forKey: .fromBlock)
        try container.encode(toBlock.description, forKey: .toBlock)
        try container.encode(address.description, forKey: .address)
        try container.encode(topics.textRepresentation, forKey: .topics)
    }
}

extension EventFilterParameters {
    /// This enum covers the optional nested Arrays
    ///
    /// ``EventFilterParameters`` include ``topic`` property with is array of optional values,
    /// and where `nil` value is a thing, and should be kept in server request.
    ///
    /// This is not a trivial case for swift lang or any other stricktly typed lang.
    ///
    /// So to make this possible ``Topic`` enum is provided.
    ///
    /// It handle two cases: ``.string(String?)`` and ``.strings([Topic?]?)``,
    /// where former should be used to assign first demention value,
    /// and the latter to assign second dimension value into ``EventFilterParameters.topics`` property.
    ///
    ///  So to encode as a parameter follow JSON array:
    ///  ```JSON
    ///  [
    ///          "0x000000000000000000000000a94f5374fce5edbc8e2a8697c15331677e6ebf0b",
    ///          null,
    ///          [
    ///              "0x000000000000000000000000a94f5374fce5edbc8e2a8697c15331677e6ebf0b",
    ///              "0x0000000000000000000000000aff3454fce5edbc8cca8697c15331677e6ebccc"
    ///          ]
    /// ]
    /// ```
    ///
    /// you have to pass to the ``topics`` property follow swift array:
    /// ```swift
    /// let topics: [Topic?] = [
    ///          .string("0x000000000000000000000000a94f5374fce5edbc8e2a8697c15331677e6ebf0b"),
    ///          .string(nil),
    ///          .strings([
    ///              .string("0x000000000000000000000000a94f5374fce5edbc8e2a8697c15331677e6ebf0b"),
    ///              .string("0x0000000000000000000000000aff3454fce5edbc8cca8697c15331677e6ebccc"),
    ///          ])
    ///      ]
    /// ```
    public enum Topic: Encodable {
        case string(String?)
        case strings([Topic?]?)

        var rawValue: String {
            switch self {
            case let .string(string):
                // Associated value can contain only String or nil, both of them always encoded as a JSON could be represented as String again.
                return String(data: try! JSONEncoder().encode(string), encoding: .utf8)!
            case let .strings(strings):
                return strings!.textRepresentation
            }
        }
    }
}

extension EventFilterParameters: APIRequestParameterType { }

// - Why don't you develop some JSON composer to just send a server request, Yaroslav?
// - Indeed, see no reason, why should i pass this.
// Oh i wish to look deep in the Vitaliks eyes someday.
extension Array where Element == EventFilterParameters.Topic? {
    var textRepresentation: String {
        var string = "["
        for (number, element) in self.enumerated() {
            if number > 0 {
                string += ","
            }
            if let element = element {
                string += element.rawValue
            } else {
                string += "null"
            }
        }
        string += "]"
        return string
    }
}
