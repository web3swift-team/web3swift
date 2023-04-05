//
//  TransactionInBlock.swift
//
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation

public enum TransactionInBlock: Decodable {
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
}
