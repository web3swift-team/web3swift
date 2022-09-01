//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core


extension web3.Eth {

    // FIXME: Rewrite this to EncodableTransaction
    public func send(_ transaction: EncodableTransaction, transactionOptions: TransactionOptions? = nil, password: String = "web3swift") async throws -> TransactionSendingResult {
        //  print(transaction)
        var assembledTransaction: EncodableTransaction = transaction

        var mergedOptions = self.web3.transactionOptions.merge(transactionOptions)

        var forAssemblyPipeline: (EncodableTransaction, TransactionOptions) = (assembledTransaction, mergedOptions)

        // usually not calling
        // Can't find where this hooks are implemented.
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
        // MARK: Writing Data flow
        // From EncodableTransaction.data to TransactionParameters.data
        assembledTransaction.applyOptions(mergedOptions)
        // guard let transactionParameters = transaction.encodeAsDictionary(from: transactionOptions?.from) else { throw Web3Error.dataError }

        // MARK: Sending Data flow
        // FIXME: This gives empty object, fix me, there were TransactionParameters applied.
        let request: APIRequest = .sendTransaction(assembledTransaction)
        let response: APIResponse<Hash> = try await APIRequest.sendRequest(with: self.provider, for: request)

        let result = TransactionSendingResult(transaction: assembledTransaction, hash: response.result)
        for hook in self.web3.postSubmissionHooks {
            hook.function(result)
        }
        return result
    }
}
