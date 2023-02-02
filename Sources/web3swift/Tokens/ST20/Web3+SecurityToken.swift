//
//  Web3+SecurityToken.swift
//
//  Created by Anton on 05/03/2019.
//  Copyright © 2019 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

/// The Ownable contract has an owner address, and provides basic authorization control functions, this simplifies the implementation of "user permissions".
protocol IOwnable {
    /// Allows the current owner to relinquish control of the contract.
    func renounceOwnership(from: EthereumAddress) async throws -> WriteOperation

    /// Allows the current owner to transfer control of the contract to a newOwner.
    func transferOwnership(from: EthereumAddress, newOwner: EthereumAddress) async throws -> WriteOperation
}

/// Security token interface
protocol ISecurityToken: IST20, IOwnable {
    /// Value of current checkpoint
    func currentCheckpointId() async throws -> BigUInt

    func getGranularity() async throws -> BigUInt

    /// Total number of non-zero token holders
    func investorCount() async throws -> BigUInt

    /// List of token holders at specified index
    func investors(index: UInt) async throws -> [EthereumAddress]

    /// Permissions this to a Permission module, which has a key of 1
    /// If no Permission return false - note that IModule withPerm will allow ST owner all permissions anyway
    /// this allows individual modules to override this logic if needed (to not allow ST owner all permissions)
    func checkPermission(delegate: EthereumAddress, module: EthereumAddress, perm: [UInt32]) async throws -> Bool

    /// returns module list for a module type
    /// params:
    /// - moduleType is which type of module we are trying to remove
    /// - moduleIndex is the index of the module within the chosen type
    func getModule(moduleType: UInt8, moduleIndex: UInt8) async throws -> ([UInt32], EthereumAddress)

    /// returns module list for a module name - will return first match
    /// params:
    /// - moduleType is which type of module we are trying to remove
    /// - name is the name of the module within the chosen type
    func getModuleByName(moduleType: UInt8, name: [UInt32]) async throws -> ([UInt32], EthereumAddress)

    /// Queries totalSupply as of a defined checkpoint
    func totalSupplyAt(checkpointId: BigUInt) async throws -> BigUInt

    /// Queries balances as of a defined checkpoint
    func balanceOfAt(investor: EthereumAddress, checkpointId: BigUInt) async throws -> BigUInt

    /// Creates a checkpoint that can be used to query historical balances / totalSuppy
    func createCheckpoint(from: EthereumAddress) async throws -> WriteOperation

    /// gets length of investors array
    func getInvestorsLength() async throws -> BigUInt
}

// FIXME: Rewrite this to CodableTransaction
public class SecurityToken: ISecurityToken, ERC20BaseProperties {
    public private(set) var basePropertiesProvider: ERC20BasePropertiesProvider
    public var transaction: CodableTransaction
    public var web3: Web3
    public var provider: Web3Provider
    public var address: EthereumAddress
    public var abi: String

    public let contract: Web3.Contract

    public init(web3: Web3, provider: Web3Provider, address: EthereumAddress, abi: String = Web3.Utils.st20ABI, transaction: CodableTransaction = .emptyTransaction) {
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

    public func decimals() async throws -> UInt8 {
        try await readProperties()
        return decimals ?? 18
    }

    func tokenDetails() async throws -> [UInt32] {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("tokenDetails")!.callContractMethod()
        guard let res = result["0"] as? [UInt32] else { throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node") }
        return res
    }

    func verifyTransfer(from: EthereumAddress, originalOwner: EthereumAddress, to: EthereumAddress, amount: String) async throws -> WriteOperation {
        transaction.from = from
        transaction.to = self.address
        transaction.callOnBlock = .latest
        contract.transaction = transaction
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals")!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals") }
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        return contract.createWriteOperation("verifyTransfer", parameters: [originalOwner, to, value])!
    }

