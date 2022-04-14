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
public struct JSONRPCrequest: Encodable {
    public var jsonrpc: String = "2.0"
    public var method: JSONRPCmethod?
    public var params: JSONRPCparams?
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
            return method.requiredNumOfParameters == self.params?.params.count
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
        // TODO: refactor me
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

/// Raw JSON RCP 2.0 internal flattening wrapper.
public struct JSONRPCparams: Encodable{
    // TODO: Rewrite me to generic
    public var params = [Any]()

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for par in params {
            if let p = par as? TransactionParameters {
                try container.encode(p)
            } else if let p = par as? String {
                try container.encode(p)
            } else if let p = par as? Bool {
                try container.encode(p)
            } else if let p = par as? EventFilterParameters {
                try container.encode(p)
            } else if let p = par as? [Double] {
                try container.encode(p)
            }
        }
    }
}
