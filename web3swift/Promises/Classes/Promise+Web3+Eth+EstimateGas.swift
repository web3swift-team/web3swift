//
//  Promise+Web3+Eth+EstimateGas.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 18.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension web3.Eth {
    
    func estimateGasPromise(_ transaction: EthereumTransaction, options: Web3Options? = nil, onBlock: String = "latest") -> Promise<BigUInt>{
        let queue = web3.requestDispatcher.queue
        do {
            guard let request = EthereumTransaction.createRequest(method: .estimateGas, transaction: transaction, onBlock: onBlock, options: options) else {
                throw Web3Error.processingError("Transaction is invalid")
            }
            let rp = web3.dispatch(request)
            return rp.map(on: queue ) { response in
                guard let value: BigUInt = response.getValue() else {
                    if response.error != nil {
                        throw Web3Error.nodeError(response.error!.message)
                    }
                    throw Web3Error.nodeError("Invalid value from Ethereum node")
                }
                return value
            }
        } catch {
            let returnPromise = Promise<BigUInt>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
}

