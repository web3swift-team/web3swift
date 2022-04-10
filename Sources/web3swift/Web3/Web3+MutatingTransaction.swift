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

        guard let from = mergedOptions.from else {
            throw Web3Error.inputError(desc: "No 'from' field provided")
        }

        guard let gasLimitPolicy = mergedOptions.gasLimit else {
            throw Web3Error.inputError(desc: "No gasLimit policy provided")
        }

        guard let gasPricePolicy = mergedOptions.gasPrice else {
            throw Web3Error.inputError(desc: "No gasPrice policy provided")
        }

        guard let noncePolicy = mergedOptions.nonce else {
            throw Web3Error.inputError(desc: "No nonce policy provided")
        }

        // assemble promise for gas estimation
        let optionsForGasEstimation = TransactionOptions(
            to: mergedOptions.to,
            from: mergedOptions.from,
            gasLimit: mergedOptions.gasLimit,
            value: mergedOptions.value,
            callOnBlock: mergedOptions.callOnBlock
        )

        async let gasEstimatePromise: BigUInt = gasEstimate(for: gasLimitPolicy, assembledTransaction: assembledtx, optionsForGasEstimation: optionsForGasEstimation)

        async let getNoncePromise: BigUInt = nonce(for: noncePolicy, from: from)

        async let gasPricePromise: BigUInt = gasPrice(for: gasPricePolicy)

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

    public func sendPromise(password: String = "web3swift", transactionOptions: TransactionOptions? = nil) async -> TransactionSendingResult{
        let transaction = self.assemblePromise(transactionOptions: transactionOptions)
        let mergedOptions = self.transactionOptions.merge(transactionOptions)
        var cleanedOptions = TransactionOptions()
        cleanedOptions.from = mergedOptions.from
        cleanedOptions.to = mergedOptions.to
        return self.web3.eth.sendTransactionPromise(transaction, transactionOptions: cleanedOptions, password: password)
    }

    public func send(password: String = "web3swift", transactionOptions: TransactionOptions? = nil) throws -> TransactionSendingResult {
        return try self.sendPromise(password: password, transactionOptions: transactionOptions)
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