    func mint(from: EthereumAddress, investor: EthereumAddress, amount: String) async throws -> WriteOperation {
        transaction.from = from
        transaction.to = self.address
        transaction.callOnBlock = .latest
        contract.transaction = transaction
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals")!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals") }
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        return contract.createWriteOperation("mint", parameters: [investor, value])!
    }

    public func burn(from: EthereumAddress, amount: String) async throws -> WriteOperation {
        transaction.from = from
        transaction.to = self.address
        transaction.callOnBlock = .latest
        contract.transaction = transaction
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals")!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals") }
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        return contract.createWriteOperation("burn", parameters: [value])!
    }

    public func getBalance(account: EthereumAddress) async throws -> BigUInt {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("balanceOf", parameters: [account])!.callContractMethod()
        guard let res = result["0"] as? BigUInt else { throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node") }
        return res
    }

    public func getAllowance(originalOwner: EthereumAddress, delegate: EthereumAddress) async throws -> BigUInt {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("allowance", parameters: [originalOwner, delegate])!.callContractMethod()
        guard let res = result["0"] as? BigUInt else { throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node") }
        return res
    }

    public func transfer(from: EthereumAddress, to: EthereumAddress, amount: String) async throws -> WriteOperation {
        transaction.from = from
        transaction.to = self.address
        transaction.callOnBlock = .latest
        contract.transaction = transaction
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals")!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals") }
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        return contract.createWriteOperation("transfer", parameters: [to, value])!
    }

    public func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String) async throws -> WriteOperation {
        transaction.from = from
        transaction.to = self.address
        transaction.callOnBlock = .latest
        contract.transaction = transaction
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals")!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals") }
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        return contract.createWriteOperation("transferFrom", parameters: [originalOwner, to, value])!
    }

    public func setAllowance(from: EthereumAddress, to: EthereumAddress, newAmount: String) async throws -> WriteOperation {
        transaction.from = from
        transaction.to = self.address
        transaction.callOnBlock = .latest
        contract.transaction = transaction
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals")!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals") }
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(newAmount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        return contract.createWriteOperation("setAllowance", parameters: [to, value])!
    }

    public func approve(from: EthereumAddress, spender: EthereumAddress, amount: String) async throws -> WriteOperation {
        transaction.from = from
        transaction.to = self.address
        transaction.callOnBlock = .latest
        contract.transaction = transaction
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals")!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals") }
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        return contract.createWriteOperation("approve", parameters: [spender, value])!
    }

    public func totalSupply() async throws -> BigUInt {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("totalSupply")!.callContractMethod()
        guard let res = result["0"] as? BigUInt else { throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node") }
        return res
    }

    public func renounceOwnership(from: EthereumAddress) throws -> WriteOperation {
        transaction.from = from
        transaction.to = self.address
        transaction.callOnBlock = .latest

        contract.transaction = transaction
        return contract.createWriteOperation("renounceOwnership")!

    }

    public func transferOwnership(from: EthereumAddress, newOwner: EthereumAddress) throws -> WriteOperation {
        transaction.from = from
        transaction.to = self.address
        transaction.callOnBlock = .latest

        contract.transaction = transaction
        return contract.createWriteOperation("transferOwnership", parameters: [newOwner])!

    }

    public func currentCheckpointId() async throws -> BigUInt {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("currentCheckpointId")!.callContractMethod()
        guard let res = result["0"] as? BigUInt else { throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node") }
        return res
    }

    public func getGranularity() async throws -> BigUInt {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("granularity")!.callContractMethod()
        guard let res = result["0"] as? BigUInt else { throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node") }
        return res
    }

    public func investorCount() async throws -> BigUInt {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("investorCount")!.callContractMethod()
        guard let res = result["0"] as? BigUInt else { throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node") }
        return res
    }

    public func investors(index: UInt) async throws -> [EthereumAddress] {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("investors", parameters: [index])!.callContractMethod()
        guard let res = result["0"] as? [EthereumAddress] else { throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node") }
        return res
    }

    public func checkPermission(delegate: EthereumAddress, module: EthereumAddress, perm: [UInt32]) async throws -> Bool {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("checkPermission", parameters: [delegate, module, perm])!.callContractMethod()
        guard let res = result["0"] as? Bool else { throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node") }
        return res
    }

    public func getModule(moduleType: UInt8, moduleIndex: UInt8) async throws -> ([UInt32], EthereumAddress) {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("getModule", parameters: [moduleType, moduleIndex])!.callContractMethod()
        guard let moduleList = result["0"] as? [UInt32] else { throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node") }
        guard let moduleAddress = result["1"] as? EthereumAddress else { throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node") }
        return (moduleList, moduleAddress)
    }

    public func getModuleByName(moduleType: UInt8, name: [UInt32]) async throws -> ([UInt32], EthereumAddress) {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("getModuleByName", parameters: [moduleType, name])!.callContractMethod()
        guard let moduleList = result["0"] as? [UInt32] else { throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node") }
        guard let moduleAddress = result["1"] as? EthereumAddress else { throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node") }
        return (moduleList, moduleAddress)
    }

    public func totalSupplyAt(checkpointId: BigUInt) async throws -> BigUInt {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("totalSupplyAt", parameters: [checkpointId])!.callContractMethod()
        guard let res = result["0"] as? BigUInt else { throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node") }
        return res
    }

    public func balanceOfAt(investor: EthereumAddress, checkpointId: BigUInt) async throws -> BigUInt {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("balanceOfAt", parameters: [investor, checkpointId])!.callContractMethod()
        guard let res = result["0"] as? BigUInt else { throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node") }
        return res
    }

    public func createCheckpoint(from: EthereumAddress) throws -> WriteOperation {
        transaction.from = from
        transaction.to = self.address
        transaction.callOnBlock = .latest

        contract.transaction = transaction
        return contract.createWriteOperation("createCheckpoint")!

    }

    public func getInvestorsLength() async throws -> BigUInt {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("getInvestorsLength")!.callContractMethod()
        guard let res = result["0"] as? BigUInt else { throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node") }
        return res
    }
}
