//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
//  Additions for metadata by Mark Loit 2022

import Foundation
import BigInt

/// This structure holds additional data
/// returned by nodes when reading a transaction
/// from the blockchain. The data here is not
/// part of the transaction itself
public struct TransactionMetadata {

    /// hash for the block that contains this transaction on chain
    public var blockHash: Data?

    /// block number for the block containing this transaction on chain
    public var blockNumber: BigUInt?

    /// index for this transaction within the containing block
    public var transactionIndex: UInt?

    /// hash for this transaction as returned by the node [not computed]
    /// this can be used for validation against the computed hash returned
    /// by the transaction envelope.
    public var transactionHash: Data?

    /// gasPrice value returned by the node
    /// note this is a duplicate value for legacy and EIP-2930 transaction types
    /// but is included here since EIP-1559 does not contain a `gasPrice`, but
    /// nodes still report the value.
    public var gasPrice: BigUInt?
}

public extension TransactionMetadata {
    private enum CodingKeys: String, CodingKey {
        case blockHash
        case blockNumber
        case transactionIndex
        case transactionHash
        case gasPrice
    }

    /// since metadata realistically can only come when a transaction is created from
    /// JSON returned by a node, we only provide an initializer from JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.blockHash = try container.decodeHexIfPresent(Data.self, forKey: .blockHash)
        self.transactionHash = try container.decodeHexIfPresent(Data.self, forKey: .transactionHash)
        self.transactionIndex = try container.decodeHexIfPresent(UInt.self, forKey: .transactionIndex)
        self.blockNumber = try container.decodeHexIfPresent(BigUInt.self, forKey: .blockNumber)
        self.gasPrice = try container.decodeHexIfPresent(BigUInt.self, forKey: .gasPrice)
    }
}
