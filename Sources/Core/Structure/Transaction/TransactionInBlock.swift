

import Foundation

public enum TransactionInBlock: Decodable {
    case hash(Data)
    case transaction(EthereumTransaction)
    case null

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        if let string = try? value.decode(String.self) {
            guard let d = Data.fromHex(string) else {throw Web3Error.dataError}
            self = .hash(d)
        } else if let transaction = try? value.decode(EthereumTransaction.self) {
            self = .transaction(transaction)
        } else {
            self = .null
        }
    }
}
