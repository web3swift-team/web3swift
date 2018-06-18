//
//  Promise+Web3+Eth+SendRawTransaction.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 18.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit

extension web3.Eth {
    func sendRawTransactionPromise(_ transaction: Data) -> Promise<TransactionSendingResult> {
        guard let deserializedTX = EthereumTransaction.fromRaw(transaction) else {
            let promise = Promise<TransactionSendingResult>.pending()
            promise.resolver.reject(Web3Error.processingError("Serialized TX is invalid"))
            return promise.promise
        }
        return sendRawTransactionPromise(deserializedTX)
    }

    func sendRawTransactionPromise(_ transaction: EthereumTransaction) -> Promise<TransactionSendingResult>{
        print(transaction)
        let queue = web3.requestDispatcher.queue
        do {
            guard let request = EthereumTransaction.createRawTransaction(transaction: transaction) else {
                throw Web3Error.processingError("Transaction is invalid")
            }
            let rp = web3.dispatch(request)
            return rp.map(on: queue ) { response in
                guard let value: String = response.getValue() else {
                    if response.error != nil {
                        throw Web3Error.nodeError(response.error!.message)
                    }
                    throw Web3Error.nodeError("Invalid value from Ethereum node")
                }
                let result = TransactionSendingResult(transaction: transaction, hash: value)
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
