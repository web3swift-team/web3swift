//
//  Web3+ERC1410.swift
//  web3swift-iOS
//
//  Created by Anton Grigorev on 19/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt

//Partially Fungible Token Standard
protocol IERC1410: IERC20 {

    // Token Information
    func getBalance(account: EthereumAddress) async throws -> BigUInt
    func balanceOfByPartition(partition: Data, tokenHolder: EthereumAddress) async throws -> BigUInt
    func partitionsOf(tokenHolder: EthereumAddress) async throws -> [Data]
    func totalSupply() async throws -> BigUInt

    // Token Transfers
    func transferByPartition(partition: Data, from: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteTransaction
    func operatorTransferByPartition(partition: Data, from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) async throws -> WriteTransaction
    func canTransferByPartition(originalOwner: EthereumAddress, to: EthereumAddress, partition: Data, amount: String, data: [UInt8]) async throws -> ([UInt8], Data, Data)

    // Operator Information
    func isOperator(operator user: EthereumAddress, tokenHolder: EthereumAddress) async throws -> Bool
    func isOperatorForPartition(partition: Data, operator user: EthereumAddress, tokenHolder: EthereumAddress) async throws -> Bool

    // Operator Management
    func authorizeOperator(from: EthereumAddress, operator user: EthereumAddress) async throws -> WriteTransaction
    func revokeOperator(from: EthereumAddress, operator user: EthereumAddress) async throws -> WriteTransaction
    func authorizeOperatorByPartition(from: EthereumAddress, partition: Data, operator user: EthereumAddress) async throws -> WriteTransaction
    func revokeOperatorByPartition(from: EthereumAddress, partition: Data, operator user: EthereumAddress) async throws -> WriteTransaction

    // Issuance / Redemption
    func issueByPartition(from: EthereumAddress, partition: Data, tokenHolder: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteTransaction
    func redeemByPartition(from: EthereumAddress, partition: Data, amount: String, data: [UInt8]) async throws -> WriteTransaction
    func operatorRedeemByPartition(from: EthereumAddress, partition: Data, tokenHolder: EthereumAddress, amount: String, operatorData: [UInt8]) async throws -> WriteTransaction

}

public class ERC1410: IERC1410, ERC20BaseProperties {

    internal var _name: String? = nil
    internal var _symbol: String? = nil
    internal var _decimals: UInt8? = nil
    private var _totalSupply: BigUInt? = nil
    internal var _hasReadProperties: Bool = false

    public var transactionOptions: TransactionOptions
    public var web3: web3
    public var provider: Web3Provider
    public var address: EthereumAddress
    public var abi: String

    lazy var contract: web3.web3contract = {
        let contract = self.web3.contract(self.abi, at: self.address, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()

    public init(web3: web3, provider: Web3Provider, address: EthereumAddress, abi: String = Web3.Utils.erc1410ABI) {
        self.web3 = web3
        self.provider = provider
        self.address = address
        var mergedOptions = web3.transactionOptions
        mergedOptions.to = address
        self.abi = abi
        self.transactionOptions = mergedOptions
    }

    public func getBalance(account: EthereumAddress) async throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("balanceOf", parameters: [account] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getAllowance(originalOwner: EthereumAddress, delegate: EthereumAddress) async throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("allowance", parameters: [originalOwner, delegate] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func transfer(from: EthereumAddress, to: EthereumAddress, amount: String) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: basicOptions)?.call()
        var decimals = BigUInt(0)
        guard let dec = callResult?["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        guard let tx = contract.write("transfer", parameters: [to, value] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: basicOptions)?.call()
        var decimals = BigUInt(0)
        guard let dec = callResult?["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        guard let tx = contract.write("transferFrom", parameters: [originalOwner, to, value] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func setAllowance(from: EthereumAddress, to: EthereumAddress, newAmount: String) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: basicOptions)?.call()
        var decimals = BigUInt(0)
        guard let dec = callResult?["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(newAmount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        guard let tx = contract.write("setAllowance", parameters: [to, value] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func totalSupply() async throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("totalSupply", parameters: [AnyObject](), extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func approve(from: EthereumAddress, spender: EthereumAddress, amount: String) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: basicOptions)?.call()
        var decimals = BigUInt(0)
        guard let dec = callResult?["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        guard let tx = contract.write("approve", parameters: [spender, value] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    //ERC1410 methods
    public func balanceOfByPartition(partition: Data, tokenHolder: EthereumAddress) async throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("balanceOfByPartition", parameters: [partition, tokenHolder] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func partitionsOf(tokenHolder: EthereumAddress) async throws -> [Data] {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("partitionsOf", parameters: [tokenHolder] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? [Data] else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func transferByPartition(partition: Data, from: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: basicOptions)?.call()
        var decimals = BigUInt(0)
        guard let dec = callResult?["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        guard let tx = contract.write("transferByPartition", parameters: [partition, to, value, data] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func operatorTransferByPartition(partition: Data, from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: basicOptions)?.call()
        var decimals = BigUInt(0)
        guard let dec = callResult?["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        guard let tx = contract.write("operatorTransferByPartition", parameters: [partition, originalOwner, to, value, data, operatorData] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func canTransferByPartition(originalOwner: EthereumAddress, to: EthereumAddress, partition: Data, amount: String, data: [UInt8]) async throws -> ([UInt8], Data, Data) {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: transactionOptions)?.call()
        var decimals = BigUInt(0)
        guard let dec = callResult?["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let result = try await contract.read("canTransfer", parameters: [originalOwner, to, partition, value, data] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? ([UInt8], Data, Data) else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func isOperator(operator user: EthereumAddress, tokenHolder: EthereumAddress) async throws -> Bool {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("isOperator", parameters: [user, tokenHolder] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func isOperatorForPartition(partition: Data, operator user: EthereumAddress, tokenHolder: EthereumAddress) async throws -> Bool {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("isOperatorForPartition", parameters: [partition, user, tokenHolder] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func authorizeOperator(from: EthereumAddress, operator user: EthereumAddress) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        guard let tx = contract.write("authorizeOperator", parameters: [user] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func revokeOperator(from: EthereumAddress, operator user: EthereumAddress) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        guard let tx = contract.write("revokeOperator", parameters: [user] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func authorizeOperatorByPartition(from: EthereumAddress, partition: Data, operator user: EthereumAddress) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        guard let tx = contract.write("authorizeOperatorByPartition", parameters: [partition, user] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func revokeOperatorByPartition(from: EthereumAddress, partition: Data, operator user: EthereumAddress) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        guard let tx = contract.write("revokeOperatorByPartition", parameters: [partition, user] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func issueByPartition(from: EthereumAddress, partition: Data, tokenHolder: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: basicOptions)?.call()
        var decimals = BigUInt(0)
        guard let dec = callResult?["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        guard let tx = contract.write("issueByPartition", parameters: [partition, tokenHolder, value, data] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func redeemByPartition(from: EthereumAddress, partition: Data, amount: String, data: [UInt8]) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: basicOptions)?.call()
        var decimals = BigUInt(0)
        guard let dec = callResult?["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        guard let tx = contract.write("redeemByPartition", parameters: [partition, value, data] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func operatorRedeemByPartition(from: EthereumAddress, partition: Data, tokenHolder: EthereumAddress, amount: String, operatorData: [UInt8]) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: basicOptions)?.call()
        var decimals = BigUInt(0)
        guard let dec = callResult?["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        guard let tx = contract.write("operatorRedeemByPartition", parameters: [partition, tokenHolder, value, operatorData] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }
}

extension ERC1410: IERC777 {
    public func canImplementInterfaceForAddress(interfaceHash: Data, addr: EthereumAddress) async throws -> Data {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("canImplementInterfaceForAddress", parameters: [interfaceHash, addr] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? Data else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getInterfaceImplementer(addr: EthereumAddress, interfaceHash: Data) async throws -> EthereumAddress {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("getInterfaceImplementer", parameters: [addr, interfaceHash] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func setInterfaceImplementer(from: EthereumAddress, addr: EthereumAddress, interfaceHash: Data, implementer: EthereumAddress) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from

        guard let tx = contract.write("setInterfaceImplementer", parameters: [addr, interfaceHash, implementer] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func setManager(from: EthereumAddress, addr: EthereumAddress, newManager: EthereumAddress) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from

        guard let tx = contract.write("setManager", parameters: [addr, newManager] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func interfaceHash(interfaceName: String) async throws -> Data {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("interfaceHash", parameters: [interfaceName] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? Data else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func updateERC165Cache(from: EthereumAddress, contract: EthereumAddress, interfaceId: [UInt8]) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from

        guard let tx = contract.write("updateERC165Cache", parameters: [contract, interfaceId] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func supportsInterface(interfaceID: String) async throws -> Bool {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        transactionOptions.gasLimit = .manual(30000)
        let result = try await contract.read("supportsInterface", parameters: [interfaceID] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func authorize(from: EthereumAddress, operator user: EthereumAddress) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.callOnBlock = .latest

        guard let tx = contract.write("authorizeOperator", parameters: [user] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func revoke(from: EthereumAddress, operator user: EthereumAddress) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.callOnBlock = .latest

        guard let tx = contract.write("revokeOperator", parameters: [user] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func isOperatorFor(operator user: EthereumAddress, tokenHolder: EthereumAddress) async throws -> Bool {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("isOperatorFor", parameters: [user, tokenHolder] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func send(from: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: basicOptions)?.call()
        var decimals = BigUInt(0)
        guard let dec = callResult?["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        guard let tx = contract.write("send", parameters: [to, value, data] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func operatorSend(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: basicOptions)?.call()
        var decimals = BigUInt(0)
        guard let dec = callResult?["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        guard let tx = contract.write("operatorSend", parameters: [originalOwner, to, value, data, operatorData] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func burn(from: EthereumAddress, amount: String, data: [UInt8]) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: basicOptions)?.call()
        var decimals = BigUInt(0)
        guard let dec = callResult?["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        guard let tx = contract.write("burn", parameters: [value, data] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func operatorBurn(from: EthereumAddress, amount: String, originalOwner: EthereumAddress, data: [UInt8], operatorData: [UInt8]) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: basicOptions)?.call()
        var decimals = BigUInt(0)
        guard let dec = callResult?["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        guard let tx = contract.write("burn", parameters: [originalOwner, value, data, operatorData] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }

    public func getGranularity() async throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("granularity", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getDefaultOperators() async throws -> [EthereumAddress] {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("defaultOperators", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? [EthereumAddress] else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
}
