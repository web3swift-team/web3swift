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

        guard 200 ..< 400 ~= response.statusCode else {
            if 400 ..< 500 ~= response.statusCode {
                throw Web3Error.clientError(code: response.statusCode)
            } else {
                throw Web3Error.serverError(code: response.statusCode)
            }
        }

        if let error = (try? JSONDecoder().decode(JsonRpcErrorObject.self, from: data))?.error {
            guard let parsedErrorCode = error.parsedErrorCode else {
                throw Web3Error.nodeError(desc: "\(error.message)\nError code: \(error.code)")
            }
            let description = "\(parsedErrorCode.errorName). Error code: \(error.code). \(error.message)"
            switch parsedErrorCode {
            case .parseError, .invalidParams:
                throw Web3Error.inputError(desc: description)
            case .methodNotFound, .invalidRequest:
                throw Web3Error.processingError(desc: description)
            case .internalError, .serverError:
                throw Web3Error.nodeError(desc: description)
            }
        }

        return try initalizeLiteralTypeApiResponse(data) ?? JSONDecoder().decode(APIResponse<Result>.self, from: data)
    }

    /// Attempts decoding and parsing of a response into literal types as `Data`, `(U)Int`, `Big(U)Int`.
    /// - Parameter data: response to parse.
    /// - Returns: parsed response or `nil`. Throws ``Web3Error``.
    internal static func initalizeLiteralTypeApiResponse<Result>(_ data: Data) throws -> APIResponse<Result>? {
        guard let LiteralType = Result.self as? LiteralInitiableFromString.Type else {
            return nil
        }
        guard let responseAsString = try? JSONDecoder().decode(APIResponse<String>.self, from: data) else {
            throw Web3Error.dataError(desc: "Failed to decode received data as `APIResponse<String>`. Given data: \(data.toHexString().addHexPrefix()).")
        }
        guard let literalValue = LiteralType.init(from: responseAsString.result) else {
            throw Web3Error.dataError(desc: "Failed to initialize \(LiteralType.self) from String `\(responseAsString.result)`.")
        }
        /// `literalValue` conforms `LiteralInitiableFromString`, that conforming to an `APIResultType` type, so it's never fails.
        guard let result = literalValue as? Result else {
            throw Web3Error.typeError(desc: "Initialized value of type \(LiteralType.self) cannot be cast as \(Result.self).")
        }
        return APIResponse(id: responseAsString.id, jsonrpc: responseAsString.jsonrpc, result: result)
    }
}

/// JSON RPC Error object. See official specification https://www.jsonrpc.org/specification#error_object
private struct JsonRpcErrorObject: Decodable {
    public let error: RpcError?

    class RpcError: Decodable {
        let message: String
        let code: Int
        var parsedErrorCode: JsonRpcErrorCode? {
            JsonRpcErrorCode.from(code)
        }
    }
}

/// For error codes specification see chapter `5.1 Error object`
/// https://www.jsonrpc.org/specification#error_object
private enum JsonRpcErrorCode {
    /// -32700
    /// Invalid JSON was received by the server. An error occurred on the server while parsing the JSON
    case parseError
    /// -32600
    /// The JSON sent is not a valid Request object.
    case invalidRequest
    /// -32601
    /// The method does not exist / is not available.
    case methodNotFound
    /// -32602
    /// Invalid method parameter(s).
    case invalidParams
    /// -32603
    /// Internal JSON-RPC error.
    case internalError
    /// Values in range of -32000 to -32099
    /// Reserved for implementation-defined server-errors.
    case serverError(Int)

    var errorName: String {
        switch self {
        case .parseError:
            return "Parsing error"
        case .invalidRequest:
            return "Invalid request"
        case .methodNotFound:
            return "Method not found"
        case .invalidParams:
            return "Invalid parameters"
        case .internalError:
            return "Internal error"
        case .serverError:
            return "Server error"
        }
    }

    static func from(_ code: Int) -> JsonRpcErrorCode? {
        switch code {
        case -32700:
            return .parseError
        case -32600:
            return .invalidRequest
        case -32601:
            return .methodNotFound
        case -32602:
            return .invalidParams
        case -32603:
            return .internalError
        default:
            if (-32099)...(-32000) ~= code {
                return .serverError(code)
            }
            return nil
        }
    }
}
