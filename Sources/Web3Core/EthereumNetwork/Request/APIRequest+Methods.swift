//
//  APIRequest+Methods.swift
//
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation
import BigInt

/// TODO: should we do more error explain like ethers.js?
/// https://github.com/ethers-io/ethers.js/blob/0bfa7f497dc5793b66df7adfb42c6b846c51d794/packages/providers/src.ts/json-rpc-provider.ts#L55
func checkError(method: String, error: JsonRpcErrorObject.RpcError) throws -> String {
    if method == "eth_call" {
        if let result = spelunkData(value: error) {
            return result.data
        }
        throw Web3Error.nodeError(desc: "Error data decoding failed: missing revert data in exception; Transaction reverted without a reason string.")
    }

    throw Web3Error.nodeError(desc: error.message)
}

func spelunkData(value: Any?) -> (message: String, data: String)? {
    if (value == nil) {
        return nil
    }

    func spelunkRpcError(_ message: String, data: String) -> (message: String, data: String)? {
        if message.contains("revert") && data.isHex {
            return (message, data)
        } else {
            return nil
        }
    }

    if let error = value as? JsonRpcErrorObject.RpcError {
        if let data = error.data as? String {
            return spelunkRpcError(error.message, data: data)
        } else {
            return spelunkData(value: error.data)
        }
    }

    // Spelunk further...
    if let object = value as? [String: Any] {
        if let message = object["message"] as? String,
           let data = object["data"] as? String {
            return spelunkRpcError(message, data: data)
        }

        for value in object.values {
            if let result = spelunkData(value: value) {
                return result
            }
            return nil
        }
    }
    if let array = value as? [Any] {
        for e in array {
            if let result = spelunkData(value: e) {
                return result
            }
            return nil
        }
    }

    // Might be a JSON string we can further descend...
    if let string = value as? String, let data = string.data(using: .utf8) {
        let json = try? JSONSerialization.jsonObject(with: data)
        return spelunkData(value: json)
    }

    return nil
}

extension APIRequest {
    public static func sendRequest<Result>(with provider: Web3Provider, for call: APIRequest) async throws -> APIResponse<Result> {
        try await send(call.call, parameters: call.parameters, with: provider)
    }

    static func setupRequest(for body: RequestBody, with provider: Web3Provider) -> URLRequest {
        var urlRequest = URLRequest(url: provider.url, cachePolicy: .reloadIgnoringCacheData)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = body.encodedBody
        return urlRequest
    }

    public static func send<Result>(_ method: String, parameters: [Encodable], with provider: Web3Provider) async throws -> APIResponse<Result> {
        let body = RequestBody(method: method, params: parameters)
        let uRLRequest = setupRequest(for: body, with: provider)

        let data: Data
        do {
            data = try await send(uRLRequest: uRLRequest, with: provider.session)
        } catch Web3Error.rpcError(let error) {
            let responseAsString = try checkError(method: method, error: error)
            guard let LiteralType = Result.self as? LiteralInitiableFromString.Type,
                  let literalValue = LiteralType.init(from: responseAsString),
                  let result = literalValue as? Result else {
                throw Web3Error.dataError
            }
            return APIResponse(id: 2, result: result)
        }

        /// Checks if `Result` type can be initialized from HEX-encoded bytes.
        /// If it can - we attempt initializing a value of `Result` type.
        if let LiteralType = Result.self as? LiteralInitiableFromString.Type {
            guard let responseAsString = try? JSONDecoder().decode(APIResponse<String>.self, from: data) else { throw Web3Error.dataError }
            guard let literalValue = LiteralType.init(from: responseAsString.result) else { throw Web3Error.dataError }
            /// `literalValue` conforms `LiteralInitiableFromString` (which conforms to an `APIResponseType` type) so it never fails.
            guard let result = literalValue as? Result else { throw Web3Error.typeError }
            return APIResponse(id: responseAsString.id, jsonrpc: responseAsString.jsonrpc, result: result)
        }
        return try JSONDecoder().decode(APIResponse<Result>.self, from: data)
    }

    public static func send(uRLRequest: URLRequest, with session: URLSession) async throws -> Data {
        let (data, response) = try await session.data(for: uRLRequest)

        guard 200 ..< 400 ~= response.statusCode else {
            if 400 ..< 500 ~= response.statusCode {
                throw Web3Error.clientError(code: response.statusCode)
            } else {
                throw Web3Error.serverError(code: response.statusCode)
            }
        }

        if let error = JsonRpcErrorObject.init(from: data)?.error {
            guard let parsedErrorCode = error.parsedErrorCode else {
                throw Web3Error.rpcError(error)
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

        return data
    }
}

/// JSON RPC Error object. See official specification https://www.jsonrpc.org/specification#error_object
public struct JsonRpcErrorObject {
    public let error: RpcError?

    public class RpcError {
        public let message: String
        public let code: Int
        public let data: Any?

        init(message: String, code: Int, data: Any?) {
            self.message = message
            self.code = code
            self.data = data
        }

        var parsedErrorCode: JsonRpcErrorCode? {
            JsonRpcErrorCode.from(code)
        }
    }

    init?(from data: Data) {
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        if let error = root["error"] as? [String: Any],
           let message = error["message"] as? String,
           let code = error["code"] as? Int {
            guard let errorData = error["data"] else {
                self.error = RpcError(message: message, code: code, data: nil)
                return
            }
            self.error = RpcError(message: message, code: code, data: errorData)
        } else {
            self.error = nil
        }
    }
}

/// For error codes specification see chapter `5.1 Error object`
/// https://www.jsonrpc.org/specification#error_object
enum JsonRpcErrorCode {
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
