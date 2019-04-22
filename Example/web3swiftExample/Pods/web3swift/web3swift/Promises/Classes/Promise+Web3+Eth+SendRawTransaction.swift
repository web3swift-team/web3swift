//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import PromiseKit

extension web3.Eth {
    public func sendRawTransactionPromise(_ transaction: Data) -> Promise<TransactionSendingResult> {
        guard let deserializedTX = EthereumTransaction.fromRaw(transaction) else {
            let promise = Promise<TransactionSendingResult>.pending()
            promise.resolver.reject(Web3Error.processingError(desc: "Serialized TX is invalid"))
            return promise.promise
        }
        return sendRawTransactionPromise(deserializedTX)
    }

    public func sendRawTransactionPromise(_ transaction: EthereumTransaction) -> Promise<TransactionSendingResult>{
//        print(transaction)
        let queue = web3.requestDispatcher.queue
        do {
            guard let request = EthereumTransaction.createRawTransaction(transaction: transaction) else {
                throw Web3Error.processingError(desc: "Transaction is invalid")
            }
            let rp = web3.dispatch(request)
            return rp.map(on: queue ) { response in
                guard let value: String = response.getValue() else {
                    if response.error != nil {
                        throw Web3Error.nodeError(desc: response.error!.message)
                    }
                    throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
                }
                let result = TransactionSendingResult(transaction: transaction, hash: value)
                for hook in self.web3.postSubmissionHooks {
                    hook.queue.async {
                        hook.function(result)
                    }
                }
                return result
            }
        } catch {
            let returnPromise = Promise<TransactionSendingResult>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
}
