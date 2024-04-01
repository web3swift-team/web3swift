//
//  TxPoolStatus.swift
//
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation
import BigInt

public struct TxPoolStatus: Decodable {
    public var pending: BigUInt
    public var queued: BigUInt

    enum CodingKeys: String, CodingKey {
        case pending
        case queued
    }
}

extension TxPoolStatus: APIResultType { }

public extension TxPoolStatus {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pending = try container.decodeHex(BigUInt.self, forKey: .pending)
        self.queued = try container.decodeHex(BigUInt.self, forKey: .queued)
    }
}
