//
//  APIRequest+UtilityTypes.swift
//
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation

/// JSON RPC response structure for serialization and deserialization purposes.
public struct APIResponse<Result>: Decodable where Result: APIResultType {
    public var id: Int
    public var jsonrpc = "2.0"
    public var result: Result
}

public enum REST: String {
    case POST
    case GET
}

struct RequestBody: Encodable {
    var jsonrpc = "2.0"
    var id = Counter.increment()

    var method: String
    var params: [Encodable]

    enum CodingKeys: String, CodingKey {
        case jsonrpc
        case id
        case method
        case params
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encode(id, forKey: .id)
        try container.encode(method, forKey: .method)

        var paramsContainer = container.superEncoder(forKey: .params).unkeyedContainer()
        try params.forEach { a in
            try paramsContainer.encode(a)
        }
    }

    public var encodedBody: Data {
         // Safe to use force-try because request will fail to
         // compile if it's not conforming to the `Encodable` protocol.
         return try! JSONEncoder().encode(self)
     }
}
