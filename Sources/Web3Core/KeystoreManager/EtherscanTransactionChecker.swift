//
//  EtherscanTransactionChecker.swift
//  Created by albertopeam on 28/12/22.
//

import Foundation

public struct EtherscanTransactionChecker: TransactionChecker {
    private let urlSession: URLSessionProxy
    private let apiKey: String
    private let successRange = 200..<300

    public init(urlSession: URLSession, apiKey: String) {
        self.urlSession = URLSessionProxyImplementation(urlSession: urlSession)
        self.apiKey = apiKey
    }

    internal init(urlSession: URLSessionProxy, apiKey: String) {
        self.urlSession = urlSession
        self.apiKey = apiKey
    }

    public func hasTransactions(ethereumAddress: EthereumAddress) async throws -> Bool {
        let urlString = "https://api.etherscan.io/api?module=account&action=txlist&address=\(ethereumAddress.address)&startblock=0&page=1&offset=1&sort=asc&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw EtherscanTransactionCheckerError.invalidUrl(url: urlString)
        }
        let request = URLRequest(url: url)
        let result = try await urlSession.data(for: request)
        if let httpResponse = result.1 as? HTTPURLResponse, !successRange.contains(httpResponse.statusCode) {
            throw EtherscanTransactionCheckerError.network(statusCode: httpResponse.statusCode)
        }
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
    case network(statusCode: Int)

    public var errorDescription: String? {
        switch self {
        case let .invalidUrl(url):
            return "Couldn't create URL(string: \(url))"
        case let .network(statusCode):
            return "Network error, statusCode: \(statusCode)"
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
