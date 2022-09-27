//
//  Web3+ERC1400.swift
//
//  Created by Anton Grigorev on 14/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//
import Foundation
import BigInt
import Core


// Security Token Standard
protocol IERC1400: IERC20 {

    // Document Management
    func getDocument(name: Data) async throws -> (String, Data)
    func setDocument(from: EthereumAddress, name: Data, uri: String, documentHash: Data) async throws -> WriteOperation

    // Token Information
    func balanceOfByPartition(partition: Data, tokenHolder: EthereumAddress) async throws -> BigUInt
    func partitionsOf(tokenHolder: EthereumAddress) async throws -> [Data]

    // Transfers
    func transferWithData(from: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation
    func transferFromWithData(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation

    // Partition Token Transfers
    func transferByPartition(partition: Data, from: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation
    func operatorTransferByPartition(partition: Data, from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) async throws -> WriteOperation

    // Controller Operation
    func isControllable() async throws -> Bool
    func controllerTransfer(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) async throws -> WriteOperation
    func controllerRedeem(from: EthereumAddress, tokenHolder: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) async throws -> WriteOperation

    // Operator Management
    func authorizeOperator(from: EthereumAddress, operator user: EthereumAddress) async throws -> WriteOperation
    func revokeOperator(from: EthereumAddress, operator user: EthereumAddress) async throws -> WriteOperation
    func authorizeOperatorByPartition(from: EthereumAddress, partition: Data, operator user: EthereumAddress) async throws -> WriteOperation
    func revokeOperatorByPartition(from: EthereumAddress, partition: Data, operator user: EthereumAddress) async throws -> WriteOperation

    // Operator Information
    func isOperator(operator user: EthereumAddress, tokenHolder: EthereumAddress) async throws -> Bool
    func isOperatorForPartition(partition: Data, operator user: EthereumAddress, tokenHolder: EthereumAddress) async throws -> Bool

    // Token Issuance
    func isIssuable() async throws -> Bool
    func issue(from: EthereumAddress, tokenHolder: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation
    func issueByPartition(from: EthereumAddress, partition: Data, tokenHolder: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation

    // Token Redemption
    func redeem(from: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation
    func redeemFrom(from: EthereumAddress, tokenHolder: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation
    func redeemByPartition(from: EthereumAddress, partition: Data, amount: String, data: [UInt8]) async throws -> WriteOperation
    func operatorRedeemByPartition(from: EthereumAddress, partition: Data, tokenHolder: EthereumAddress, amount: String, operatorData: [UInt8]) async throws -> WriteOperation

    // Transfer Validity
    func canTransfer(to: EthereumAddress, amount: String, data: [UInt8]) async throws -> ([UInt8], Data)
    func canTransferFrom(originalOwner: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8]) async throws -> ([UInt8], Data)
    func canTransferByPartition(originalOwner: EthereumAddress, to: EthereumAddress, partition: Data, amount: String, data: [UInt8]) async throws -> ([UInt8], Data, Data)
}

// This namespace contains functions to work with ERC1400 tokens.
// variables are lazyly evaluated or global token information (name, ticker, total supply)
// can be imperatively read and saved
// FIXME: Rewrite this to CodableTransaction
public class ERC1400: IERC1400, ERC20BaseProperties {

    internal var _name: String? = nil
    internal var _symbol: String? = nil
    internal var _decimals: UInt8? = nil
    internal var _hasReadProperties: Bool = false

    public var transaction: CodableTransaction
    public var web3: Web3
    public var provider: Web3Provider
    public var address: EthereumAddress
    public var abi: String

    lazy var contract: Web3.Contract = {
        let contract = self.web3.contract(self.abi, at: self.address, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()

    public init(web3: Web3, provider: Web3Provider, address: EthereumAddress, abi: String = Web3.Utils.erc1400ABI, transaction: CodableTransaction = .emptyTransaction) {
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

    // ERC1400 methods
    public func getDocument(name: Data) async throws -> (String, Data) {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("getDocument", parameters: [name] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? (String, Data) else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func setDocument(from: EthereumAddress, name: Data, uri: String, documentHash: Data) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address

        let tx = contract.createWriteOperation("setDocument", parameters: [name, uri, documentHash] as [AnyObject] )!
        return tx
    }

    public func balanceOfByPartition(partition: Data, tokenHolder: EthereumAddress) async throws -> BigUInt {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("balanceOfByPartition", parameters: [partition, tokenHolder] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func partitionsOf(tokenHolder: EthereumAddress) async throws -> [Data] {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("partitionsOf", parameters: [tokenHolder] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? [Data] else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func transferWithData(from: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation {
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

        let tx = contract.createWriteOperation("transferWithData", parameters: [to, value, data] as [AnyObject] )!
        return tx
    }

    public func transferFromWithData(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation {
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

        let tx = contract.createWriteOperation("transferFromWithData", parameters: [originalOwner, to, value, data] as [AnyObject] )!
        return tx
    }

    public func transferByPartition(partition: Data, from: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation {
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

        let tx = contract.createWriteOperation("transferByPartition", parameters: [partition, to, value, data] as [AnyObject] )!
        return tx
    }

    public func operatorTransferByPartition(partition: Data, from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) async throws -> WriteOperation {
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

        let tx = contract.createWriteOperation("operatorTransferByPartition", parameters: [partition, originalOwner, to, value, data, operatorData] as [AnyObject] )!
        return tx
    }

    public func isControllable() async throws -> Bool {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("isControllable", parameters: [AnyObject](), extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func controllerTransfer(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) async throws -> WriteOperation {
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

        let tx = contract.createWriteOperation("controllerTransfer", parameters: [originalOwner, to, value, data, operatorData] as [AnyObject] )!
        return tx
    }

    public func controllerRedeem(from: EthereumAddress, tokenHolder: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) async throws -> WriteOperation {
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

        let tx = contract.createWriteOperation("controllerRedeem", parameters: [tokenHolder, value, data, operatorData] as [AnyObject] )!
        return tx
    }

    public func authorizeOperator(from: EthereumAddress, operator user: EthereumAddress) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address

        let tx = contract.createWriteOperation("authorizeOperator", parameters: [user] as [AnyObject] )!
        return tx
    }

    public func revokeOperator(from: EthereumAddress, operator user: EthereumAddress) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address

        let tx = contract.createWriteOperation("revokeOperator", parameters: [user] as [AnyObject] )!
        return tx
    }

    public func authorizeOperatorByPartition(from: EthereumAddress, partition: Data, operator user: EthereumAddress) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address

        let tx = contract.createWriteOperation("authorizeOperatorByPartition", parameters: [partition, user] as [AnyObject] )!
        return tx
    }

    public func revokeOperatorByPartition(from: EthereumAddress, partition: Data, operator user: EthereumAddress) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address

        let tx = contract.createWriteOperation("revokeOperatorByPartition", parameters: [partition, user] as [AnyObject] )!
        return tx
    }

    public func isOperator(operator user: EthereumAddress, tokenHolder: EthereumAddress) async throws -> Bool {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("isOperator", parameters: [user, tokenHolder] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func isOperatorForPartition(partition: Data, operator user: EthereumAddress, tokenHolder: EthereumAddress) async throws -> Bool {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("isOperatorForPartition", parameters: [partition, user, tokenHolder] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func isIssuable() async throws -> Bool {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("isIssuable", parameters: [AnyObject](), extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func issue(from: EthereumAddress, tokenHolder: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation {
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

        let tx = contract.createWriteOperation("issue", parameters: [tokenHolder, value, data] as [AnyObject] )!
        return tx
    }

    public func issueByPartition(from: EthereumAddress, partition: Data, tokenHolder: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation {
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

        let tx = contract.createWriteOperation("issueByPartition", parameters: [partition, tokenHolder, value, data] as [AnyObject] )!
        return tx
    }

    public func redeem(from: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation {
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

        let tx = contract.createWriteOperation("redeem", parameters: [value, data] as [AnyObject] )!
        return tx
    }

    public func redeemFrom(from: EthereumAddress, tokenHolder: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation {
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

        let tx = contract.createWriteOperation("redeemFrom", parameters: [tokenHolder, value, data] as [AnyObject] )!
        return tx
    }

    public func redeemByPartition(from: EthereumAddress, partition: Data, amount: String, data: [UInt8]) async throws -> WriteOperation {
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

        let tx = contract.createWriteOperation("redeemByPartition", parameters: [partition, value, data] as [AnyObject] )!
        return tx
    }

    public func operatorRedeemByPartition(from: EthereumAddress, partition: Data, tokenHolder: EthereumAddress, amount: String, operatorData: [UInt8]) async throws -> WriteOperation {
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

        let tx = contract.createWriteOperation("operatorRedeemByPartition", parameters: [partition, tokenHolder, value, operatorData] as [AnyObject] )!
        return tx
    }

    public func canTransfer(to: EthereumAddress, amount: String, data: [UInt8]) async throws -> ([UInt8], Data) {
        let contract = self.contract
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

        let result = try await contract.createReadOperation("canTransfer", parameters: [to, value, data] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? ([UInt8], Data) else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func canTransferFrom(originalOwner: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8]) async throws -> ([UInt8], Data) {
        let contract = self.contract
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

        let result = try await contract.createReadOperation("canTransfer", parameters: [originalOwner, to, value, data] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? ([UInt8], Data) else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func canTransferByPartition(originalOwner: EthereumAddress, to: EthereumAddress, partition: Data, amount: String, data: [UInt8]) async throws -> ([UInt8], Data, Data) {
        let contract = self.contract
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

        let result = try await contract.createReadOperation("canTransfer", parameters: [originalOwner, to, partition, value, data] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? ([UInt8], Data, Data) else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
}

extension ERC1400: IERC777 {
    public func canImplementInterfaceForAddress(interfaceHash: Data, addr: EthereumAddress) async throws -> Data {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("canImplementInterfaceForAddress", parameters: [interfaceHash, addr] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? Data else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getInterfaceImplementer(addr: EthereumAddress, interfaceHash: Data) async throws -> EthereumAddress {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("getInterfaceImplementer", parameters: [addr, interfaceHash] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func setInterfaceImplementer(from: EthereumAddress, addr: EthereumAddress, interfaceHash: Data, implementer: EthereumAddress) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address

        let tx = contract.createWriteOperation("setInterfaceImplementer", parameters: [addr, interfaceHash, implementer] as [AnyObject] )!
        return tx
    }

    public func setManager(from: EthereumAddress, addr: EthereumAddress, newManager: EthereumAddress) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address

        let tx = contract.createWriteOperation("setManager", parameters: [addr, newManager] as [AnyObject] )!
        return tx
    }

    public func interfaceHash(interfaceName: String) async throws -> Data {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("interfaceHash", parameters: [interfaceName] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? Data else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func updateERC165Cache(from: EthereumAddress, contract: EthereumAddress, interfaceId: [UInt8]) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address

        let tx = contract.createWriteOperation("updateERC165Cache", parameters: [contract, interfaceId] as [AnyObject] )!
        return tx
    }

    public func supportsInterface(interfaceID: String) async throws -> Bool {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        self.transaction.gasLimitPolicy = .manual(30000)
        let result = try await contract.createReadOperation("supportsInterface", parameters: [interfaceID] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getGranularity() async throws -> BigUInt {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("granularity", parameters: [] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getDefaultOperators() async throws -> [EthereumAddress] {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("defaultOperators", parameters: [] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? [EthereumAddress] else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func authorize(from: EthereumAddress, operator user: EthereumAddress) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address
        self.transaction.callOnBlock = .latest

        let tx = contract.createWriteOperation("authorizeOperator", parameters: [user] as [AnyObject] )!
        return tx
    }

    public func revoke(from: EthereumAddress, operator user: EthereumAddress) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address
        self.transaction.callOnBlock = .latest

        let tx = contract.createWriteOperation("revokeOperator", parameters: [user] as [AnyObject] )!
        return tx
    }

    public func isOperatorFor(operator user: EthereumAddress, tokenHolder: EthereumAddress) async throws -> Bool {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("isOperatorFor", parameters: [user, tokenHolder] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func send(from: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation {
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
        let tx = contract.createWriteOperation("send", parameters: [to, value, data] as [AnyObject] )!
        return tx
    }

    public func operatorSend(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) async throws -> WriteOperation {
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
        let tx = contract.createWriteOperation("operatorSend", parameters: [originalOwner, to, value, data, operatorData] as [AnyObject] )!
        return tx
    }

    public func burn(from: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteOperation {
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
        let tx = contract.createWriteOperation("burn", parameters: [value, data] as [AnyObject] )!
        return tx
    }

    public func operatorBurn(from: EthereumAddress, amount: String, originalOwner: EthereumAddress, data: [UInt8], operatorData: [UInt8]) async throws -> WriteOperation {
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
        let tx = contract.createWriteOperation("burn", parameters: [originalOwner, value, data, operatorData] as [AnyObject] )!
        return tx
    }
}
