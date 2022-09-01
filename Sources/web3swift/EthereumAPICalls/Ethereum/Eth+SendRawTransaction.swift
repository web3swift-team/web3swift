//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import Core


extension web3.Eth {
    public func send(raw transaction: Data) async throws -> TransactionSendingResult {
        guard let deserializedTX = EncodableTransaction(rawValue: transaction) else {
            throw Web3Error.processingError(desc: "Serialized TX is invalid")
        }
        return try await send(raw: deserializedTX)
    }

    public func send(raw transaction: EncodableTransaction) async throws -> TransactionSendingResult {
        guard let transactionHexData = transaction.encode(for: .transaction)?.toHexString().addHexPrefix() else { throw Web3Error.dataError }
        let request: APIRequest = .sendRawTransaction(transactionHexData)
        let response: APIResponse<Hash> = try await APIRequest.sendRequest(with: self.provider, for: request)

        let result = TransactionSendingResult(transaction: transaction, hash: response.result)
        for hook in self.web3.postSubmissionHooks {
            hook.function(result)
        }
        return result
    }
}


public struct TransactionSendingResult {
    public var transaction: EncodableTransaction
    public var hash: String
}
