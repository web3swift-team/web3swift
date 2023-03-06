//
//  Web3+ERC1644.swift
//
//  Created by Anton Grigorev on 19/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

// Controller Token Operation Standard
protocol IERC1644: IERC20 {

    // Controller Operation
    func isControllable() async throws -> Bool
    func controllerTransfer(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) async throws -> WriteOperation
    func controllerRedeem(from: EthereumAddress, tokenHolder: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) async throws -> WriteOperation

}

// FIXME: Rewrite this to CodableTransaction
public class ERC1644: IERC1644, ERC20BaseProperties {
    public private(set) var basePropertiesProvider: ERC20BasePropertiesProvider
    public var transaction: CodableTransaction
    public var web3: Web3
    public var provider: Web3Provider
    public var address: EthereumAddress
    public var abi: String

    public let contract: Web3.Contract

    public init(web3: Web3, provider: Web3Provider, address: EthereumAddress, abi: String = Web3.Utils.erc1644ABI, transaction: CodableTransaction = .emptyTransaction) {
        self.web3 = web3
        self.provider = provider
        self.address = address
        self.transaction = transaction
        self.transaction.to = address
        self.abi = abi
        // TODO: Make `init` and `web3.contract.init` throwing. Forced because this should fail if ABI is wrongly configured
        contract = web3.contract(abi, at: address)!
        basePropertiesProvider = ERC20BasePropertiesProvider(contract: contract)
    }

    public func getBalance(account: EthereumAddress) async throws -> BigUInt {
        let result = try await contract.createReadOperation("balanceOf", parameters: [account])!.callContractMethod()

        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getAllowance(originalOwner: EthereumAddress, delegate: EthereumAddress) async throws -> BigUInt {
        let result = try await contract.createReadOperation("allowance", parameters: [originalOwner, delegate])!.callContractMethod()

        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func transfer(from: EthereumAddress, to: EthereumAddress, amount: String) async throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals")!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let tx = contract.createWriteOperation("transfer", parameters: [to, value])!
        return tx
    }

    public func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String) async throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals")!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let tx = contract.createWriteOperation("transferFrom", parameters: [originalOwner, to, value])!
        return tx
    }

    public func setAllowance(from: EthereumAddress, to: EthereumAddress, newAmount: String) async throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals")!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(newAmount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let tx = contract.createWriteOperation("setAllowance", parameters: [to, value])!
        return tx
    }

    public func totalSupply() async throws -> BigUInt {
        let result = try await contract.createReadOperation("totalSupply")!.callContractMethod()

        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func approve(from: EthereumAddress, spender: EthereumAddress, amount: String) async throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals")!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let tx = contract.createWriteOperation("approve", parameters: [spender, value])!
        return tx
    }

    // ERC1644
    public func isControllable() async throws -> Bool {
        let result = try await contract.createReadOperation("isControllable")!.callContractMethod()

        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func controllerTransfer(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) async throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals")!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let tx = contract.createWriteOperation("controllerTransfer", parameters: [originalOwner, to, value, data, operatorData])!
        return tx
    }

    public func controllerRedeem(from: EthereumAddress, tokenHolder: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) async throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals")!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let tx = contract.createWriteOperation("controllerRedeem", parameters: [tokenHolder, value, data, operatorData])!
        return tx
    }
}

// MARK: - Private

extension ERC1644 {

    private func updateTransactionAndContract(from: EthereumAddress) {
        transaction.from = from
        transaction.to = address
        contract.transaction = transaction
    }

}
