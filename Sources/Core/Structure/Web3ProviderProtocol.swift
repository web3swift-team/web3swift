//
//  Web3ProviderProtocol.swift
//
//  Created by Yaroslav Yashin on 11.07.2022.
//

import Foundation

public protocol Web3Provider {
    var network: Networks { get }
    var keystoreManager: KeystoreManager? { get set }
    var policies: Policies { get set }
    var url: URL { get }
    var session: URLSession { get }

    func sendAsync(_ request: JSONRPCRequest, callback: @escaping (JSONRPCResponse) -> Void)
}

public extension Web3Provider {
    func sendAsync(_ request: JSONRPCRequest, callback: @escaping (JSONRPCResponse) -> Void) {
        fatalError("Must be implemented by a provider that supports JSONRPCRequest, e.g. WebSocket provider.")
    }
}
