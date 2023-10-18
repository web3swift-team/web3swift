//
//  EIP712Parser.swift
//
//  Created by JeneaVranceanu on 17.10.2023.
//

import Foundation
import Web3Core

/// The only purpose of this class is to parse raw JSON and output an EIP712 hash.
/// Example of a payload that is received via `eth_signTypedData` for signing:
/// ```
/// {
///    "types":{
///       "EIP712Domain":[
///          {
///             "name":"name",
///             "type":"string"
///          },
///          {
///             "name":"version",
///             "type":"string"
///          },
///          {
///             "name":"chainId",
///             "type":"uint256"
///          },
///          {
///             "name":"verifyingContract",
///             "type":"address"
///          }
///       ],
///       "Person":[
///          {
///             "name":"name",
///             "type":"string"
///          },
///          {
///             "name":"wallet",
///             "type":"address"
///          }
///       ],
///       "Mail":[
///          {
///             "name":"from",
///             "type":"Person"
///          },
///          {
///             "name":"to",
///             "type":"Person"
///          },
///          {
///             "name":"contents",
///             "type":"string"
///          }
///       ]
///    },
///    "primaryType":"Mail",
///    "domain":{
///       "name":"Ether Mail",
///       "version":"1",
///       "chainId":1,
///       "verifyingContract":"0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"
///    },
///    "message":{
///       "from":{
///          "name":"Cow",
///          "wallet":"0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"
///       },
///       "to":{
///          "name":"Bob",
///          "wallet":"0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB"
///       },
///       "contents":"Hello, Bob!"
///    }
/// }
/// ```
public class EIP712Parser {
    static func toData(_ json: String) throws -> Data {
        guard let json = json.data(using: .utf8) else {
            throw Web3Error.inputError(desc: "Failed to parse EIP712 payload. Given string is not valid UTF8 string. \(json)")
        }
        return json
    }

    public static func parse(_ rawJson: String) throws -> EIP712TypedData {
        try parse(try toData(rawJson))
    }

    public static func parse(_ rawJson: Data) throws -> EIP712TypedData {
        let decoder = JSONDecoder()
        let types = try decoder.decode(EIP712TypeArray.self, from: rawJson).types
        guard let json = try rawJson.asJsonDictionary(),
              let primaryType = json["primaryType"] as? String,
              let domain = json["domain"] as? [String : AnyObject],
              let message = json["message"] as? [String : AnyObject]
        else {
            throw Web3Error.inputError(desc: "EIP712Parser: cannot decode EIP712TypedData object. Failed to parse one of primaryType, domain or message fields. Is any field missing?")
        }

        return try EIP712TypedData(types: types, primaryType: primaryType, domain: domain, message: message)
    }
}

internal struct EIP712TypeArray: Codable {
    public let types: [String : [EIP712TypeProperty]]
}

public struct EIP712TypeProperty: Codable {
    /// Property name. An arbitrary string.
    public let name: String
    /// Property type. A type that's ABI encodable.
    public let type: String

    public init(name: String, type: String) {
        self.name = name
        self.type = type
    }
}

public struct EIP712TypedData {
    public let types: [String: [EIP712TypeProperty]]
    /// A name of one of the types from `types`.
    public let primaryType: String
    /// A JSON object as a string
    public let domain: [String : AnyObject]
    /// A JSON object as a string
    public let message: [String : AnyObject]

    public init(types: [String : [EIP712TypeProperty]],
                primaryType: String,
                domain: [String : AnyObject],
                message: [String : AnyObject]) throws {
        self.types = types
        self.primaryType = primaryType
        self.domain = domain
        self.message = message
        if let problematicType = hasCircularDependency() {
            throw Web3Error.inputError(desc: "Created EIP712TypedData has a circular dependency amongst it's types. Cycle was first identified in '\(problematicType)'. Review it's uses in 'types'.")
        }
    }

    /// Checks for a circular dependency among the given types.
    ///
    /// If a circular dependency is detected, it returns the name of the type where the cycle was first identified.
    /// Otherwise, it returns `nil`.
    ///
    /// - Returns: The type name where a circular dependency is detected, or `nil` if no circular dependency exists.
    /// - Note: The function utilizes depth-first search to identify the circular dependencies.
    func hasCircularDependency() -> String? {

        /// Generates an adjacency list for the given types, representing their dependencies.
        ///
        /// - Parameter types: A dictionary mapping type names to their property definitions.
        /// - Returns: An adjacency list representing type dependencies.
        func createAdjacencyList(types: [String: [EIP712TypeProperty]]) -> [String: [String]] {
            var adjList: [String: [String]] = [:]

            for (typeName, fields) in types {
                adjList[typeName] = []
                for field in fields {
                    if types.keys.contains(field.type) {
                        adjList[typeName]?.append(field.type)
                    }
                }
            }

            return adjList
        }

        let adjList = createAdjacencyList(types: types)

        /// Depth-first search to check for circular dependencies.
        ///
        /// - Parameters:
        ///   - node: The current type being checked.
        ///   - visited: A dictionary keeping track of the visited types.
        ///   - stack: A dictionary used for checking the current path for cycles.
        ///
        /// - Returns: `true` if a cycle is detected from the current node, `false` otherwise.
        func depthFirstSearch(node: String, visited: inout [String: Bool], stack: inout [String: Bool]) -> Bool {
            visited[node] = true
            stack[node] = true

            for neighbor in adjList[node] ?? [] {
                if visited[neighbor] == nil {
                    if depthFirstSearch(node: neighbor, visited: &visited, stack: &stack) {
                        return true
                    }
                } else if stack[neighbor] == true {
                    return true
                }
            }

            stack[node] = false
            return false
        }

        var visited: [String: Bool] = [:]
        var stack: [String: Bool] = [:]

        for typeName in adjList.keys {
            if visited[typeName] == nil {
                if depthFirstSearch(node: typeName, visited: &visited, stack: &stack) {
                    return typeName
                }
            }
        }

        return nil
    }

