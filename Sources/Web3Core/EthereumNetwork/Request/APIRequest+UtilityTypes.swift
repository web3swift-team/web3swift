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

enum REST: String {
    case POST
    case GET
}

struct RequestBody: Encodable {
    var jsonrpc = "2.0"
    var id = Counter.increment()

    var method: String
    var params: [RequestParameter]
}
