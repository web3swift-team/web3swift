//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation


extension web3.Eth {
    public func send(raw transaction: Data) async throws -> TransactionSendingResult {
        guard let deserializedTX = EthereumTransaction(rawValue: transaction) else {
            throw Web3Error.processingError(desc: "Serialized TX is invalid")
        }
        return try await send(raw: deserializedTX)
    }

    public func send(raw transaction: EthereumTransaction) async throws -> TransactionSendingResult {
        // FIXME: Add appropriate error
        guard let transactionHexData = transaction.encode()?.toHexString().addHexPrefix() else { throw Web3Error.unknownError }
        let request: APIRequest = .sendRawTransaction(transactionHexData)
        let response: APIResponse<Hash> = try await APIRequest.sendRequest(with: self.provider, for: request)

        let result = TransactionSendingResult(transaction: transaction, hash: response.result)
        for hook in self.web3.postSubmissionHooks {
            hook.function(result)
        }
        return result
    }
}
