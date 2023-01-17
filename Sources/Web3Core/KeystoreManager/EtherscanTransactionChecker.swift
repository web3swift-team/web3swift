//
//  EtherscanTransactionChecker.swift
//  Created by albertopeam on 28/12/22.
//

import Foundation

public struct EtherscanTransactionChecker: TransactionChecker {
    private let urlSession: URLSessionProxy
    private let apiKey: String

    public init(urlSession: URLSession, apiKey: String) {
        self.urlSession = URLSessionProxyImplementation(urlSession: urlSession)
        self.apiKey = apiKey
    }

    internal init(urlSession: URLSessionProxy, apiKey: String) {
        self.urlSession = urlSession
        self.apiKey = apiKey
    }

    public func hasTransactions(address: String) async throws -> Bool {
        let urlString = "https://api.etherscan.io/api?module=account&action=txlist&address=\(address)&startblock=0&page=1&offset=1&sort=asc&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw EtherscanTransactionCheckerError.invalidUrl(url: urlString)
        }
        let request = URLRequest(url: url)
        let result = try await urlSession.data(for: request)
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

public enum EtherscanTransactionCheckerError: LocalizedError, Equatable {
    case invalidUrl(url: String)

    public var errorDescription: String? {
        switch self {
        case let .invalidUrl(url):
            return "Couldn't create URL(string: \(url))"
        }
    }
}

internal protocol URLSessionProxy {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

internal struct URLSessionProxyImplementation: URLSessionProxy {
    let urlSession: URLSession

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await urlSession.data(for: request)
    }
}
