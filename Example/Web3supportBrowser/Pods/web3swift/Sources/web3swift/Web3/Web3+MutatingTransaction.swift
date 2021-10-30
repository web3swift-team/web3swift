//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit
fileprivate typealias PromiseResult = PromiseKit.Result
//import EthereumAddress

public class WriteTransaction: ReadTransaction {
    
    public func assemblePromise(transactionOptions: TransactionOptions? = nil) -> Promise<EthereumTransaction> {
        var assembledTransaction : EthereumTransaction = self.transaction
        let queue = self.web3.requestDispatcher.queue
        let returnPromise = Promise<EthereumTransaction> { seal in
            if self.method != "fallback" {
                let m = self.contract.methods[self.method]
                if m == nil {
                    seal.reject(Web3Error.inputError(desc: "Contract's ABI does not have such method"))
                    return
                }
                switch m! {
                case .function(let function):
                    if function.constant {
                        seal.reject(Web3Error.inputError(desc: "Trying to transact to the constant function"))
                        return
                    }
                case .constructor(_):
                    break
                default:
                    seal.reject(Web3Error.inputError(desc: "Contract's ABI does not have such method"))
                    return
                }
            }
            
            var mergedOptions = self.transactionOptions.merge(transactionOptions)
            if mergedOptions.value != nil {
                assembledTransaction.value = mergedOptions.value!
            }
            var forAssemblyPipeline : (EthereumTransaction, EthereumContract, TransactionOptions) = (assembledTransaction, self.contract, mergedOptions)
            
            for hook in self.web3.preAssemblyHooks {
                let prom : Promise<Bool> = Promise<Bool> {seal in
                    hook.queue.async {
                        let hookResult = hook.function(forAssemblyPipeline)
                        if hookResult.3 {
                            forAssemblyPipeline = (hookResult.0, hookResult.1, hookResult.2)
                        }
                        seal.fulfill(hookResult.3)
                    }
                }
                let shouldContinue = try prom.wait()
                if !shouldContinue {
                    seal.reject(Web3Error.processingError(desc: "Transaction is canceled by middleware"))
                    return
                }
            }
            
            assembledTransaction = forAssemblyPipeline.0
            mergedOptions = forAssemblyPipeline.2
            
            guard let from = mergedOptions.from else {
                seal.reject(Web3Error.inputError(desc: "No 'from' field provided"))
                return
            }
            
            // assemble promise for gas estimation
            var optionsForGasEstimation = TransactionOptions()
            optionsForGasEstimation.from = mergedOptions.from
            optionsForGasEstimation.to = mergedOptions.to
            optionsForGasEstimation.value = mergedOptions.value
            optionsForGasEstimation.callOnBlock = mergedOptions.callOnBlock
            let gasEstimatePromise : Promise<BigUInt> = self.web3.eth.estimateGasPromise(assembledTransaction, transactionOptions: optionsForGasEstimation)
            
            // assemble promise for nonce
            var getNoncePromise: Promise<BigUInt>?
            guard let noncePolicy = mergedOptions.nonce else {
                seal.reject(Web3Error.inputError(desc: "No nonce policy provided"))
                return
            }
            switch noncePolicy {
            case .latest:
                getNoncePromise = self.web3.eth.getTransactionCountPromise(address: from, onBlock: "latest")
            case .pending:
                getNoncePromise = self.web3.eth.getTransactionCountPromise(address: from, onBlock: "pending")
            case .manual(let nonce):
                getNoncePromise = Promise<BigUInt>.value(nonce)
            }

            let gasPricePromise : Promise<BigUInt> = self.web3.eth.getGasPricePromise()
            var promisesToFulfill: [Promise<BigUInt>] = [getNoncePromise!, gasPricePromise, gasPricePromise]
            when(resolved: getNoncePromise!, gasEstimatePromise, gasPricePromise).map(on: queue, { (results:[PromiseResult<BigUInt>]) throws -> EthereumTransaction in
                
                promisesToFulfill.removeAll()
                guard case .fulfilled(let nonce) = results[0] else {
                    throw Web3Error.processingError(desc: "Failed to fetch nonce")
                }
                guard case .fulfilled(let gasEstimate) = results[1] else {
                    throw Web3Error.processingError(desc: "Failed to fetch gas estimate")
                }
                guard case .fulfilled(let gasPrice) = results[2] else {
                    throw Web3Error.processingError(desc: "Failed to fetch gas price")
                }
                
                guard let estimate = mergedOptions.resolveGasLimit(gasEstimate) else {
                    throw Web3Error.processingError(desc: "Failed to calculate gas estimate that satisfied options")
                }
                
                guard let finalGasPrice = mergedOptions.resolveGasPrice(gasPrice) else {
                    throw Web3Error.processingError(desc: "Missing parameter of gas price for transaction")
                }
                
    
                assembledTransaction.nonce = nonce
                assembledTransaction.gasLimit = estimate
                assembledTransaction.gasPrice = finalGasPrice
                
                forAssemblyPipeline = (assembledTransaction, self.contract, mergedOptions)
                
                for hook in self.web3.postAssemblyHooks {
                    let prom : Promise<Bool> = Promise<Bool> {seal in
                        hook.queue.async {
                            let hookResult = hook.function(forAssemblyPipeline)
                            if hookResult.3 {
                                forAssemblyPipeline = (hookResult.0, hookResult.1, hookResult.2)
                            }
                            seal.fulfill(hookResult.3)
                        }
                    }
                    let shouldContinue = try prom.wait()
                    if !shouldContinue {
                        throw Web3Error.processingError(desc: "Transaction is canceled by middleware")
                    }
                }
                
                assembledTransaction = forAssemblyPipeline.0
                mergedOptions = forAssemblyPipeline.2
                
                return assembledTransaction
            }).done(on: queue) {tx in
                seal.fulfill(tx)
                }.catch(on: queue) {err in
                    seal.reject(err)
            }
        }
        return returnPromise
    }
    
    public func sendPromise(password:String = "web3swift", transactionOptions: TransactionOptions? = nil) -> Promise<TransactionSendingResult>{
        let queue = self.web3.requestDispatcher.queue
        return self.assemblePromise(transactionOptions: transactionOptions).then(on: queue) { transaction throws -> Promise<TransactionSendingResult> in
            let mergedOptions = self.transactionOptions.merge(transactionOptions)
            var cleanedOptions = TransactionOptions()
            cleanedOptions.from = mergedOptions.from
            cleanedOptions.to = mergedOptions.to
            return self.web3.eth.sendTransactionPromise(transaction, transactionOptions: cleanedOptions, password: password)
        }
    }
    
    public func send(password:String = "web3swift", transactionOptions: TransactionOptions? = nil) throws -> TransactionSendingResult {
        return try self.sendPromise(password: password, transactionOptions: transactionOptions).wait()
    }
    
    public func assemble(transactionOptions: TransactionOptions? = nil) throws -> EthereumTransaction {
        return try self.assemblePromise(transactionOptions: transactionOptions).wait()
    }
}
