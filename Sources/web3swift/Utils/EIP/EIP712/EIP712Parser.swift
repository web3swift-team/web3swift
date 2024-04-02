//
//  EIP712Parser.swift
//
//  Created by JeneaVranceanu on 17.10.2023.
//

import Foundation
import Web3Core

/// The only purpose of this class is to parse raw JSON and output an EIP712 hash ready for signing.
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
///
/// Example use case:
/// ```
///     let payload: String = ... // This is the payload received from eth_signTypedData
///     let eip712TypedData = try EIP712Parser.parse(payload)
///     let signature = try Web3Signer.signEIP712(
///         eip712TypedData,
///         keystore: keystore,
///         account: account,
///         password: password)
/// ```
public class EIP712Parser {

    static func toData(_ json: String) throws -> Data {
        guard let json = json.data(using: .utf8) else {
            throw Web3Error.inputError(desc: "EIP712Parser. Failed to parse EIP712 payload. Given string is not valid UTF8 string.")
        }
        return json
    }

    public static func parse(_ rawJson: String) throws -> EIP712TypedData {
        try parse(try toData(rawJson))
    }

    public static func parse(_ rawJson: Data) throws -> EIP712TypedData {
        let decoder = JSONDecoder()
        let types = try decoder.decode(EIP712TypeArray.self, from: rawJson).types
        guard let json = try rawJson.asJsonDictionary() else {
            throw Web3Error.inputError(desc: "EIP712Parser. Cannot decode given JSON as it cannot be represented as a Dictionary. Is it valid JSON?")
        }
        guard let primaryType = json["primaryType"] as? String else {
            throw Web3Error.inputError(desc: "EIP712Parser. Top-level string field 'primaryType' missing.")
        }
        guard let domain = json["domain"] as? [String : AnyObject] else {
            throw Web3Error.inputError(desc: "EIP712Parser. Top-level object field 'domain' missing.")
        }
        guard let message = json["message"] as? [String : AnyObject] else {
            throw Web3Error.inputError(desc: "EIP712Parser. Top-level object field 'message' missing.")
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
    /// Property type. A type that's ABI encodable or a custom type from ``EIP712TypedData/types``.
    public let type: String
    /// Stripped of brackets ([] - denoting an array).
    /// If ``type`` is an array of then ``coreType`` will return the type of the array.
    public let coreType: String

    public let isArray: Bool

    public init(name: String, type: String) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.type = type.trimmingCharacters(in: .whitespacesAndNewlines)

        var _coreType = self.type
        if _coreType.hasSuffix("[]") {
            _coreType.removeLast(2)
            isArray = true
        } else {
            isArray = false
        }
        self.coreType = _coreType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let type = try container.decode(String.self, forKey: .type)
        self.init(name: name, type: type)
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
        self.primaryType = primaryType.trimmingCharacters(in: .whitespacesAndNewlines)
        self.domain = domain
        self.message = message
    }

    public func encodeType(_ type: String) throws -> String {
        guard let typeData = types[type] else {
            throw Web3Error.processingError(desc: "EIP712Parser. Attempting to encode type that doesn't exist in this payload. Given type: \(type). Available types: \(types.keys).")
        }
        return try encodeType(type, typeData)
    }

    public func typeHash(_ type: String) throws -> String {
        try encodeType(type).sha3(.keccak256).addHexPrefix()
    }

    internal func encodeType(_ type: String, _ typeData: [EIP712TypeProperty], typesCovered: [String] = []) throws -> String {
        var typesCovered = typesCovered
        var encodedSubtypes: [String : String] = [:]
        let parameters = try typeData.map { attributeType in
            if let innerTypes = types[attributeType.coreType], !typesCovered.contains(attributeType.coreType) {
                typesCovered.append(attributeType.coreType)
                if attributeType.coreType != type {
                    encodedSubtypes[attributeType.coreType] = try encodeType(attributeType.coreType, innerTypes)
                }
            }
            return "\(attributeType.type) \(attributeType.name)"
        }
        return type + "(" + parameters.joined(separator: ",") + ")" + encodedSubtypes.sorted { lhs, rhs in
            return lhs.key < rhs.key
        }
        .map { $0.value }
        .joined(separator: "")
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
            throw Web3Error.processingError(desc: "EIP712Parser. Attempting to encode data for type that doesn't exist in this payload. Given type: \(type). Available types: \(types.keys).")
        }

        func encodeField(_ field: EIP712TypeProperty,
                         value: AnyObject?) throws -> (encTypes: [ABI.Element.ParameterType], encValues: [Any]) {
            var encTypes: [ABI.Element.ParameterType] = []
            var encValues: [Any] = []
            if field.type == "string" {
                guard let value = value as? String else {
                    throw Web3Error.processingError(desc: "EIP712Parser. Type metadata of '\(field)' and actual value '\(String(describing: value))' type doesn't match. Cannot cast value to String. Parent object type: \(type).")
                }
                encTypes.append(.bytes(length: 32))
                encValues.append(value.sha3(.keccak256).addHexPrefix())
            } else if field.type == "bytes"{
                let _value: Data?
                if let value = value as? String,
                   let data = Data.fromHex(value) {
                    _value = data
                } else {
                    _value = value as? Data
                }
                guard let value = _value else {
                    throw Web3Error.processingError(desc: "EIP712Parser. Type metadata '\(field)' and actual value '\(String(describing: value))' type doesn't match. Cannot cast/parse value to Data. Parent object type: \(type).")
                }
                encTypes.append(.bytes(length: 32))
                encValues.append(value.sha3(.keccak256))
            } else if field.isArray {
                guard let values = value as? [AnyObject] else {
                    throw Web3Error.processingError(desc: "EIP712Parser. Custom type metadata '\(field)' and actual value '\(String(describing: value))' type doesn't match. Cannot cast value to [AnyObject]. Parent object type: \(type)")
                }
                encTypes.append(.bytes(length: 32))
                let subField = EIP712TypeProperty(name: field.name, type: field.coreType)
                var encodedSubTypes: [ABI.Element.ParameterType] = []
                var encodedSubValues: [Any] = []
                try values.forEach { value in
                    let encoded = try encodeField(subField, value: value)
                    encodedSubTypes.append(contentsOf: encoded.encTypes)
                    encodedSubValues.append(contentsOf: encoded.encValues)
                }

                guard let encodedValue = ABIEncoder.encode(types: encodedSubTypes, values: encodedSubValues) else {
                    throw Web3Error.processingError(desc: "EIP712Parser. Failed to encode an array of custom type. Field: '\(field)'; value: '\(String(describing: value))'. Parent object type: \(type)")
                }

                encValues.append(encodedValue.sha3(.keccak256))
            } else if types[field.coreType] != nil  {
                encTypes.append(.bytes(length: 32))
                if let value = value as? [String : AnyObject] {
                    encValues.append(try encodeData(field.type, data: value).sha3(.keccak256))
                } else {
                    encValues.append(Data(count: 32))
                }
            } else {
                encTypes.append(try ABITypeParser.parseTypeString(field.type))
                encValues.append(value as Any)
            }
            return (encTypes, encValues)
        }

        // Add field contents
        for field in typeData {
            let (_encTypes, _encValues) = try encodeField(field, value: data[field.name])
            encTypes.append(contentsOf: _encTypes)
            encValues.append(contentsOf: _encValues)
        }

        guard let encodedData = ABIEncoder.encode(types: encTypes, values: encValues) else {
            throw Web3Error.processingError(desc: "EIP712Parser. ABIEncoder.encode failed with the following types and values: \(encTypes); \(encValues)")
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
