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

        return EIP712TypedData(types: types, primaryType: primaryType, domain: domain, message: message)
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
                message: [String : AnyObject]) {
        self.types = types
        self.primaryType = primaryType
        self.domain = domain
        self.message = message
    }

}
