//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

public class WriteTransaction: ReadTransaction {

    public func assembleTransaction(transactionOptions: TransactionOptions? = nil) async throws -> EthereumTransaction {
        var assembledTransaction: EthereumTransaction = self.transaction

        if self.method != "fallback" {
            let m = self.contract.methods[self.method]
            if m == nil {
                throw Web3Error.inputError(desc: "Contract's ABI does not have such method")
            }
            switch m! {
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
        if mergedOptions.value != nil {
            assembledTransaction.value = mergedOptions.value!
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

            // assemble promise for gasLimit

        guard let gasLimitPolicy = mergedOptions.gasLimit else {
            throw Web3Error.inputError(desc: "No gasLimit policy provided")
        }

        guard let gasPricePolicy = mergedOptions.gasPrice else {
            throw Web3Error.inputError(desc: "No gasPrice policy provided")
        }

        guard let noncePolicy = mergedOptions.nonce else {
            throw Web3Error.inputError(desc: "No nonce policy provided")
        }


        let assembledTransactionPostHood = assembledTransaction
        let optionsForGasEstimationPostHood = optionsForGasEstimation

        async let gasEstimatePromise = gasEstimate(for: gasLimitPolicy, assembledTransaction: assembledTransactionPostHood, optionsForGasEstimation: optionsForGasEstimationPostHood)

        // assemble promise for nonce
        async let getNoncePromise = nonce(for: noncePolicy, from: from)


        // assemble promise for gasPrice
        async let gasPricePromise = gasPrice(for: gasPricePolicy)


        let results = try await [getNoncePromise, gasPricePromise, gasEstimatePromise]

        let nonce = results[0]
        let gasEstimate = results[1]
        let gasPrice = results[2]


        let estimate = mergedOptions.resolveGasLimit(gasEstimate)
        let finalGasPrice = mergedOptions.resolveGasPrice(gasPrice)

        var finalOptions = TransactionOptions()
        finalOptions.nonce = .manual(nonce)
        finalOptions.gasLimit = .manual(estimate)
        finalOptions.gasPrice = .manual(finalGasPrice)

        assembledTransaction.applyOptions(finalOptions)

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


        return assembledTransaction

    }

    public func send(password: String = "web3swift", transactionOptions: TransactionOptions? = nil) async throws -> TransactionSendingResult {
        let transaction = try await self.assembleTransaction(transactionOptions: transactionOptions)
        let mergedOptions = self.transactionOptions.merge(transactionOptions)
        var cleanedOptions = TransactionOptions()
        cleanedOptions.from = mergedOptions.from
        cleanedOptions.to = mergedOptions.to
        return try await self.web3.eth.send(transaction, transactionOptions: cleanedOptions, password: password)
    }

    public func assemble(transactionOptions: TransactionOptions? = nil) async throws -> EthereumTransaction {
        return try await self.assembleTransaction(transactionOptions: transactionOptions)
    }

    func gasEstimate(for policy:  TransactionOptions.GasLimitPolicy
                     , assembledTransaction: EthereumTransaction, optionsForGasEstimation: TransactionOptions) async throws -> BigUInt {
        switch policy {
        case .automatic, .withMargin, .limited:
            return try await self.web3.eth.estimateGas(for: assembledTransaction, transactionOptions: optionsForGasEstimation)
        case .manual(let gasLimit):
            return gasLimit
        }
    }

    func nonce(for policy:  TransactionOptions.NoncePolicy,  from: EthereumAddress) async throws -> BigUInt {
        switch policy {
        case .latest:
            return try await self.web3.eth.getTransactionCount(address: from, onBlock: "latest")
        case .pending:
            return try await self.web3.eth.getTransactionCount(address: from, onBlock: "pending")
        case .manual(let nonce):
            return nonce
        }
    }

    func gasPrice(for policy:  TransactionOptions.GasPricePolicy) async throws -> BigUInt {
        switch policy {
        case .automatic, .withMargin:
            return try await self.web3.eth.gasPrice()
        case .manual(let gasPrice):
            return gasPrice
        }
    }
}
