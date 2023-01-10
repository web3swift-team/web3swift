//
//  Web3+ERC1376.swift
//
//  Created by Anton Grigorev on 20/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

public enum IERC1376DelegateMode: UInt {
    case PublicMsgSender = 0
    case PublicTxOrigin = 1
    case PrivateMsgSender = 2
    case PrivateTxOrigin = 3
}

public struct DirectDebitInfo {
    let amount: BigUInt
    let startTime: BigUInt
    let interval: BigUInt
}

public struct DirectDebit {
    let info: DirectDebitInfo
    let epoch: BigUInt
}

extension DirectDebit: Hashable {
}

extension DirectDebitInfo: Hashable {
}

// Service-Friendly Token Standard
protocol IERC1376: IERC20 {
    func approve(from: EthereumAddress, spender: EthereumAddress, expectedValue: String, newValue: String) async throws -> WriteOperation
    func increaseAllowance(from: EthereumAddress, spender: EthereumAddress, value: String) async throws -> WriteOperation
    func decreaseAllowance(from: EthereumAddress, spender: EthereumAddress, value: String, strict: Bool) async throws -> WriteOperation
    func setERC20ApproveChecking(from: EthereumAddress, approveChecking: Bool) async throws -> WriteOperation

    func spendableAllowance(owner: EthereumAddress, spender: EthereumAddress) async throws -> BigUInt
    func transfer(from: EthereumAddress, data: String) async throws -> WriteOperation
    func transferAndCall(from: EthereumAddress, to: EthereumAddress, value: String, data: [UInt8]) async throws -> WriteOperation

    func nonceOf(owner: EthereumAddress) async throws -> BigUInt
    func increaseNonce(from: EthereumAddress) async throws -> WriteOperation
    func delegateTransferAndCall(from: EthereumAddress,
                                 nonce: BigUInt,
                                 fee: BigUInt,
                                 gasAmount: BigUInt,
                                 to: EthereumAddress,
                                 value: String,
                                 data: [UInt8],
                                 mode: IERC1376DelegateMode,
                                 v: UInt8,
                                 r: Data,
                                 s: Data) async throws -> WriteOperation

    func directDebit(debtor: EthereumAddress, receiver: EthereumAddress) async throws -> DirectDebit
    func setupDirectDebit(from: EthereumAddress, receiver: EthereumAddress, info: DirectDebitInfo) async throws -> WriteOperation
    func terminateDirectDebit(from: EthereumAddress, receiver: EthereumAddress) async throws -> WriteOperation
    func withdrawDirectDebit(from: EthereumAddress, debtor: EthereumAddress) async throws -> WriteOperation
    func withdrawDirectDebit(from: EthereumAddress, debtors: [EthereumAddress], strict: Bool) async throws -> WriteOperation
}

// FIXME: Rewrite this to CodableTransaction
public class ERC1376: IERC1376, ERC20BaseProperties {
    public private(set) var basePropertiesProvider: ERC20BasePropertiesProvider
    public var transaction: CodableTransaction
    public var web3: Web3
    public var provider: Web3Provider
    public var address: EthereumAddress
    public var abi: String

    public let contract: Web3.Contract

    public init(web3: Web3, provider: Web3Provider, address: EthereumAddress, abi: String = Web3.Utils.erc1376ABI, transaction: CodableTransaction = .emptyTransaction) {
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
        let result = try await contract.createReadOperation("balanceOf", parameters: [account] as [AnyObject], extraData: Data())!.callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getAllowance(originalOwner: EthereumAddress, delegate: EthereumAddress) async throws -> BigUInt {
        let result = try await contract.createReadOperation("allowance", parameters: [originalOwner, delegate] as [AnyObject], extraData: Data())!.callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func transfer(from: EthereumAddress, to: EthereumAddress, amount: String) async throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
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
        let tx = contract.createWriteOperation("transfer", parameters: [to, value] as [AnyObject])!
        return tx
    }

    public func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String) async throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
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

