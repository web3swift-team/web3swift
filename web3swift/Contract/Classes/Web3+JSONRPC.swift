//
//  Web3+JSONRPC.swift
//  web3swift
//
//  Created by Alexander Vlasov on 21.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import Alamofire

public struct JSONRPCrequest: Encodable, ParameterEncoding  {
    var jsonrpc: String = "2.0"
    var method: JSONRPCmethod?
    var params: JSONRPCparams?
    var id: Int = Int(floor(Date().timeIntervalSince1970))
    
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
            return method.requiredNumOfParameter == self.params?.params.count
        }
    }
}


public struct TransactionParameters: Codable {
    public var data: String?
    public var from: String
    public var gas: String?
    public var gasPrice: String?
    public var to: String
    public var value: String? = "0x0"
    
    public init(from _from:String, to _to:String) {
        from = _from
        to = _to
    }
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
            }
        }
    }
}
