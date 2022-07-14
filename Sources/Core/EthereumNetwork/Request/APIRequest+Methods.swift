//
//  APIRequest+Methods.swift
//  
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation
import BigInt

extension APIRequest {
    public static func sendRequest<Result>(with provider: Web3Provider, for call: APIRequest) async throws -> APIResponse<Result> {
        let request = setupRequest(for: call, with: provider)
        return try await APIRequest.send(uRLRequest: request, with: provider.session)
    }

    static func setupRequest(for call: APIRequest, with provider: Web3Provider) -> URLRequest {
        var urlRequest = URLRequest(url: provider.url, cachePolicy: .reloadIgnoringCacheData)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpMethod = call.method.rawValue
        urlRequest.httpBody = call.encodedBody
        return urlRequest
    }
    
    public static func send<Result>(uRLRequest: URLRequest, with session: URLSession) async throws -> APIResponse<Result> {
        let (data, response) = try await session.data(for: uRLRequest)

        guard 200 ..< 400 ~= response.statusCode else { throw Web3Error.serverError(code: response.statusCode) }

        /// This bit of code is purposed to work with literal types that comes in Response in hexString type.
        /// Currently it's just `Data` and any kind of Integers `(U)Int`, `Big(U)Int`.
        if Result.self == Data.self || Result.self == UInt.self || Result.self == Int.self || Result.self == BigInt.self || Result.self == BigUInt.self {
            guard let Literal = Result.self as? LiteralInitiableFromString.Type else { throw Web3Error.typeError }
            guard let responseAsString = try? JSONDecoder().decode(APIResponse<String>.self, from: data) else { throw Web3Error.dataError }
            guard let literalValue = Literal.init(from: responseAsString.result) else { throw Web3Error.dataError }
            /// `Literal` conforming `LiteralInitiableFromString`, that conforming to an `APIResponseType` type, so it's never fails.
            guard let result = literalValue as? Result else { throw Web3Error.typeError }
            return APIResponse(id: responseAsString.id, jsonrpc: responseAsString.jsonrpc, result: result)
        }
        return try JSONDecoder().decode(APIResponse<Result>.self, from: data)
    }
}
