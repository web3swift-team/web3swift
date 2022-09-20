//
//  Web3+ERC1634.swift
//
//  Created by Anton Grigorev on 20/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import Core

// Re-Fungible Token Standard (RFT)
// FIXME: Rewrite this to CodableTransaction
protocol IERC1633: IERC20, IERC165 {

    func parentToken() async throws -> EthereumAddress
    func parentTokenId() async throws -> BigUInt

}

public class ERC1633: IERC1633, ERC20BaseProperties {

    internal var _name: String? = nil
    internal var _symbol: String? = nil
    internal var _decimals: UInt8? = nil
    internal var _hasReadProperties: Bool = false

    public var transaction: CodableTransaction
    public var web3: web3
    public var provider: Web3Provider
    public var address: EthereumAddress
    public var abi: String

    lazy var contract: web3.Contract = {
        let contract = self.web3.contract(self.abi, at: self.address, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()

    public init(web3: web3, provider: Web3Provider, address: EthereumAddress, abi: String = Web3.Utils.erc1633ABI, transaction: CodableTransaction = .emptyTransaction) {
        self.web3 = web3
        self.provider = provider
        self.address = address
        self.transaction = transaction
        self.transaction.to = address
        self.abi = abi
    }

    public func getBalance(account: EthereumAddress) async throws -> BigUInt {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("balanceOf", parameters: [account] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getAllowance(originalOwner: EthereumAddress, delegate: EthereumAddress) async throws -> BigUInt {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("allowance", parameters: [originalOwner, delegate] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func transfer(from: EthereumAddress, to: EthereumAddress, amount: String) async throws -> WriteOperation {
        let contract = self.contract

        self.transaction.from = from
        self.transaction.to = self.address
        self.transaction.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals" )!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        let tx = contract.createWriteOperation("transfer", parameters: [to, value] as [AnyObject] )!
        return tx
    }

    public func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String) async throws -> WriteOperation {
        let contract = self.contract

        self.transaction.from = from
        self.transaction.to = self.address
        self.transaction.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals" )!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let tx = contract.createWriteOperation("transferFrom", parameters: [originalOwner, to, value] as [AnyObject] )!
        return tx
    }

    public func setAllowance(from: EthereumAddress, to: EthereumAddress, newAmount: String) async throws -> WriteOperation {
        let contract = self.contract

        self.transaction.from = from
        self.transaction.to = self.address
        self.transaction.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals" )!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(newAmount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let tx = contract.createWriteOperation("setAllowance", parameters: [to, value] as [AnyObject] )!
        return tx
    }

    public func totalSupply() async throws -> BigUInt {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("totalSupply", parameters: [AnyObject](), extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func approve(from: EthereumAddress, spender: EthereumAddress, amount: String) async throws -> WriteOperation {
        let contract = self.contract

        self.transaction.from = from
        self.transaction.to = self.address
        self.transaction.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals" )!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let tx = contract.createWriteOperation("approve", parameters: [spender, value] as [AnyObject] )!
        return tx
    }

    func parentToken() async throws -> EthereumAddress {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("parentToken", parameters: [] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func parentTokenId() async throws -> BigUInt {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("parentTokenId", parameters: [] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func supportsInterface(interfaceID: String) async throws -> Bool {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        self.transaction.gasLimitPolicy = .manual(30000)
        let result = try await contract.createReadOperation("supportsInterface", parameters: [interfaceID] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

}
