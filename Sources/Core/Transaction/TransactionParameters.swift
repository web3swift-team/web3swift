//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
//  Additions to support new transaction types by Mark Loit March 2022
//
//  Made most structs generics by Yaroslav Yashin 2022

import Foundation
import BigInt

/// Global counter object to enumerate JSON RPC requests.
public struct Counter {
    public static var counter: UInt = 1
    public static var lockQueue = DispatchQueue(label: "counterQueue")
    public static func increment() -> UInt {
        defer {
            lockQueue.sync {
                Counter.counter += 1
            }
        }
        return counter
    }
}

/// Transaction parameters JSON structure for interaction with Ethereum node.
public struct TransactionParameters: Codable {
    /// accessList parameter JSON structure
    public struct AccessListEntry: Codable {
        public var address: String
        public var storageKeys: [String]
    }

    public var type: String?  // must be set for new EIP-2718 transaction types
    public var chainID: String?
    public var data: String?
    public var from: String?
    public var gas: String?
    public var gasPrice: String? // Legacy & EIP-2930
    public var maxFeePerGas: String? // EIP-1559
    public var maxPriorityFeePerGas: String? // EIP-1559
    public var accessList: [AccessListEntry]? // EIP-1559 & EIP-2930
    public var to: String?
    public var value: String? = "0x0"

    public init(from _from: String?, to _to: String?) {
        from = _from
        to = _to
    }
}

extension TransactionParameters: APIRequestParameterType { }

/// Event filter parameters JSON structure for interaction with Ethereum node.
public struct EventFilterParameters: Codable {
    public var fromBlock: String?
    public var toBlock: String?
    public var topics: [[String?]?]?
    public var address: [String?]?
    
    public init(fromBlock: String? = nil, toBlock: String? = nil, topics: [[String?]?]? = nil, address: [String?]? = nil) {
        self.fromBlock = fromBlock
        self.toBlock = toBlock
        self.topics = topics
        self.address = address
    }
}

extension EventFilterParameters: APIRequestParameterType { }
