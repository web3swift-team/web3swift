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

        guard let request = EthereumTransaction.createRawTransaction(transaction: transaction) else {
            throw Web3Error.processingError(desc: "Transaction is invalid")
        }
        let response = try await web3.dispatch(request)


        guard let value: String = response.getValue() else {
            if response.error != nil {
                throw Web3Error.nodeError(desc: response.error!.message)
            }
            throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
        }
        let result = TransactionSendingResult(transaction: transaction, hash: value)
        for hook in self.web3.postSubmissionHooks {
            hook.function(result)
        }
        return result


    }
}
