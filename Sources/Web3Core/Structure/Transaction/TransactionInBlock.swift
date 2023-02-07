//
//  TransactionInBlock.swift
//
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation

public enum TransactionInBlock: Codable {
    case hash(Data)
    case transaction(CodableTransaction)
    case null

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        if let string = try? value.decode(String.self) {
            guard let d = Data.fromHex(string) else {throw Web3Error.dataError}
            self = .hash(d)
        } else if let transaction = try? value.decode(CodableTransaction.self) {
            self = .transaction(transaction)
        } else {
            self = .null
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .hash(let data):
            try container.encode(data.hexString)
        case .transaction(let transactions):
            try container.encode(transactions)
        case .null:
            try container.encodeNil()
        }
    }
}
