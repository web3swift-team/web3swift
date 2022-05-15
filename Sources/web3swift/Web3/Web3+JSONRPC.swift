//  Package: web3swift
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
//  Additions to support new transaction types by Mark Loit March 2022

import Foundation
import BigInt

/// Global counter object to enumerate JSON RPC requests.
public struct Counter {
    public static var counter = UInt64(1)
    public static var lockQueue = DispatchQueue(label: "counterQueue")
    public static func increment() -> UInt64 {
        var c: UInt64 = 0
        lockQueue.sync {
            c = Counter.counter
            Counter.counter = Counter.counter + 1
        }
        return c
    }
}

/// JSON RPC request structure for serialization and deserialization purposes.
//public struct JSONRPCrequest<T: Encodable>: Encodable {
public struct JSONRPCrequest: Encodable {
    public var jsonrpc: String = "2.0"
    public var method: JSONRPCmethod?
    public var params: [JSONRPCParameter] = []
    public var id: UInt64 = Counter.increment()

    enum CodingKeys: String, CodingKey {
        case jsonrpc
        case method
        case params
        case id
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encode(method?.rawValue, forKey: .method)
        try container.encode(params, forKey: .params)
        try container.encode(id, forKey: .id)
    }

    public var isValid: Bool {
        get {
            if self.method == nil {
                return false
            }
            guard let method = self.method else {return false}
            return method.requiredNumOfParameters == self.params.count
        }
    }
}

/// JSON RPC batch request structure for serialization and deserialization purposes.
public struct JSONRPCrequestBatch: Encodable {
    var requests: [JSONRPCrequest]

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.requests)
    }
}

/// JSON RPC response structure for serialization and deserialization purposes.
public struct JSONRPCresponse: Decodable{
    public var id: Int
    public var jsonrpc = "2.0"
    public var result: Any?
    public var error: ErrorMessage?
    public var message: String?

    enum JSONRPCresponseKeys: String, CodingKey {
        case id = "id"
        case jsonrpc = "jsonrpc"
        case result = "result"
        case error = "error"
    }

    public init(id: Int, jsonrpc: String, result: Any?, error: ErrorMessage?) {
        self.id = id
        self.jsonrpc = jsonrpc
        self.result = result
        self.error = error
    }

    public struct ErrorMessage: Decodable {
        public var code: Int
        public var message: String
    }

    internal var decodableTypes: [Decodable.Type] = [
        [EventLog].self,
        [TransactionDetails].self,
        [TransactionReceipt].self,
        [Block].self,
        [String].self,
        [Int].self,
        [Bool].self,
        EventLog.self,
        TransactionDetails.self,
        TransactionReceipt.self,
        Block.self,
        String.self,
        Int.self,
        Bool.self,
        [String: String].self,
        [String: Int].self,
        [String: [String: [String: [String]]]].self,
        Web3.Oracle.FeeHistory.self
    ]

