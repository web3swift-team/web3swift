//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core

public class WriteTransaction: ReadTransaction {

    // FIXME: Rewrite this to EthereumTransaction (don't touch the logic)
    public func assembleTransaction(transactionOptions: TransactionOptions? = nil) async throws -> EthereumTransaction {
        var assembledTransaction: EthereumTransaction = transaction

        if self.method != "fallback" {
            let function = self.contract.methods[self.method]?.first
            if function == nil {
                throw Web3Error.inputError(desc: "Contract's ABI does not have such method")
            }

            if function!.constant {
                throw Web3Error.inputError(desc: "Trying to transact to the constant function")
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

        // assemble gasLimit async call
        let assembledTransactionPostHood = assembledTransaction
        let optionsForGasEstimationPostHood = optionsForGasEstimation
        guard let gasLimitPolicy = mergedOptions.gasLimit else {
            throw Web3Error.inputError(desc: "No gasLimit policy provided")
        }
        async let gasEstimateAsync = gasEstimate(for: gasLimitPolicy, assembledTransaction: assembledTransactionPostHood, optionsForGasEstimation: optionsForGasEstimationPostHood)

        // assemble nonce async call
        guard let noncePolicy = mergedOptions.nonce else {
            throw Web3Error.inputError(desc: "No nonce policy provided")
        }
        async let getNonceAsync = nonce(for: noncePolicy, from: from)

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
                    throw Web3Error.inputError(desc: "No gasPrice policy provided")
                }
                switch gasPricePolicy {
                case .automatic, .withMargin:
                    let percentiles = await oracle.gasPriceLegacyPercentiles()
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
                    throw Web3Error.inputError(desc: "No maxPriorityFeePerGas policy provided")
                }
                switch maxPriorityFeePerGasPolicy {
                case .automatic:
                    let percentiles = await oracle.tipFeePercentiles()
                    guard !percentiles.isEmpty else {
                        throw Web3Error.processingError(desc: "Failed to fetch maxPriorityFeePerGas data")
                    }
                    finalTipFee = percentiles[0]
                case .manual(let maxPriorityFeePerGas):
                    finalTipFee = maxPriorityFeePerGas
                }

                // determine the baseFee, and calculate the maxFeePerGas
                guard let maxFeePerGasPolicy = mergedOptions.maxFeePerGas else {
                    throw Web3Error.inputError(desc: "No maxFeePerGas policy provided")
                }
                switch maxFeePerGasPolicy {
                case .automatic:
                    let percentiles = await oracle.baseFeePercentiles()
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

        // wait for async calls to complete
        let results = try await [getNonceAsync, gasEstimateAsync]

        let nonce = results[0]
        let gasEstimate = results[1]

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

//        assembledTransaction.applyOptions(finalOptions)

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

    // FIXME: Rewrite this to EthereumTransaction
    public func send(password: String = "web3swift", transactionOptions: TransactionOptions? = nil) async throws -> TransactionSendingResult {
        let transaction = try await assembleTransaction(transactionOptions: transactionOptions)
        let mergedOptions = self.transactionOptions.merge(transactionOptions)
        var cleanedOptions = TransactionOptions()
        cleanedOptions.from = mergedOptions.from
        cleanedOptions.to = mergedOptions.to
        // MARK: Sending Data flow
        return try await web3.eth.send(transaction, transactionOptions: cleanedOptions, password: password)
    }

    // FIXME: Rewrite this to EthereumTransaction
    func gasEstimate(for policy: TransactionOptions.GasLimitPolicy,
                     assembledTransaction: EthereumTransaction,
                     optionsForGasEstimation: TransactionOptions) async throws -> BigUInt {
        switch policy {
        case .automatic, .withMargin, .limited:
            return try await web3.eth.estimateGas(for: assembledTransaction, transactionOptions: optionsForGasEstimation)
        case .manual(let gasLimit):
            return gasLimit
        }
    }

    // FIXME: Rewrite this to EthereumTransaction
    func nonce(for policy: TransactionOptions.NoncePolicy, from: EthereumAddress) async throws -> BigUInt {
        switch policy {
        case .latest:
            return try await self.web3.eth.getTransactionCount(for: from, onBlock: .latest)
        case .pending:
            return try await self.web3.eth.getTransactionCount(for: from, onBlock: .pending)
        case .manual(let nonce):
            return nonce
        }
    }
}
