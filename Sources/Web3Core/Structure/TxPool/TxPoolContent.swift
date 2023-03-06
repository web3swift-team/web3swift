//
//  TxPoolContent.swift
//
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation
import BigInt

public struct TxPoolContent: Decodable {
    public var pending: [EthereumAddress: [TxPoolContentForNonce]]
    public var queued: [EthereumAddress: [TxPoolContentForNonce]]

    enum CodingKeys: String, CodingKey {
        case pending
        case queued
    }

    fileprivate static func decodePoolContentForKey<T>(container: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key) throws -> [EthereumAddress: [TxPoolContentForNonce]] {
        let raw = try container.nestedContainer(keyedBy: AdditionalDataCodingKeys.self, forKey: key)
        var result = [EthereumAddress: [TxPoolContentForNonce]]()
        for addressKey in raw.allKeys {
            let addressString = addressKey.stringValue
            guard let address = EthereumAddress(addressString, type: .normal, ignoreChecksum: true) else {
                throw Web3Error.dataError
            }
            let nestedContainer = try raw.nestedContainer(keyedBy: AdditionalDataCodingKeys.self, forKey: addressKey)
            var perNonceInformation = [TxPoolContentForNonce]()
            perNonceInformation.reserveCapacity(nestedContainer.allKeys.count)
            for nonceKey in nestedContainer.allKeys {
                guard let nonce = BigUInt(nonceKey.stringValue) else {
                    throw Web3Error.dataError
                }
                let n = try? nestedContainer.nestedUnkeyedContainer(forKey: nonceKey)
                if n != nil {
                    let details = try nestedContainer.decode([TransactionDetails].self, forKey: nonceKey)
                    let content = TxPoolContentForNonce(nonce: nonce, details: details)
                    perNonceInformation.append(content)
                } else {
                    let detail = try nestedContainer.decode(TransactionDetails.self, forKey: nonceKey)
                    let content = TxPoolContentForNonce(nonce: nonce, details: [detail])
                    perNonceInformation.append(content)
                }
            }
            result[address] = perNonceInformation
        }
        return result
    }

    fileprivate struct AdditionalDataCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
}

extension TxPoolContent: APIResultType { }

extension TxPoolContent {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pending = try TxPoolContent.decodePoolContentForKey(container: container, key: .pending)
        self.queued = try TxPoolContent.decodePoolContentForKey(container: container, key: .queued)
    }
}

public struct TxPoolContentForNonce {
    public var nonce: BigUInt
    public var details: [TransactionDetails]
}
