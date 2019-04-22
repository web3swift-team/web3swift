//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension web3.Eth {
    
    public func sendTransactionPromise(_ transaction: EthereumTransaction, transactionOptions: TransactionOptions? = nil, password:String = "web3swift") -> Promise<TransactionSendingResult> {
//        print(transaction)
        var assembledTransaction : EthereumTransaction = transaction // .mergedWithOptions(transactionOptions)
        let queue = web3.requestDispatcher.queue
        do {
            var mergedOptions = self.web3.transactionOptions.merge(transactionOptions)
            
            var forAssemblyPipeline : (EthereumTransaction, TransactionOptions) = (assembledTransaction, mergedOptions)
            
            for hook in self.web3.preSubmissionHooks {
                let prom : Promise<Bool> = Promise<Bool> {seal in
                    hook.queue.async {
                        let hookResult = hook.function(forAssemblyPipeline)
                        if hookResult.2 {
                            forAssemblyPipeline = (hookResult.0, hookResult.1)
                        }
                        seal.fulfill(hookResult.2)
                    }
                }
                let shouldContinue = try prom.wait()
                if !shouldContinue {
                    throw Web3Error.processingError(desc: "Transaction is canceled by middleware")
                }
            }
            
            assembledTransaction = forAssemblyPipeline.0
            mergedOptions = forAssemblyPipeline.1
            
            if self.web3.provider.attachedKeystoreManager == nil {
                guard let request = EthereumTransaction.createRequest(method: .sendTransaction, transaction: assembledTransaction, transactionOptions: mergedOptions) else
                {
                    throw Web3Error.processingError(desc: "Failed to create a request to send transaction")
                }
                return self.web3.dispatch(request).map(on: queue) {response in
                    guard let value: String = response.getValue() else {
                        if response.error != nil {
                            throw Web3Error.nodeError(desc: response.error!.message)
                        }
                        throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
                    }
                    let result = TransactionSendingResult(transaction: assembledTransaction, hash: value)
                    for hook in self.web3.postSubmissionHooks {
                        hook.queue.async {
                            hook.function(result)
                        }
                    }
                    return result
                }
            }
            guard let from = mergedOptions.from else {
                throw Web3Error.inputError(desc: "No 'from' field provided")
            }
            do {
                try Web3Signer.signTX(transaction: &assembledTransaction, keystore: self.web3.provider.attachedKeystoreManager!, account: from, password: password)
            } catch {
                throw Web3Error.inputError(desc: "Failed to locally sign a transaction")
            }
            return self.web3.eth.sendRawTransactionPromise(assembledTransaction)
        } catch {
            let returnPromise = Promise<TransactionSendingResult>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
}
