//
//  EtherscanTransactionChecker.swift
//  Created by albertopeam on 28/12/22.
//

import Foundation
import _Concurrency

public struct EtherscanTransactionChecker: TransactionChecker {
    private let urlSession: URLSessionProxy
    private let apiKey: String
    
    public init(urlSession: URLSessionProxy, apiKey: String) {
        self.urlSession = urlSession
        self.apiKey = apiKey
    }
    
    public func hasTransactions(address: String) async throws -> Bool {
        let urlString = "https://api.etherscan.io/api?module=account&action=txlist&address=\(address)&startblock=0&page=1&offset=1&sort=asc&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw EtherscanTransactionCheckerError.invalidUrl
        }
        let request = URLRequest(url: url)
        let result = try await urlSession.data(request: request)
        let response = try JSONDecoder().decode(Response.self, from: result.0)
        return !response.result.isEmpty
    }
}

extension EtherscanTransactionChecker {
    struct Response: Codable {
        let result: [Transaction]
    }
    struct Transaction: Codable {}
}

public enum EtherscanTransactionCheckerError: Error {
    case invalidUrl
}

public protocol URLSessionProxy {
    func data(request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

extension URLSession: URLSessionProxy {
    public func data(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        return try await data(for: request)
    }
}
