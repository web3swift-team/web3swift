//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

/// Providers abstraction for custom providers (websockets, other custom private key managers). At the moment should not be used.
public protocol Web3NetworkProvider {
    var network: Networks? {get set}
    var attachedKeystoreManager: KeystoreManager? {get set}
    var url: URL {get}
    var session: URLSession {get}
}

public protocol Web3Provider: Web3NetworkProvider {
    func sendAsync(_ request: JSONRPCrequest) async throws -> JSONRPCresponse
    func sendAsync(_ requests: JSONRPCrequestBatch) async throws -> JSONRPCresponseBatch
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
    public init(_ httpProviderURL: URL, network net: Networks? = nil, keystoreManager manager: KeystoreManager? = nil) async throws {
        do {
            guard httpProviderURL.scheme == "http" || httpProviderURL.scheme == "https" else {throw Web3Error.dataError}
            url = httpProviderURL
            if net == nil {
                let request = JSONRPCRequestFabric.prepareRequest(.getNetwork, parameters: [])
                let response = try await post(request)
                guard response.error == nil else {
                    throw Web3Error.dataError
                }
                guard let result: String = response.getValue(), let intNetworkNumber = Int(result) else {throw Web3Error.dataError}
                network = Networks.fromInt(intNetworkNumber)
                if network == nil {throw Web3Error.dataError}
            } else {
                network = net
            }
        } catch {
            throw Web3Error.dataError
        }
        attachedKeystoreManager = manager
    }

    public init(_ httpProviderURL: URL, network net: Networks, keystoreManager manager: KeystoreManager? = nil) throws {
        guard httpProviderURL.scheme == "http" || httpProviderURL.scheme == "https" else {throw Web3Error.dataError}
        url = httpProviderURL
        network = net
        attachedKeystoreManager = manager
    }

    public func sendAsync(_ request: JSONRPCrequest) async throws -> JSONRPCresponse {
        if request.method == nil {
            throw Web3Error.nodeError(desc: "RPC method is nill")
        }

        return try await post(request)
    }

    public func sendAsync(_ requests: JSONRPCrequestBatch) async throws -> JSONRPCresponseBatch {
        try await post(requests)
    }
}

extension Web3HttpProvider {

    func post<T: Encodable>(request: T, providerURL: URL, session: URLSession) async throws -> Data {
        let encoder = JSONEncoder()
        let requestData = try encoder.encode(request)
        var urlRequest = URLRequest(url: providerURL, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpBody = requestData
        let (data, _) = try await session.data(for: urlRequest, delegate: nil)

        return data
    }

    func post(_ request: JSONRPCrequest) async throws -> JSONRPCresponse {
        let data: Data = try await post(request: request, providerURL: url, session: session)

        let parsedResponse = try JSONDecoder().decode(JSONRPCresponse.self, from: data)
        if let parsedResponseerror = parsedResponse.error  {
            throw Web3Error.nodeError(desc: "Received an error message from node\n" + String(describing: parsedResponseerror))
        }
        return parsedResponse
   }

    func post(_ request: JSONRPCrequestBatch) async throws -> JSONRPCresponseBatch {
        let data: Data = try await post(request: request, providerURL: url, session: session)
        let parsedResponse = try JSONDecoder().decode(JSONRPCresponseBatch.self, from: data)
        return parsedResponse

    }
}


