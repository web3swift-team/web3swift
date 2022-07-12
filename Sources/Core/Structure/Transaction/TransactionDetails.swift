


import Foundation
import BigInt

public struct TransactionDetails: Decodable {
    public var blockHash: Data?
    public var blockNumber: BigUInt?
    public var transactionIndex: BigUInt?
    public var transaction: EthereumTransaction

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
        self.transaction = try EthereumTransaction(from: decoder)
    }
}