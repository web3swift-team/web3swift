//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension web3.Eth {
    public func sendRawTransactionPromise(_ transaction: Data) async throws -> TransactionSendingResult {
        guard let deserializedTX = EthereumTransaction.fromRaw(transaction) else {
            throw Web3Error.processingError(desc: "Serialized TX is invalid")
        }
        return try await sendRawTransactionPromise(deserializedTX)
    }

    public func sendRawTransactionPromise(_ transaction: EthereumTransaction) async throws -> TransactionSendingResult {

        guard let request = EthereumTransaction.createRawTransaction(transaction: transaction) else {
            throw Web3Error.processingError(desc: "Transaction is invalid")
        }
        let response = await web3.dispatch(request)

        guard let value: String = response?.getValue() else {
            throw Web3Error.nodeError(desc: response?.error?.message ?? "Invalid value from Ethereum node")
        }
        let result = TransactionSendingResult(transaction: transaction, hash: value)
        for hook in self.web3.postSubmissionHooks {
            hook.queue.async {
                hook.function(result)
            }
        }
        return result

    }
}
