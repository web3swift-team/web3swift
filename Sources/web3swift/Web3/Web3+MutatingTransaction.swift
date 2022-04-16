//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

public class WriteTransaction: ReadTransaction {

    public func assemblePromise(transactionOptions: TransactionOptions? = nil) async throws -> EthereumTransaction {
        var assembledTransaction: EthereumTransaction = self.transaction

        guard self.method == "fallback" else {
            guard let m = self.contract.methods[self.method] else {
                throw Web3Error.inputError(desc: "Contract's ABI does not have such method")
            }

            switch m {
            case .function(let function):
                if function.constant {
                    throw Web3Error.inputError(desc: "Trying to transact to the constant function")
                }
            case .constructor(_):
                break
            default:
                throw Web3Error.inputError(desc: "Contract's ABI does not have such method")
            }
            throw Web3Error.inputError(desc: "Contract's ABI does not have such method")
        }

        var mergedOptions = self.transactionOptions.merge(transactionOptions)
        if let mergedOptionsValue = mergedOptions.value {
            assembledTransaction.value = mergedOptionsValue
        }

        var forAssemblyPipeline: (EthereumTransaction, EthereumContract, TransactionOptions) = (assembledTransaction, self.contract, mergedOptions)

        for hook in self.web3.preAssemblyHooks {

            let hookResult = hook.function(forAssemblyPipeline)
            if hookResult.3 {
                forAssemblyPipeline = (hookResult.0, hookResult.1, hookResult.2)
            }

            let shouldContinue = hookResult.3
            if !shouldContinue {
                throw Web3Error.processingError(desc: "Transaction is canceled by middleware")
            }
        }

        let assembledtx = forAssemblyPipeline.0
        mergedOptions = forAssemblyPipeline.2

                let estimate = mergedOptions.resolveGasLimit(gasEstimate)
                let finalGasPrice = mergedOptions.resolveGasPrice(gasPrice)

                var finalOptions = TransactionOptions()
                finalOptions.nonce = .manual(nonce)
                finalOptions.gasLimit = .manual(estimate)
                finalOptions.gasPrice = .manual(finalGasPrice)

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

        var results: [BigUInt] = try await [getNoncePromise, gasEstimatePromise, gasPricePromise ]

        guard results.count >= 3 else {
            throw Web3Error.processingError(desc: "Failed to fetch Data")
        }

        guard let gasPrice = results.popLast() else {
            throw Web3Error.processingError(desc: "Failed to fetch gas price")
        }

        guard let gasEstimate = results.popLast() else {
            throw Web3Error.processingError(desc: "Failed to fetch gas estimate")
        }

        guard let nonce = results.popLast() else {
            throw Web3Error.processingError(desc: "Failed to fetch nonce")
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

            let hookResult = hook.function(forAssemblyPipeline)
            if hookResult.3 {
                forAssemblyPipeline = (hookResult.0, hookResult.1, hookResult.2)
            }

            let shouldContinue = hookResult.3
            if !shouldContinue {
                throw Web3Error.processingError(desc: "Transaction is canceled by middleware")
            }
        }

        assembledTransaction = forAssemblyPipeline.0
        mergedOptions = forAssemblyPipeline.2

        return assembledTransaction

    }

    public func sendPromise(password: String = "web3swift", transactionOptions: TransactionOptions? = nil) async throws -> TransactionSendingResult{
        let transaction = try await self.assemblePromise(transactionOptions: transactionOptions)
        let mergedOptions = self.transactionOptions.merge(transactionOptions)
        var cleanedOptions = TransactionOptions()
        cleanedOptions.from = mergedOptions.from
        cleanedOptions.to = mergedOptions.to
        return try await self.web3.eth.sendTransactionPromise(transaction, transactionOptions: cleanedOptions, password: password)
    }

    public func send(password: String = "web3swift", transactionOptions: TransactionOptions? = nil) async throws -> TransactionSendingResult {
        return try await self.sendPromise(password: password, transactionOptions: transactionOptions)
    }

    public func assemble(transactionOptions: TransactionOptions? = nil) async throws -> EthereumTransaction {
        return try await self.assemblePromise(transactionOptions: transactionOptions)
    }

    func gasEstimate(for policy:  TransactionOptions.GasLimitPolicy
                     , assembledTransaction: EthereumTransaction, optionsForGasEstimation: TransactionOptions) async throws -> BigUInt {
        switch policy {
        case .automatic, .withMargin, .limited:
            return try await self.web3.eth.estimateGasPromise(assembledTransaction, transactionOptions: optionsForGasEstimation)
        case .manual(let gasLimit):
            return gasLimit
        }
    }

    func nonce(for policy:  TransactionOptions.NoncePolicy,  from: EthereumAddress) async throws -> BigUInt {
        switch policy {
        case .latest:
            return try await self.web3.eth.getTransactionCountPromise(address: from, onBlock: "latest")
        case .pending:
            return try await self.web3.eth.getTransactionCountPromise(address: from, onBlock: "pending")
        case .manual(let nonce):
            return nonce
        }
    }

    func gasPrice(for policy:  TransactionOptions.GasPricePolicy) async throws -> BigUInt {
        switch policy {
        case .automatic, .withMargin:
            return try await self.web3.eth.getGasPricePromise()
        case .manual(let gasPrice):
            return gasPrice
        }
    }
}
