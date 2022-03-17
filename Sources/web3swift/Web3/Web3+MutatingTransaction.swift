//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt


public class WriteTransaction: ReadTransaction {

    public func assemblePromise(transactionOptions: TransactionOptions? = nil) async throws -> EthereumTransaction {

        if self.method != "fallback" {
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
        }

        var assembledTransaction : EthereumTransaction = self.transaction
        var mergedOptions = self.transactionOptions.merge(transactionOptions)

        if let mergedOptionsValue = mergedOptions.value {
            assembledTransaction.value = mergedOptionsValue
        }

        var forAssemblyPipeline : (EthereumTransaction, EthereumContract, TransactionOptions) = (assembledTransaction, self.contract, mergedOptions)

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

        assembledTransaction = forAssemblyPipeline.0
        mergedOptions = forAssemblyPipeline.2

        guard let from = mergedOptions.from else {
            throw Web3Error.inputError(desc: "No 'from' field provided")
        }

        // assemble promise for gas estimation
        var optionsForGasEstimation = TransactionOptions()
        optionsForGasEstimation.from = mergedOptions.from
        optionsForGasEstimation.to = mergedOptions.to
        optionsForGasEstimation.value = mergedOptions.value
        optionsForGasEstimation.gasLimit = mergedOptions.gasLimit
        optionsForGasEstimation.callOnBlock = mergedOptions.callOnBlock

        guard let gasLimitPolicy = mergedOptions.gasLimit else {
            throw Web3Error.inputError(desc: "No gasLimit policy provided")
        }

        // assemble promise for gasLimit
        let gasAssembledTransaction = assembledTransaction
        let gasOptionsForGasEstimation = optionsForGasEstimation
        async let gasEstimatePromise: BigUInt = getGasEstimatePromise(gasLimitPolicy: gasLimitPolicy, assembledTransaction: gasAssembledTransaction, optionsForGasEstimation: gasOptionsForGasEstimation)

        // assemble promise for nonce
        guard let noncePolicy = mergedOptions.nonce else {
            throw Web3Error.inputError(desc: "No nonce policy provided")
        }

        async let getNoncePromise: BigUInt = getNoncePromise(policy: noncePolicy, from: from)

        // assemble promise for gasPrice
        guard let gasPricePolicy = mergedOptions.gasPrice else {
            throw Web3Error.inputError(desc: "No gasPrice policy provided")
        }

        async let gasPricePromise: BigUInt = getGasPricePromise(policy: gasPricePolicy)


        var results: [BigUInt] = try await [getNoncePromise, gasEstimatePromise, gasPricePromise ]

        guard results.count == 3 else {
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

            if !hookResult.3 {
                throw Web3Error.processingError(desc: "Transaction is canceled by middleware")
            }
        }

        assembledTransaction = forAssemblyPipeline.0
        mergedOptions = forAssemblyPipeline.2

        return assembledTransaction

    }

    private func getGasEstimatePromise(gasLimitPolicy: TransactionOptions.GasLimitPolicy, assembledTransaction: EthereumTransaction, optionsForGasEstimation: TransactionOptions) async throws -> BigUInt {
        switch gasLimitPolicy {
        case .automatic, .withMargin, .limited:
            return try await self.web3.eth.estimateGasPromise(assembledTransaction, transactionOptions: optionsForGasEstimation)
        case .manual(let gasLimit):
            return gasLimit
        }
    }

    private func getGasPricePromise(policy gasPricePolicy: TransactionOptions.GasPricePolicy) async throws -> BigUInt {
        switch gasPricePolicy {
        case .automatic, .withMargin:
            return try await self.web3.eth.getGasPricePromise()
        case .manual(let gasPrice):
            return gasPrice
        }
    }

    private func getNoncePromise(policy noncePolicy: TransactionOptions.NoncePolicy, from: EthereumAddress) async throws -> BigUInt {
        switch noncePolicy {
        case .latest:
            return try await self.web3.eth.getTransactionCountPromise(address: from, onBlock: "latest")
        case .pending:
            return try await self.web3.eth.getTransactionCountPromise(address: from, onBlock: "pending")
        case .manual(let nonce):
            return nonce
        }
    }

    public func sendPromise(password:String = "web3swift", transactionOptions: TransactionOptions? = nil) async throws -> TransactionSendingResult {

        let transaction = try await self.assemblePromise(transactionOptions: transactionOptions)

        let mergedOptions = self.transactionOptions.merge(transactionOptions)
        var cleanedOptions = TransactionOptions()
        cleanedOptions.from = mergedOptions.from
        cleanedOptions.to = mergedOptions.to
        return try await self.web3.eth.sendTransactionPromise(transaction, transactionOptions: cleanedOptions, password: password)

    }

    public func send(password:String = "web3swift", transactionOptions: TransactionOptions? = nil) async throws -> TransactionSendingResult {
        return try await self.sendPromise(password: password, transactionOptions: transactionOptions)
    }

    public func assemble(transactionOptions: TransactionOptions? = nil) async throws -> EthereumTransaction {
        return try await self.assemblePromise(transactionOptions: transactionOptions)
    }
}
