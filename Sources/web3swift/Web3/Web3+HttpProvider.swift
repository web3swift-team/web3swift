//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

/// Providers abstraction for custom providers (websockets, other custom private key managers). At the moment should not be used.
public protocol Web3Provider {
    func sendAsync(_ request: JSONRPCrequest) async throws -> JSONRPCresponse
    func sendAsync(_ requests: JSONRPCrequestBatch) async throws -> JSONRPCresponseBatch

    var network: Networks? {get set}
    var attachedKeystoreManager: KeystoreManager? {get set}
    var url: URL {get}
    var session: URLSession {get}
}

/// The default http provider.
public class Web3HttpProvider: Web3Provider {
    public var url: URL
    public var network: Networks?
    public var attachedKeystoreManager: KeystoreManager?
    public var session: URLSession = {() -> URLSession in
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config)
        return urlSession
    }()

    public init?(_ httpProviderURL: URL, network net: Networks? = nil, keystoreManager manager: KeystoreManager? = nil) async {
        do {
            guard httpProviderURL.scheme == "http" || httpProviderURL.scheme == "https" else {
                return nil
            }
            url = httpProviderURL
            if net == nil {
                let request = JSONRPCRequestFabric.prepareRequest(.getNetwork, parameters: [])
                let response: JSONRPCresponse = try await Web3HttpProvider.post(request, providerURL: httpProviderURL, session: session)
                if response.error != nil {
                    if response.message != nil {
                        print(response.message!)
                    }
                    return nil
                }
                guard let result: String = response.getValue(), let intNetworkNumber = Int(result) else {return nil}
                network = Networks.fromInt(intNetworkNumber)
                if network == nil {
                    return nil
                }
            } else {
                network = net
            }
        } catch {
            return nil
        }
        attachedKeystoreManager = manager
    }

    static func post<T: Decodable, U: Encodable>(_ request: U, providerURL: URL, session: URLSession) async throws -> T {

        let requestData = try JSONEncoder().encode(request)
        var urlRequest = URLRequest(url: providerURL, cachePolicy: .reloadIgnoringCacheData)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpBody = requestData

        let (data, _) = try await session.data(for: urlRequest)

        let parsedResponse = try JSONDecoder().decode(T.self, from: data)

        if let response = parsedResponse as? JSONRPCresponse, response.error != nil {
            throw Web3Error.nodeError(desc: "Received an error message from node\n" + String(describing: response.error!))
        }
        return parsedResponse

    }

    public func sendAsync(_ request: JSONRPCrequest) async throws -> JSONRPCresponse {
        guard request.method != nil else {
            throw Web3Error.nodeError(desc: "RPC method is nill")
        }

        return try await Web3HttpProvider.post(request, providerURL: self.url, session: self.session)
    }

    public func sendAsync(_ requests: JSONRPCrequestBatch) async throws -> JSONRPCresponseBatch {
        return try await Web3HttpProvider.post(requests, providerURL: self.url, session: self.session)
    }
}
