//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import Core


extension web3.Eth {
    public func send(raw data: Data) async throws -> TransactionSendingResult {
        let hexString = data.toHexString().addHexPrefix()
        let request: APIRequest = .sendRawTransaction(hexString)
        let response: APIResponse<Hash> = try await APIRequest.sendRequest(with: self.provider, for: request)

        let result = try TransactionSendingResult(data: data, hash: response.result)
        return result
    }
}

public struct TransactionSendingResult {
    public var transaction: CodableTransaction
    public var hash: String
}

extension TransactionSendingResult {
    init(data: Data, hash: Hash) throws {
        guard let transaction = CodableTransaction(rawValue: data) else { throw Web3Error.dataError }
        self.transaction = transaction
        self.hash = hash
    }
}