    // FIXME: Make me a real generic
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONRPCresponseKeys.self)
        let id: Int = try container.decode(Int.self, forKey: .id)
        let jsonrpc: String = try container.decode(String.self, forKey: .jsonrpc)
        let errorMessage = try container.decodeIfPresent(ErrorMessage.self, forKey: .error)
        if errorMessage != nil {
            self.init(id: id, jsonrpc: jsonrpc, result: nil, error: errorMessage)
            return
        }
        // TODO: make me generic (DecodableFromHex or Decodable)
        /// This is all available types of `result` to init
        /// Now its type is `Any?`, since you're typecasting this any to exact each response,
        /// coz you're knowing response to what request it would be,
        /// and you're could be sure about API Response structure.
        ///
        /// So since we're typecasting this explicitly each tyme, `result` property could be set
        /// to protocol type like `Decodable` or `DevodableFromHex` or something,
        /// and this code could be reduced so hard.
        var result: Any? = nil
        if let rawValue = try? container.decodeIfPresent(String.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(Int.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(Bool.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(EventLog.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(Block.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(TransactionReceipt.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(TransactionDetails.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([EventLog].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([Block].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([TransactionReceipt].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([TransactionDetails].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(TxPoolStatus.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(TxPoolContent.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([Bool].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([Int].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String: String].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String: Int].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String: [String: [String: String]]].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String: [String: [String: [String: String?]]]].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(Web3.Oracle.FeeHistory.self, forKey: .result) {
            result = rawValue
        }
        self.init(id: id, jsonrpc: jsonrpc, result: result, error: nil)
    }

    // FIXME: Make me a real generic
    // MARK: - This fits for DecodableFromHex
    /// Get the JSON RCP reponse value by deserializing it into some native <T> class.
    ///
    /// Returns nil if serialization fails
    public func getValue<T>() -> T? {
        let type = T.self

        if type == BigUInt.self {
            guard let string = self.result as? String else {return nil}
            guard let value = BigUInt(string.stripHexPrefix(), radix: 16) else {return nil}
            return value as? T
        } else if type == BigInt.self {
            guard let string = self.result as? String else {return nil}
            guard let value = BigInt(string.stripHexPrefix(), radix: 16) else {return nil}
            return value as? T
        } else if type == Data.self {
            guard let string = self.result as? String else {return nil}
            guard let value = Data.fromHex(string) else {return nil}
            return value as? T
        } else if type == EthereumAddress.self {
            guard let string = self.result as? String else {return nil}
            guard let value = EthereumAddress(string, ignoreChecksum: true) else {return nil}
            return value as? T
        }
//        else if slf == String.self {
//            guard let value = self.result as? T else {return nil}
//            return value
//        } else if slf == Int.self {
//            guard let value = self.result as? T else {return nil}
//            return value
//        }
        else if type == [BigUInt].self {
            guard let string = self.result as? [String] else {return nil}
            let values = string.compactMap { (str) -> BigUInt? in
                return BigUInt(str.stripHexPrefix(), radix: 16)
            }
            return values as? T
        } else if type == [BigInt].self {
            guard let string = self.result as? [String] else {return nil}
            let values = string.compactMap { (str) -> BigInt? in
                return BigInt(str.stripHexPrefix(), radix: 16)
            }
            return values as? T
        } else if type == [Data].self {
            guard let string = self.result as? [String] else {return nil}
            let values = string.compactMap { (str) -> Data? in
                return Data.fromHex(str)
            }
            return values as? T
        } else if type == [EthereumAddress].self {
            guard let string = self.result as? [String] else {return nil}
            let values = string.compactMap { (str) -> EthereumAddress? in
                return EthereumAddress(str, ignoreChecksum: true)
            }
            return values as? T
        }
        guard let value = self.result as? T  else {return nil}
        return value
    }
}

/// JSON RPC batch response structure for serialization and deserialization purposes.
public struct JSONRPCresponseBatch: Decodable {
    var responses: [JSONRPCresponse]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let responses = try container.decode([JSONRPCresponse].self)
        self.responses = responses
    }
}

/// Transaction parameters JSON structure for interaction with Ethereum node.
public struct TransactionParameters: Codable {
    /// accessList parameter JSON structure
    public struct AccessListEntry: Codable {
        public var address: String
        public var storageKeys: [String]
    }

    public var type: String?  // must be set for new EIP-2718 transaction types
    public var chainID: String?
    public var data: String?
    public var from: String?
    public var gas: String?
    public var gasPrice: String? // Legacy & EIP-2930
    public var maxFeePerGas: String? // EIP-1559
    public var maxPriorityFeePerGas: String? // EIP-1559
    public var accessList: [AccessListEntry]? // EIP-1559 & EIP-2930
    public var to: String?
    public var value: String? = "0x0"

    public init(from _from: String?, to _to: String?) {
        from = _from
        to = _to
    }
}

/// Event filter parameters JSON structure for interaction with Ethereum node.
public struct EventFilterParameters: Codable {
    public var fromBlock: String?
    public var toBlock: String?
    public var topics: [[String?]?]?
    public var address: [String?]?
}

/**
 Enum to compose request to the node params.

 In most cases request params are passed to Ethereum JSON RPC request as array of mixed type values, such as `[12,"this",true]`,
 thus this is not appropriate API design we have what we have.

 Meanwhile swift don't provide strict way to compose such array it gives some hacks to solve this task
 and one of them is using `RawRepresentable` protocol.

 Conforming this protocol gives designated type ability to represent itself in `String` representation in any way.

 So in our case we're using such to implement custom `encode` method to any used in node request params types.

 Latter is required to encode array of `JSONRPCParameter` to not to `[JSONRPCParameter.int(1)]`, but to `[1]`.

 Here's an example of using this enum in field.
 ```swift
 let jsonRPCParams: [JSONRPCParameter] = [
    .init(rawValue: 12)!,
    .init(rawValue: "this")!,
    .init(rawValue: 12.2)!,
    .init(rawValue: [12.2, 12.4])!
 ]
 let encoded = try JSONEncoder().encode(jsonRPCParams)
 print(String(data: encoded, encoding: .utf8)!)
 //> [12,\"this\",12.2,[12.2,12.4]]`
 ```
 */
public enum JSONRPCParameter {
    case int(Int)
    case intArray([Int])

    case double(Double)
    case doubleArray([Double])

    case string(String)
    case stringArray([String])

    case bool(Bool)
    case transaction(TransactionParameters)
    case eventFilter(EventFilterParameters)
}


extension JSONRPCParameter: RawRepresentable {
    /**
     This init required by `RawRepresentable` protocol, which is requred to encode mixed type values array in JSON.

     This protocol used to implement custom `encode` method for that enum,
     which is encodes array of self into array of self assotiated values.

     You're totally free to use explicit and more convenience member init as `JSONRPCParameter.int(12)` in your code.
     */
    public init?(rawValue: Encodable) {
        /// force casting in this switch is safe because
        /// each `rawValue` forced to casts only in exact case which is runs based on `rawValues` type
        // swiftlint:disable force_cast
        switch type(of: rawValue) {
        case is Int.Type: self = .int(rawValue as! Int)
        case is [Int].Type: self = .intArray(rawValue as! [Int])

        case is String.Type: self = .string(rawValue as! String)
        case is [String].Type: self = .stringArray(rawValue as! [String])

        case is Double.Type: self = .double(rawValue as! Double)
        case is [Double].Type: self = .doubleArray(rawValue as! [Double])

        case is Bool.Type: self = .bool(rawValue as! Bool)
        case is TransactionParameters.Type: self = .transaction(rawValue as! TransactionParameters)
        case is EventFilterParameters.Type: self = .eventFilter(rawValue as! EventFilterParameters)
        default: return nil
        }
        // swiftlint:enable force_cast
    }

    /// Returning associated value of the enum case only.
    public var rawValue: Encodable {
        // cases can't be merged, coz it cause compiler error since it couldn't predict what exact type on exact case will be returned.
        switch self {
        case let .int(value): return value
        case let .intArray(value): return value

        case let .string(value): return value
        case let .stringArray(value): return value

        case let .double(value): return value
        case let .doubleArray(value): return value

        case let .bool(value): return value
        case let .transaction(value): return value
        case let .eventFilter(value): return value
        }
    }
}

extension JSONRPCParameter: Encodable {
    /**
     This encoder encodes `JSONRPCParameter` assotiated value ignoring self value

     This is required to encode mixed types array, like

     ```swift
     let someArray: [JSONRPCParameter] = [
        .init(rawValue: 12)!,
        .init(rawValue: "this")!,
        .init(rawValue: 12.2)!,
        .init(rawValue: [12.2, 12.4])!
     ]
     let encoded = try JSONEncoder().encode(someArray)
     print(String(data: encoded, encoding: .utf8)!)
     //> [12,\"this\",12.2,[12.2,12.4]]`
     ```
     */
    public func encode(to encoder: Encoder) throws {
        var enumContainer = encoder.singleValueContainer()
        /// force casting in this switch is safe because
        /// each `rawValue` forced to casts only in exact case which is runs based on `rawValue` type
        // swiftlint:disable force_cast
        switch type(of: self.rawValue) {
        case is Int.Type: try enumContainer.encode(rawValue as! Int)
        case is [Int].Type: try enumContainer.encode(rawValue as! [Int])

        case is String.Type: try enumContainer.encode(rawValue as! String)
        case is [String].Type: try enumContainer.encode(rawValue as! [String])

        case is Double.Type: try enumContainer.encode(rawValue as! Double)
        case is [Double].Type: try enumContainer.encode(rawValue as! [Double])

        case is Bool.Type: try enumContainer.encode(rawValue as! Bool)
        case is TransactionParameters.Type: try enumContainer.encode(rawValue as! TransactionParameters)
        case is EventFilterParameters.Type: try enumContainer.encode(rawValue as! EventFilterParameters)
        default: break
        }
        // swiftlint:enable force_cast
    }
}
