//
//  Web3+Eth+Websocket.swift
//  web3swift
//
//  Created by Anton on 03/04/2019.
//  Copyright © 2019 The Matter Inc. All rights reserved.
//
import Foundation
import BigInt
import PromiseKit
import Starscream

public struct SubscribeOnLogsParams: Encodable {
    public let address: [String]?
    public let topics: [String]?
}

extension web3.Eth {
    private func _subscribe<R>(filter: SubscribeEventFilter,
                              listener: @escaping Web3SubscriptionListener<R>) throws -> Subscription {
        guard let provider = provider as? Web3SubscriptionProvider else {
            throw Web3Error.processingError(desc: "Provider is not subscribable")
        }
        return provider.subscribe(filter: filter, queue: web3.requestDispatcher.queue, listener: listener)
    }
    
    public func subscribeOnNewHeads(listener: @escaping Web3SubscriptionListener<BlockHeader>) throws -> Subscription {
        try _subscribe(filter: .newHeads, listener: listener)
    }
    
    public func subscribeOnLogs(addresses: [EthereumAddress]? = nil,
                                topics: [String]? = nil,
                                listener: @escaping Web3SubscriptionListener<EventLog>) throws -> Subscription {
        let params = SubscribeOnLogsParams(address: addresses?.map { $0.address }, topics: topics)
        return try _subscribe(filter: .logs(params: params), listener: listener)
    }
    
    public func subscribeOnNewPendingTransactions(listener: @escaping Web3SubscriptionListener<String>) throws -> Subscription {
        try _subscribe(filter: .newPendingTransactions, listener: listener)
    }
    
    public func subscribeOnSyncing(listener: @escaping Web3SubscriptionListener<SyncingInfo>) throws -> Subscription {
        guard provider.network != Networks.Kovan else {
            throw Web3Error.inputError(desc: "Can't sync on Kovan")
        }
        return try _subscribe(filter: .syncing, listener: listener)
    }
}
