//
//  Web3+SubscriptionProvider.swift
//  
//
//  Created by Ostap Danylovych on 29.12.2021.
//

import Foundation

public enum SubscribeEventFilter {
    case newHeads
    case logs(params: Encodable)
    case newPendingTransactions
    case syncing
}

extension SubscribeEventFilter {
    public var params: [Encodable] {
        switch self {
        case .newHeads: return ["newHeads"]
        case .logs(let logsParam): return ["logs", logsParam]
        case .newPendingTransactions: return ["newPendingTransactions"]
        case .syncing: return ["syncing"]
        }
    }
}

public protocol Subscription {
    func unsubscribe()
}

public typealias Web3SubscriptionListener<R: Decodable> = (Result<R, Error>) -> Void

public protocol Web3SubscriptionProvider: Web3Provider {
    func subscribe<R>(filter: SubscribeEventFilter,
                      queue: DispatchQueue,
                      listener: @escaping Web3SubscriptionListener<R>) -> Subscription
}
