//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt


/// Providers abstraction for custom providers (websockets, other custom private key managers). At the moment should not be used.
public protocol Web3Provider {
//    func sendAsync(_ request: JSONRPCrequest) async throws -> JSONRPCresponse
//    func sendAsync(_ requests: JSONRPCrequestBatch) async throws -> JSONRPCresponseBatch
    var network: Networks? {get set}
    var attachedKeystoreManager: KeystoreManager? {get set}
    var url: URL {get}
    var session: URLSession {get}
}

/// The default http provider.
public class Web3HttpProvider: Web3Provider {
    public var url: URL
    public var network: Networks?
    public var attachedKeystoreManager: KeystoreManager? = nil
    public var session: URLSession = {() -> URLSession in
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config)
        return urlSession
    }()
    public init?(_ httpProviderURL: URL, network net: Networks, keystoreManager manager: KeystoreManager? = nil) {
        guard httpProviderURL.scheme == "http" || httpProviderURL.scheme == "https" else { return nil }
        url = httpProviderURL
        network = net
        attachedKeystoreManager = manager
    }

//    fileprivate static func dataFrom(session: URLSession, request urlRequest: URLRequest) async throws -> Data{
//        let (data, _) = try await session.data(for: urlRequest)
//        return data
//    }
//
//    static func post<T: Decodable, U: Encodable>(_ request: U, providerURL: URL, session: URLSession) async throws -> T {
//        let requestData = try JSONEncoder().encode(request)
//        var urlRequest = URLRequest(url: providerURL, cachePolicy: .reloadIgnoringCacheData)
//        urlRequest.httpMethod = "POST"
//        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
//        urlRequest.httpBody = requestData
//
//        let data = try await dataFrom(session: session, request: urlRequest)
//
//        let parsedResponse = try JSONDecoder().decode(T.self, from: data)
//
//        if let response = parsedResponse as? JSONRPCresponse, response.error != nil {
//            throw Web3Error.nodeError(desc: "Received an error message from node\n" + String(describing: response.error!))
//        }
//        return parsedResponse
//
//    }
//
//    public func sendAsync(_ request: JSONRPCrequest) async throws -> JSONRPCresponse {
//        guard request.method != nil else {
//            throw Web3Error.nodeError(desc: "RPC method is nill")
//        }
//
//        return try await Web3HttpProvider.post(request, providerURL: self.url, session: self.session)
//    }

//    public func sendAsync(_ requests: JSONRPCrequestBatch) async throws -> JSONRPCresponseBatch {
//        return try await Web3HttpProvider.post(requests, providerURL: self.url, session: self.session)
//    }
}


@available(iOS, obsoleted: 15.0, message: "Use the built-in API instead")
@available(macOS, obsoleted: 12.0, message: "Use the built-in API instead")
extension URLSession {
    func data(fromUrl url: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        var dataTask: URLSessionDataTask?

        return try await withCheckedThrowingContinuation { continuation in
            dataTask = self.dataTask(with: request) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                continuation.resume(returning: (data, response))
            }
            dataTask?.resume()
        }
    }
}
