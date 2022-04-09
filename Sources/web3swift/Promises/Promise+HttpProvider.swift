//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation


extension Web3HttpProvider {

    static func post<T: Decodable, U: Encodable>(_ request: U, providerURL: URL, session: URLSession) async throws -> T {

        let requestData = try JSONEncoder().encode(request)
        var urlRequest = URLRequest(url: providerURL, cachePolicy: .reloadIgnoringCacheData)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpBody = requestData

        let (data, _) = try await session.data(for: urlRequest)

        let parsedResponse = try JSONDecoder().decode(T.self, from: data)

        if let response = parsedResponse as? JSONRPCresponse, response.error == nil {
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
