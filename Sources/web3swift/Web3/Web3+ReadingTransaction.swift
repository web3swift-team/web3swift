//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core

// FIXME: Rewrite this to EthereumTransaction

/// Wrapper for `EthererumTransaction.data` property appropriate encoding.
public class ReadTransaction {
    public var transaction: EthereumTransaction
    public var contract: EthereumContract
    public var method: String
    public var transactionOptions: TransactionOptions = TransactionOptions.defaultOptions

    var web3: web3

    // FIXME: Rewrite this to EthereumTransaction
    public init(transaction: EthereumTransaction,
                web3 web3Instance: web3,
                contract: EthereumContract,
                method: String = "fallback",
                transactionOptions: TransactionOptions? = nil) {
        self.transaction = transaction
        self.web3 = web3Instance
        self.contract = contract
        self.method = method
        self.transactionOptions = self.transactionOptions.merge(transactionOptions)
        if self.web3.provider.network != nil {
            self.transaction.chainID = self.web3.provider.network?.chainID
        }
    }

    // FIXME: This is wrong naming, because this method doesn't decode,
    // it's merging Transactions Oprions sending request (Transaction with appropriate binary data) to contract, get's Data response
    // and only then it decodes it.
    // It should be splitted in this way up to three (merge, send, decode)
    // TODO: Remove type erasing here, some broad wide protocol should be added instead
    // FIXME: Rewrite this to EthereumTransaction
    public func decodedData(with transactionOptions: TransactionOptions? = nil) async throws -> [String: Any] {
        // MARK: Read data from ABI flow
        var assembledTransaction: EthereumTransaction = self.transaction
        let mergedOptions = self.transactionOptions.merge(transactionOptions)
        var optionsForCall = TransactionOptions()
        optionsForCall.from = mergedOptions.from
        optionsForCall.to = mergedOptions.to
        optionsForCall.value = mergedOptions.value
        optionsForCall.callOnBlock = mergedOptions.callOnBlock
        if let value = mergedOptions.value {
            assembledTransaction.value = value
        }

        // MARK: Read data from ABI flow
        let data: Data = try await self.web3.eth.callTransaction(assembledTransaction, transactionOptions: optionsForCall)

        if self.method == "fallback" {
            let resultHex = data.toHexString().addHexPrefix()
            return ["result": resultHex as Any]
        }
        guard let decodedData = self.contract.decodeReturnData(self.method, data: data) else {
            throw Web3Error.processingError(desc: "Can not decode returned parameters")
        }
        return decodedData
    }

    // FIXME: Rewrite this to EthereumTransaction
    public func estimateGas(with transactionOptions: TransactionOptions? = nil) async throws -> BigUInt {
        var assembledTransaction: EthereumTransaction = self.transaction

        let mergedOptions = self.transactionOptions.merge(transactionOptions)
        var optionsForGasEstimation = TransactionOptions()
        optionsForGasEstimation.from = mergedOptions.from
        optionsForGasEstimation.to = mergedOptions.to
        optionsForGasEstimation.value = mergedOptions.value

        // MARK: - Fixing estimate gas problem: gas price param shouldn't be nil
        if let gasPricePolicy = mergedOptions.gasPrice {
            switch gasPricePolicy {
            case .manual(_):
                optionsForGasEstimation.gasPrice = gasPricePolicy
            default:
                optionsForGasEstimation.gasPrice = .manual(1) // 1 wei to fix wrong estimating gas problem
            }
        }

        optionsForGasEstimation.callOnBlock = mergedOptions.callOnBlock
        if mergedOptions.value != nil {
            assembledTransaction.value = mergedOptions.value!
        }

        return try await self.web3.eth.estimateGas(for: assembledTransaction, transactionOptions: optionsForGasEstimation)

    }

    // FIXME: Duplicating and pointing to another?!
    // FIXME: Rewrite this to EthereumTransaction
    public func estimateGas(transactionOptions: TransactionOptions? = nil) async throws -> BigUInt {
        return try await self.estimateGas(with: transactionOptions)
    }

    // FIXME: Rewrite this to EthereumTransaction
    // FIXME: Useless wrapper, delete me
    public func call(transactionOptions: TransactionOptions? = nil) async throws -> [String: Any] {
        return try await self.decodedData(with: transactionOptions)
    }
}
