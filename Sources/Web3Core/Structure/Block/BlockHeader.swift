//
//  BlockHeader.swift
//
//  Created by JeneaVranceanu on 16.12.2022.
//

import Foundation

public struct BlockHeader: Decodable {
    public let hash: String
    public let difficulty: String
    public let extraData: String
    public let gasLimit: String
    public let gasUsed: String
    public let logsBloom: String
    public let miner: String
    public let nonce: String
    public let number: String
    public let parentHash: String
    public let receiptsRoot: String
    public let sha3Uncles: String
    public let stateRoot: String
    public let timestamp: String
    public let transactionsRoot: String
}
