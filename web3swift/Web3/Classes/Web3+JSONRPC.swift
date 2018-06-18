//
//  Web3+JSONRPC.swift
//  web3swift
//
//  Created by Alexander Vlasov on 21.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import Alamofire
import BigInt

public struct Counter {
    public static var counter = UInt64(1)
    public static var lockQueue = DispatchQueue(label: "counterQueue")
    public static func increment() -> UInt64 {
        var c:UInt64 = 0
        lockQueue.sync {
            c = Counter.counter
            Counter.counter = Counter.counter + 1
        }
        return c
    }
}


public struct JSONRPCrequest: Encodable, ParameterEncoding  {
    var jsonrpc: String = "2.0"
    var method: JSONRPCmethod?
    var params: JSONRPCparams?
    var id: UInt64 = Counter.increment()
    
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
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        let jsonSerialization = try JSONEncoder().encode(self)
        var request = try urlRequest.asURLRequest()
        request.httpBody = jsonSerialization
        return request
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

public struct JSONRPCrequestBatch: Encodable, ParameterEncoding  {
    var requests: [JSONRPCrequest]
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        let jsonSerialization = try JSONEncoder().encode(requests)
        var request = try urlRequest.asURLRequest()
        request.httpBody = jsonSerialization
        return request
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.requests)
    }
}

public struct JSONRPCresponse: Decodable{
    public var id: Int
    public var jsonrpc = "2.0"
    public var result: Any?
    public var error: String?
    public var message: String?
    
    enum JSONRPCresponseKeys: String, CodingKey {
        case id = "id"
        case jsonrpc = "jsonrpc"
        case result = "result"
        case error = "error"
        case message = "message"
    }
    
    public init(id: Int, jsonrpc: String, result: Any?, error: String?, message: String?) {
        self.id = id
        self.jsonrpc = jsonrpc
        self.result = result
        self.error = error
        self.message = message
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONRPCresponseKeys.self)
        let id: Int = try container.decode(Int.self, forKey: .id)
        let jsonrpc: String = try container.decode(String.self, forKey: .jsonrpc)
        let error: String? = try container.decodeIfPresent(String.self, forKey: .error)
        let message: String? = try container.decodeIfPresent(String.self, forKey: .message)
        var result: Any? = nil
        if let rawValue = try? container.decodeIfPresent(String.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(Int.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String: String].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String: Int].self, forKey: .result) {
            result = rawValue
        }
        self.init(id: id, jsonrpc: jsonrpc, result: result, error: error, message: message)
    }
    
    public func getValue<T>() -> T? {
        let slf = T.self
        if slf == BigUInt.self {
            guard let string = self.result as? String else {return nil}
            guard let value = BigUInt(string.stripHexPrefix(), radix: 16) else {return nil}
            return value as? T
        } else if slf == BigInt.self {
            guard let string = self.result as? String else {return nil}
            guard let value = BigInt(string.stripHexPrefix(), radix: 16) else {return nil}
            return value as? T
        } else if slf == Data.self {
            guard let string = self.result as? String else {return nil}
            guard let value = Data.fromHex(string) else {return nil}
            return value as? T
        } else if slf == EthereumAddress.self {
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
        else if slf == [BigUInt].self {
            guard let string = self.result as? [String] else {return nil}
            let values = string.compactMap { (str) -> BigUInt? in
                return BigUInt(str.stripHexPrefix(), radix: 16)
            }
            return values as? T
        } else if slf == [BigInt].self {
            guard let string = self.result as? [String] else {return nil}
            let values = string.compactMap { (str) -> BigInt? in
                return BigInt(str.stripHexPrefix(), radix: 16)
            }
            return values as? T
        } else if slf == [Data].self {
            guard let string = self.result as? [String] else {return nil}
            let values = string.compactMap { (str) -> Data? in
                return Data.fromHex(str)
            }
            return values as? T
        } else if slf == [EthereumAddress].self {
            guard let string = self.result as? [String] else {return nil}
            let values = string.compactMap { (str) -> EthereumAddress? in
                return EthereumAddress(str, ignoreChecksum: true)
            }
            return values as? T
        }
//        else if slf == [String].self {
//            guard let value = self.result as? T else {return nil}
//            return value
//        } else if slf == [Int].self {
//            guard let value = self.result as? T else {return nil}
//            return value
//        } else if slf == [String: String].self{
//            guard let value = self.result as? T else {return nil}
//            return value
//        }
//        else if slf == [String: AnyObject].self{
//            guard let value = self.result as? T else {return nil}
//            return value
//        } else if slf == [String: Any].self{
//            guard let value = self.result as? T else {return nil}
//            return value
//        }
        guard let value = self.result as? T  else {return nil}
        return value
    }
}

public struct JSONRPCresponseBatch: Decodable {
    var responses: [JSONRPCresponse]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let responses = try container.decode([JSONRPCresponse].self)
        self.responses = responses
    }
}

public struct TransactionParameters: Codable {
    public var data: String?
    public var from: String?
    public var gas: String?
    public var gasPrice: String?
    public var to: String?
    public var value: String? = "0x0"
    
    public init(from _from:String?, to _to:String?) {
        from = _from
        to = _to
    }
}

public struct EventFilterParameters: Codable {
    public var fromBlock: String?
    public var toBlock: String?
    public var topics: [[String?]?]?
    public var address: [String?]?
}

public struct JSONRPCparams: Encodable{
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
            }
        }
    }
}