    public func encodeType(_ type: String) throws -> String {
        guard let typeData = types[type] else {
            throw Web3Error.processingError(desc: "EIP712. Attempting to encode type that doesn't exist in this payload. Given type: \(type). Available types: \(types.values).")
        }
        return try encodeType(type, typeData)
    }

    public func typeHash(_ type: String) throws -> String {
        try encodeType(type).sha3(.keccak256).addHexPrefix()
    }

    internal func encodeType(_ type: String, _ typeData: [EIP712TypeProperty], typesCovered: [String] = []) throws -> String {
        var typesCovered = typesCovered
        var encodedSubtypes: [String] = []
        let parameters = try typeData.map { attributeType in
            if let innerTypes = types[attributeType.type], !typesCovered.contains(attributeType.type) {
                encodedSubtypes.append(try encodeType(attributeType.type, innerTypes))
                typesCovered.append(attributeType.type)
            }
            return "\(attributeType.type) \(attributeType.name)"
        }
        return type + "(" + parameters.joined(separator: ",") + ")" + encodedSubtypes.joined(separator: "")
    }

    /// Convenience function for ``encodeData(_:data:)`` that uses ``primaryType`` and ``message`` as values.
    /// - Returns: encoded data based on ``primaryType`` and ``message``.
    public func encodeData() throws -> Data {
        try encodeData(primaryType, data: message)
    }

    public func encodeData(_ type: String, data: [String : AnyObject]) throws -> Data {
        // Adding typehash
        var encTypes: [ABI.Element.ParameterType] = [.bytes(length: 32)]
        var encValues: [Any] = [try typeHash(type)]

        guard let typeData = types[type] else {
            throw Web3Error.processingError(desc: "EIP712. Attempting to encode data for type that doesn't exist in this payload. Given type: \(type). Available types: \(types.values).")
        }

        // Add field contents
        for field in typeData {
            let value = data[field.name]
            if field.type == "string" {
                guard let value = value as? String else {
                    throw Web3Error.processingError(desc: "EIP712. Type metadata '\(field)' and actual value '\(String(describing: value))' type doesn't match. Cannot cast value to String.")
                }
                encTypes.append(.bytes(length: 32))
                encValues.append(value.sha3(.keccak256).addHexPrefix())
            } else if field.type == "bytes"{
                guard let value = value as? Data else {
                    throw Web3Error.processingError(desc: "EIP712. Type metadata '\(field)' and actual value '\(String(describing: value))' type doesn't match. Cannot cast value to Data.")
                }
                encTypes.append(.bytes(length: 32))
                encValues.append(value.sha3(.keccak256))
            } else if types[field.type] != nil {
                guard let value = value as? [String : AnyObject] else {
                    throw Web3Error.processingError(desc: "EIP712. Custom type metadata '\(field)' and actual value '\(String(describing: value))' type doesn't match. Cannot cast value to [String : AnyObject].")
                }
                encTypes.append(.bytes(length: 32))
                encValues.append(try encodeData(field.type, data: value).sha3(.keccak256))
            } else {
                encTypes.append(try ABITypeParser.parseTypeString(field.type))
                encValues.append(value as Any)
            }
        }

        guard let encodedData = ABIEncoder.encode(types: encTypes, values: encValues) else {
            throw Web3Error.processingError(desc: "EIP712. ABIEncoder.encode failed with the following types and values: \(encTypes); \(encValues)")
        }
        return encodedData
    }

    /// Convenience function for ``structHash(_:data:)`` that uses ``primaryType`` and ``message`` as values.
    /// - Returns: SH# keccak256 hash of encoded data based on ``primaryType`` and ``message``.
    public func structHash() throws -> Data {
        try structHash(primaryType, data: message)
    }

    public func structHash(_ type: String, data: [String : AnyObject]) throws -> Data {
        try encodeData(type, data: data).sha3(.keccak256)
    }

    public func signHash() throws -> Data {
        try (Data.fromHex("0x1901")! + structHash("EIP712Domain", data: domain) + structHash()).sha3(.keccak256)
    }
}