        let tx = contract.createWriteOperation("transferFrom", parameters: [originalOwner, to, value] as [AnyObject])!
        return tx
    }

    public func setAllowance(from: EthereumAddress, to: EthereumAddress, newAmount: String) async throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
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

        let tx = contract.createWriteOperation("setAllowance", parameters: [to, value] as [AnyObject])!
        return tx
    }

    public func approve(from: EthereumAddress, spender: EthereumAddress, amount: String) async throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
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

        let tx = contract.createWriteOperation("approve", parameters: [spender, value] as [AnyObject])!
        return tx
    }

    public func totalSupply() async throws -> BigUInt {
        let result = try await contract.createReadOperation("totalSupply", parameters: [AnyObject](), extraData: Data())!.callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func approve(from: EthereumAddress, spender: EthereumAddress, expectedValue: String, newValue: String) async throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals" )!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let eValue = Utilities.parseToBigUInt(expectedValue, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        guard let nValue = Utilities.parseToBigUInt(newValue, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let tx = contract.createWriteOperation("approve", parameters: [spender, eValue, nValue] as [AnyObject])!
        return tx
    }

    func increaseAllowance(from: EthereumAddress, spender: EthereumAddress, value: String) async throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals" )!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let amount = Utilities.parseToBigUInt(value, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let tx = contract.createWriteOperation("increaseAllowance", parameters: [spender, amount] as [AnyObject])!
        return tx
    }

    func decreaseAllowance(from: EthereumAddress, spender: EthereumAddress, value: String, strict: Bool) async throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals" )!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let amount = Utilities.parseToBigUInt(value, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let tx = contract.createWriteOperation("decreaseAllowance", parameters: [spender, amount, strict] as [AnyObject])!
        return tx
    }

    func setERC20ApproveChecking(from: EthereumAddress, approveChecking: Bool) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("setERC20ApproveChecking", parameters: [approveChecking] as [AnyObject])!
        return tx
    }

    func spendableAllowance(owner: EthereumAddress, spender: EthereumAddress) async throws -> BigUInt {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("spendableAllowance", parameters: [owner, spender] as [AnyObject], extraData: Data())!.callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func transfer(from: EthereumAddress, data: String) async throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals" )!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(data, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        let tx = contract.createWriteOperation("transfer", parameters: [value] as [AnyObject])!
        return tx
    }

    func transferAndCall(from: EthereumAddress, to: EthereumAddress, value: String, data: [UInt8]) async throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals" )!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let amount = Utilities.parseToBigUInt(value, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        let tx = contract.createWriteOperation("transferAndCall", parameters: [to, amount, data] as [AnyObject])!
        return tx
    }

    func nonceOf(owner: EthereumAddress) async throws -> BigUInt {
        let result = try await contract.createReadOperation("nonceOf", parameters: [owner] as [AnyObject], extraData: Data())!.callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func increaseNonce(from: EthereumAddress) throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("increaseNonce", parameters: [] as [AnyObject])!
        return tx
    }

    func delegateTransferAndCall(from: EthereumAddress, nonce: BigUInt, fee: BigUInt, gasAmount: BigUInt, to: EthereumAddress, value: String, data: [UInt8], mode: IERC1376DelegateMode, v: UInt8, r: Data, s: Data) async throws -> WriteOperation {
        transaction.callOnBlock = .latest
        updateTransactionAndContract(from: from)
        // get the decimals manually
        let callResult = try await contract.createReadOperation("decimals" )!.callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let amount = Utilities.parseToBigUInt(value, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let modeValue = mode.rawValue

        let tx = contract.createWriteOperation("delegateTransferAndCall", parameters: [nonce, fee, gasAmount, to, amount, data, modeValue, v, r, s] as [AnyObject])!
        return tx
    }

    func directDebit(debtor: EthereumAddress, receiver: EthereumAddress) async throws -> DirectDebit {
        let result = try await contract.createReadOperation("directDebit", parameters: [debtor, receiver] as [AnyObject], extraData: Data())!.callContractMethod()
        guard let res = result["0"] as? DirectDebit else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func setupDirectDebit(from: EthereumAddress, receiver: EthereumAddress, info: DirectDebitInfo) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("setupDirectDebit", parameters: [receiver, info] as [AnyObject])!
        return tx
    }

    func terminateDirectDebit(from: EthereumAddress, receiver: EthereumAddress) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("terminateDirectDebit", parameters: [receiver] as [AnyObject])!
        return tx
    }

    func withdrawDirectDebit(from: EthereumAddress, debtor: EthereumAddress) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("withdrawDirectDebit", parameters: [debtor] as [AnyObject])!
        return tx
    }

    func withdrawDirectDebit(from: EthereumAddress, debtors: [EthereumAddress], strict: Bool) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("withdrawDirectDebit", parameters: [debtors, strict] as [AnyObject])!
        return tx
    }
}

// MARK: - Private

extension ERC1376 {

    private func updateTransactionAndContract(from: EthereumAddress) {
        transaction.from = from
        transaction.to = address
        contract.transaction = transaction
    }

}

