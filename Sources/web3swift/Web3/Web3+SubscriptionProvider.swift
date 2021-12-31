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

public protocol Subscription {
    func unsubscribe() throws
}

public typealias Web3SubscriptionListener<R: Decodable> = (Result<R, Error>) -> Void

public protocol Web3SubscriptionProvider: Web3Provider {
    func subscribe<R>(filter: SubscribeEventFilter,
                      listener: @escaping Web3SubscriptionListener<R>) throws -> Subscription
}
