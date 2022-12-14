//
//  TransactionDetails.swift
//
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation
import BigInt

public struct TransactionDetails: Decodable {
    public var blockHash: Data?
    public var blockNumber: BigUInt?
    public var transactionIndex: BigUInt?
    public var transaction: CodableTransaction

    enum CodingKeys: String, CodingKey {
        case blockHash
        case blockNumber
        case transactionIndex
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.blockNumber = try? container.decodeHex(BigUInt.self, forKey: .blockNumber)
        self.blockHash = try?  container.decodeHex(Data.self, forKey: .blockHash)
        self.transactionIndex = try? container.decodeHex(BigUInt.self, forKey: .transactionIndex)
        self.transaction = try CodableTransaction(from: decoder)
    }
}

extension TransactionDetails: APIResultType { }
