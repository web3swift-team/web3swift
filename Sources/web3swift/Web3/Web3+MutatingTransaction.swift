//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit
fileprivate typealias PromiseResult = PromiseKit.Result

public class WriteTransaction: ReadTransaction {

    public func assemblePromise(transactionOptions: TransactionOptions? = nil) -> Promise<EthereumTransaction> {
        var assembledTransaction: EthereumTransaction = self.transaction
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
            var forAssemblyPipeline: (EthereumTransaction, EthereumContract, TransactionOptions) = (assembledTransaction, self.contract, mergedOptions)

            for hook in self.web3.preAssemblyHooks {
                let prom: Promise<Bool> = Promise<Bool> {seal in
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
            optionsForGasEstimation.gasLimit = mergedOptions.gasLimit
            optionsForGasEstimation.callOnBlock = mergedOptions.callOnBlock
            optionsForGasEstimation.type = mergedOptions.type
            optionsForGasEstimation.accessList = mergedOptions.accessList

            // assemble promise for gasLimit
            var gasEstimatePromise: Promise<BigUInt>? = nil
            guard let gasLimitPolicy = mergedOptions.gasLimit else {
                seal.reject(Web3Error.inputError(desc: "No gasLimit policy provided"))
                return
            }
            switch gasLimitPolicy {
            case .automatic, .withMargin, .limited:
                gasEstimatePromise = self.web3.eth.estimateGasPromise(assembledTransaction, transactionOptions: optionsForGasEstimation)
            case .manual(let gasLimit):
                gasEstimatePromise = Promise<BigUInt>.value(gasLimit)
            }

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

            // determine gas costing, taking transaction type into account
            let oracle = Web3.Oracle(self.web3, percentiles: [75])
            let finalGasPrice: BigUInt? // legacy gas model
            let finalGasFee: BigUInt? // EIP-1559 gas model
            let finalTipFee: BigUInt? // EIP-1559 gas model

            if mergedOptions.type == nil || mergedOptions.type != .eip1559 { // legacy Gas
                // set unused gas parameters to nil
                finalGasFee = nil
                finalTipFee = nil

                // determine the (legacy) gas price
                guard let gasPricePolicy = mergedOptions.gasPrice else {
                    seal.reject(Web3Error.inputError(desc: "No gasPrice policy provided"))
                    return
                }
                switch gasPricePolicy {
                case .automatic, .withMargin:
                    let percentiles = oracle.gasPriceLegacyPercentiles
                    guard !percentiles.isEmpty else {
                        throw Web3Error.processingError(desc: "Failed to fetch gas price")
                    }
                    finalGasPrice = percentiles[0]
                case .manual(let gasPrice):
                    finalGasPrice = gasPrice
                }
            } else { // else new gas fees (EIP-1559)
                // set unused gas parametes to nil
                finalGasPrice = nil

                // determine the tip
                guard let maxPriorityFeePerGasPolicy = mergedOptions.maxPriorityFeePerGas else {
                    seal.reject(Web3Error.inputError(desc: "No maxPriorityFeePerGas policy provided"))
                    return
                }
                switch maxPriorityFeePerGasPolicy {
                case .automatic:
                    let percentiles = oracle.tipFeePercentiles
                    guard !percentiles.isEmpty else {
                        throw Web3Error.processingError(desc: "Failed to fetch maxPriorityFeePerGas data")
                    }
                    finalTipFee = percentiles[0]
                case .manual(let maxPriorityFeePerGas):
                    finalTipFee = maxPriorityFeePerGas
                }

                // determine the baseFee, and calculate the maxFeePerGas
                guard let maxFeePerGasPolicy = mergedOptions.maxFeePerGas else {
                    seal.reject(Web3Error.inputError(desc: "No maxFeePerGas policy provided"))
                    return
                }
                switch maxFeePerGasPolicy {
                case .automatic:
                    let percentiles = oracle.baseFeePercentiles
                    guard !percentiles.isEmpty else {
                        throw Web3Error.processingError(desc: "Failed to fetch baseFee data")
                    }
                    guard let tipFee = finalTipFee else {
                        throw Web3Error.processingError(desc: "Missing tip value")
                    }
                    finalGasFee = percentiles[0] + tipFee
                case .manual(let maxFeePerGas):
                    finalGasFee = maxFeePerGas
                }
            }

            // wait for promises to resolve
            var promisesToFulfill: [Promise<BigUInt>] = [getNoncePromise!, gasEstimatePromise!]
            when(resolved: getNoncePromise!, gasEstimatePromise!).map(on: queue, { (results: [PromiseResult<BigUInt>]) throws -> EthereumTransaction in

                promisesToFulfill.removeAll()
                guard case .fulfilled(let nonce) = results[0] else {
                    throw Web3Error.processingError(desc: "Failed to fetch nonce")
                }
                guard case .fulfilled(let gasEstimate) = results[1] else {
                    throw Web3Error.processingError(desc: "Failed to fetch gas estimate")
                }

                var finalOptions = TransactionOptions()
                finalOptions.type = mergedOptions.type
                finalOptions.nonce = .manual(nonce)
                finalOptions.gasLimit = .manual(mergedOptions.resolveGasLimit(gasEstimate))
                finalOptions.accessList = mergedOptions.accessList

                // set the finalized gas parameters
                if let gasPrice = finalGasPrice {
                    finalOptions.gasPrice = .manual(mergedOptions.resolveGasPrice(gasPrice))
                }

                if let tipFee = finalTipFee {
                    finalOptions.maxPriorityFeePerGas = .manual(mergedOptions.resolveMaxPriorityFeePerGas(tipFee))
                }

                if let gasFee = finalGasFee {
                    finalOptions.maxFeePerGas = .manual(mergedOptions.resolveMaxFeePerGas(gasFee))
                }

                assembledTransaction.applyOptions(finalOptions)

                forAssemblyPipeline = (assembledTransaction, self.contract, mergedOptions)

                for hook in self.web3.postAssemblyHooks {
                    let prom: Promise<Bool> = Promise<Bool> {seal in
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

    public func sendPromise(password: String = "web3swift", transactionOptions: TransactionOptions? = nil) -> Promise<TransactionSendingResult>{
        let queue = self.web3.requestDispatcher.queue
        return self.assemblePromise(transactionOptions: transactionOptions).then(on: queue) { transaction throws -> Promise<TransactionSendingResult> in
            let mergedOptions = self.transactionOptions.merge(transactionOptions)
            var cleanedOptions = TransactionOptions()
            cleanedOptions.from = mergedOptions.from
            cleanedOptions.to = mergedOptions.to
            return self.web3.eth.sendTransactionPromise(transaction, transactionOptions: cleanedOptions, password: password)
        }
    }

    public func send(password: String = "web3swift", transactionOptions: TransactionOptions? = nil) throws -> TransactionSendingResult {
        return try self.sendPromise(password: password, transactionOptions: transactionOptions).wait()
    }

    public func assemble(transactionOptions: TransactionOptions? = nil) throws -> EthereumTransaction {
        return try self.assemblePromise(transactionOptions: transactionOptions).wait()
    }
}
