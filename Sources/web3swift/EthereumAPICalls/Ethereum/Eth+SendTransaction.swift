//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt


extension web3.Eth {

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


        if let attachedKeystoreManager = self.web3.provider.attachedKeystoreManager {
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

        // FIXME: Add appropriate error
        guard let transactionParameters = transaction.encodeAsDictionary(from: transactionOptions?.from) else { throw Web3Error.unknownError }

        let request: APIRequest = .sendTransaction(transactionParameters, transactionOptions?.callOnBlock ?? .latest)
        let response: APIResponse<Hash> = try await APIRequest.sendRequest(with: self.provider, for: request)

        let result = TransactionSendingResult(transaction: assembledTransaction, hash: response.result)
        for hook in self.web3.postSubmissionHooks {
            hook.function(result)
        }
        return result
    }
}
