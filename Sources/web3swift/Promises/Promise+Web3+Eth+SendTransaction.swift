//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension Web3.Eth {

    public func send(_ transaction: EthereumTransaction, transactionOptions: TransactionOptions? = nil, password: String = "web3swift") async throws -> TransactionSendingResult {
        //  print(transaction)
        var assembledTransaction: EthereumTransaction = transaction

        var mergedOptions = self.web3.transactionOptions.merge(transactionOptions)

        var forAssemblyPipeline: (EthereumTransaction, TransactionOptions) = (assembledTransaction, mergedOptions)

        for hook in self.web3.preSubmissionHooks {
            let hookResult = hook.function(forAssemblyPipeline)
            if hookResult.2 {
                forAssemblyPipeline = (hookResult.0, hookResult.1)
            }

            let shouldContinue = hookResult.2
            if !shouldContinue {
                throw Web3Error.processingError(desc: "Transaction is canceled by middleware")
            }
        }

        assembledTransaction = forAssemblyPipeline.0
        mergedOptions = forAssemblyPipeline.1

        guard let attachedKeystoreManager = self.web3.provider.attachedKeystoreManager else {
            guard let request = EthereumTransaction.createRequest(method: .sendTransaction, transaction: assembledTransaction, transactionOptions: mergedOptions) else {
                throw Web3Error.processingError(desc: "Failed to create a request to send transaction")
            }
            let response = try await self.web3.dispatch(request)

            guard let value: String = response.getValue() else {
                if response.error != nil {
                    throw Web3Error.nodeError(desc: response.error!.message)
                }
                throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
            }
            let result = TransactionSendingResult(transaction: assembledTransaction, hash: value)
            for hook in self.web3.postSubmissionHooks {
                Task {
                    hook.function(result)
                }
            }
            return result
        }

        guard let from = mergedOptions.from else {
            throw Web3Error.inputError(desc: "No 'from' field provided")
        }
        do {
            try Web3Signer.signTX(transaction: &assembledTransaction, keystore: attachedKeystoreManager, account: from, password: password)
        } catch {
            throw Web3Error.inputError(desc: "Failed to locally sign a transaction")
        }
        return try await self.web3.eth.send(raw: assembledTransaction)

    }
}
