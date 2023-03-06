//
//  Web3+ERC777.swift
//
//  Created by Anton Grigorev on 07/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//
import Foundation
import BigInt
import Web3Core

// A New Advanced Token Standard
protocol IERC777: IERC20, IERC820 {
    func getDefaultOperators() async throws -> [EthereumAddress]
    func getGranularity() async throws -> BigUInt
    func getBalance(account: EthereumAddress) async throws -> BigUInt
    func getAllowance(originalOwner: EthereumAddress, delegate: EthereumAddress) async throws -> BigUInt
    func transfer(from: EthereumAddress, to: EthereumAddress, amount: String) async throws -> WriteOperation
    func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String) async throws -> WriteOperation
    func setAllowance(from: EthereumAddress, to: EthereumAddress, newAmount: String) async throws -> WriteOperation
    func authorize(from: EthereumAddress, operator user: EthereumAddress) async throws -> WriteOperation
    func revoke(from: EthereumAddress, operator user: EthereumAddress) async throws -> WriteOperation
    func isOperatorFor(operator user: EthereumAddress, tokenHolder: EthereumAddress) async throws -> Bool
    func send(from: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation
    func operatorSend(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) async throws -> WriteOperation
    func burn(from: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation
    func operatorBurn(from: EthereumAddress, amount: String, originalOwner: EthereumAddress, data: [UInt8], operatorData: [UInt8]) async throws -> WriteOperation
}

// This namespace contains functions to work with ERC777 tokens.
// can be imperatively read and saved
// FIXME: Rewrite this to CodableTransaction
public class ERC777: IERC777, ERC20BaseProperties {
    public private(set) var basePropertiesProvider: ERC20BasePropertiesProvider
    public var transaction: CodableTransaction
    public var web3: Web3
    public var provider: Web3Provider
    public var address: EthereumAddress
    public var abi: String

    public let contract: Web3.Contract

    public init(web3: Web3, provider: Web3Provider, address: EthereumAddress, abi: String = Web3.Utils.erc777ABI, transaction: CodableTransaction = .emptyTransaction) {
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

    public func getGranularity() async throws -> BigUInt {
        let result = try await contract.createReadOperation("granularity")!.callContractMethod()

        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getDefaultOperators() async throws -> [EthereumAddress] {
        let result = try await contract.createReadOperation("defaultOperators")!.callContractMethod()

        guard let res = result["0"] as? [EthereumAddress] else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
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

    // ERC777 methods
    public func authorize(from: EthereumAddress, operator user: EthereumAddress) throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("authorizeOperator", parameters: [user])!
        return tx
    }

    public func revoke(from: EthereumAddress, operator user: EthereumAddress) throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("revokeOperator", parameters: [user])!
        return tx
    }

    public func isOperatorFor(operator user: EthereumAddress, tokenHolder: EthereumAddress) async throws -> Bool {
        let result = try await contract.createReadOperation("isOperatorFor", parameters: [user, tokenHolder])!.callContractMethod()

        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func send(from: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation {
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
        let tx = contract.createWriteOperation("send", parameters: [to, value, data])!
        return tx
    }

    public func operatorSend(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) async throws -> WriteOperation {
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
        let tx = contract.createWriteOperation("operatorSend", parameters: [originalOwner, to, value, data, operatorData])!
        return tx
    }

    public func burn(from: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation {
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
        let tx = contract.createWriteOperation("burn", parameters: [value, data])!
        return tx
    }

    public func operatorBurn(from: EthereumAddress, amount: String, originalOwner: EthereumAddress, data: [UInt8], operatorData: [UInt8]) async throws -> WriteOperation {
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
        let tx = contract.createWriteOperation("burn", parameters: [originalOwner, value, data, operatorData])!
        return tx
    }

    public func canImplementInterfaceForAddress(interfaceHash: Data, addr: EthereumAddress) async throws -> Data {
        let result = try await contract.createReadOperation("canImplementInterfaceForAddress", parameters: [interfaceHash, addr])!.callContractMethod()

        guard let res = result["0"] as? Data else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getInterfaceImplementer(addr: EthereumAddress, interfaceHash: Data) async throws -> EthereumAddress {
        let result = try await contract.createReadOperation("getInterfaceImplementer", parameters: [addr, interfaceHash])!.callContractMethod()

        guard let res = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func setInterfaceImplementer(from: EthereumAddress, addr: EthereumAddress, interfaceHash: Data, implementer: EthereumAddress) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("setInterfaceImplementer", parameters: [addr, interfaceHash, implementer])!
        return tx
    }

    public func setManager(from: EthereumAddress, addr: EthereumAddress, newManager: EthereumAddress) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("setManager", parameters: [addr, newManager])!
        return tx
    }

    public func interfaceHash(interfaceName: String) async throws -> Data {
        let result = try await contract.createReadOperation("interfaceHash", parameters: [interfaceName])!.callContractMethod()

        guard let res = result["0"] as? Data else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    // FIXME: might want to rename contract param here
    public func updateERC165Cache(from: EthereumAddress, contract: EthereumAddress, interfaceId: [UInt8]) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = self.contract.createWriteOperation("updateERC165Cache", parameters: [contract, interfaceId])!
        return tx
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

    public func supportsInterface(interfaceID: String) async throws -> Bool {
        let result = try await contract.createReadOperation("supportsInterface", parameters: [interfaceID])!.callContractMethod()

        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

}

// MARK: - Private

extension ERC777 {

    private func updateTransactionAndContract(from: EthereumAddress) {
        transaction.from = from
        transaction.to = address
        contract.transaction = transaction
    }

}
