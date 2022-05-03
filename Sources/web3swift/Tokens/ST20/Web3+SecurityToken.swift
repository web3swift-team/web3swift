//
//  Web3+SecurityToken.swift
//  web3swift
//
//  Created by Anton on 05/03/2019.
//  Copyright © 2019 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

/// The Ownable contract has an owner address, and provides basic authorization control functions, this simplifies the implementation of "user permissions".
protocol IOwnable {
    /// Allows the current owner to relinquish control of the contract.
    func renounceOwnership(from: EthereumAddress) throws -> WriteTransaction

    /// Allows the current owner to transfer control of the contract to a newOwner.
    func transferOwnership(from: EthereumAddress, newOwner: EthereumAddress) throws -> WriteTransaction
}

/// Security token interface
protocol ISecurityToken: IST20, IOwnable {
    /// Value of current checkpoint
    func currentCheckpointId() throws -> BigUInt

    func getGranularity() throws -> BigUInt

    /// Total number of non-zero token holders
    func investorCount() throws -> BigUInt

    /// List of token holders
    func investors() throws -> [EthereumAddress]

    /// Permissions this to a Permission module, which has a key of 1
    /// If no Permission return false - note that IModule withPerm will allow ST owner all permissions anyway
    /// this allows individual modules to override this logic if needed (to not allow ST owner all permissions)
    func checkPermission(delegate: EthereumAddress, module: EthereumAddress, perm: [UInt32]) throws -> Bool

    /// returns module list for a module type
    /// params:
    /// - moduleType is which type of module we are trying to remove
    /// - moduleIndex is the index of the module within the chosen type
    func getModule(moduleType: UInt8, moduleIndex: UInt8) throws -> ([UInt32], EthereumAddress)

    /// returns module list for a module name - will return first match
    /// params:
    /// - moduleType is which type of module we are trying to remove
    /// - name is the name of the module within the chosen type
    func getModuleByName(moduleType: UInt8, name: [UInt32]) throws -> ([UInt32], EthereumAddress)

    /// Queries totalSupply as of a defined checkpoint
    func totalSupplyAt(checkpointId: BigUInt) throws -> BigUInt

    /// Queries balances as of a defined checkpoint
    func balanceOfAt(investor: EthereumAddress, checkpointId: BigUInt) throws -> BigUInt

    /// Creates a checkpoint that can be used to query historical balances / totalSuppy
    func createCheckpoint(from: EthereumAddress) throws -> WriteTransaction

    /// gets length of investors array
    func getInvestorsLength() throws -> BigUInt
}

public class SecurityToken: ISecurityToken {

    private var _name: String? = nil
    private var _symbol: String? = nil
    private var _decimals: UInt8? = nil

    private var _hasReadProperties: Bool = false

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

    public init(web3: web3, provider: Web3Provider, address: EthereumAddress, abi: String = Web3.Utils.st20ABI) {
        self.web3 = web3
        self.provider = provider
        self.address = address
        var mergedOptions = web3.transactionOptions
        mergedOptions.to = address
        self.abi = abi
        self.transactionOptions = mergedOptions
    }

    public var name: String {
        self.readProperties()
        if self._name != nil {
            return self._name!
        }
        return ""
    }

    public var symbol: String {
        self.readProperties()
        if self._symbol != nil {
            return self._symbol!
        }
        return ""
    }

    // Must be 18!
    public var decimals: UInt8 {
        self.readProperties()
        if self._decimals != nil {
            return self._decimals!
        }
        return 18
    }

    public func readProperties() {
        if self._hasReadProperties {
            return
        }
        let contract = self.contract
        guard contract.contract.address != nil else {return}
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.callOnBlock = .latest
        guard let namePromise = contract.read("name", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)?.callPromise() else {return}

        guard let symbolPromise = contract.read("symbol", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)?.callPromise() else {return}

        guard let decimalPromise = contract.read("decimals", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)?.callPromise() else {return}

        let allPromises = [namePromise, symbolPromise, decimalPromise]
        let queue = self.web3.requestDispatcher.queue
        when(resolved: allPromises).map(on: queue) { (resolvedPromises) -> Void in
            guard case .fulfilled(let nameResult) = resolvedPromises[0] else {return}
            guard let name = nameResult["0"] as? String else {return}
            self._name = name

            guard case .fulfilled(let symbolResult) = resolvedPromises[1] else {return}
            guard let symbol = symbolResult["0"] as? String else {return}
            self._symbol = symbol

            guard case .fulfilled(let decimalsResult) = resolvedPromises[2] else {return}
            guard let decimals = decimalsResult["0"] as? BigUInt else {return}
            self._decimals = UInt8(decimals)

            self._hasReadProperties = true
            }.wait()
    }

    func tokenDetails() throws -> [UInt32] {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("tokenDetails", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? [UInt32] else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func verifyTransfer(from: EthereumAddress, originalOwner: EthereumAddress, to: EthereumAddress, amount: String) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try contract.read("decimals", transactionOptions: basicOptions)!.call()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let tx = contract.write("verifyTransfer", parameters: [originalOwner, to, value] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    func mint(from: EthereumAddress, investor: EthereumAddress, amount: String) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try contract.read("decimals", transactionOptions: basicOptions)!.call()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let tx = contract.write("mint", parameters: [investor, value] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func burn(from: EthereumAddress, amount: String) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try contract.read("decimals", transactionOptions: basicOptions)!.call()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        let tx = contract.write("burn", parameters: [value] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func getBalance(account: EthereumAddress) throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("balanceOf", parameters: [account] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getAllowance(originalOwner: EthereumAddress, delegate: EthereumAddress) throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("allowance", parameters: [originalOwner, delegate] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func transfer(from: EthereumAddress, to: EthereumAddress, amount: String) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try contract.read("decimals", transactionOptions: basicOptions)!.call()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        let tx = contract.write("transfer", parameters: [to, value] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try contract.read("decimals", transactionOptions: basicOptions)!.call()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let tx = contract.write("transferFrom", parameters: [originalOwner, to, value] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func setAllowance(from: EthereumAddress, to: EthereumAddress, newAmount: String) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try contract.read("decimals", transactionOptions: basicOptions)!.call()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(newAmount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let tx = contract.write("setAllowance", parameters: [to, value] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func approve(from: EthereumAddress, spender: EthereumAddress, amount: String) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try contract.read("decimals", transactionOptions: basicOptions)!.call()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped

        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }

        let tx = contract.write("approve", parameters: [spender, value] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func totalSupply() throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("totalSupply", parameters: [AnyObject](), extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func renounceOwnership(from: EthereumAddress) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        let tx = contract.write("renounceOwnership", parameters: [AnyObject](), transactionOptions: basicOptions)!
        return tx
    }

    public func transferOwnership(from: EthereumAddress, newOwner: EthereumAddress) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        let tx = contract.write("transferOwnership", parameters: [newOwner] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func currentCheckpointId() throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("currentCheckpointId", parameters: [AnyObject](), extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getGranularity() throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("granularity", parameters: [AnyObject](), extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func investorCount() throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("investorCount", parameters: [AnyObject](), extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func investors() throws -> [EthereumAddress] {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("investors", parameters: [AnyObject](), extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? [EthereumAddress] else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func checkPermission(delegate: EthereumAddress, module: EthereumAddress, perm: [UInt32]) throws -> Bool {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("checkPermission", parameters: [delegate, module, perm] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getModule(moduleType: UInt8, moduleIndex: UInt8) throws -> ([UInt32], EthereumAddress) {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("getModule", parameters: [moduleType, moduleIndex] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let moduleList = result["0"] as? [UInt32] else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        guard let moduleAddress = result["1"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return (moduleList, moduleAddress)
    }

    public func getModuleByName(moduleType: UInt8, name: [UInt32]) throws -> ([UInt32], EthereumAddress) {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("getModuleByName", parameters: [moduleType, name] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let moduleList = result["0"] as? [UInt32] else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        guard let moduleAddress = result["1"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return (moduleList, moduleAddress)
    }

    public func totalSupplyAt(checkpointId: BigUInt) throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("totalSupplyAt", parameters: [checkpointId] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func balanceOfAt(investor: EthereumAddress, checkpointId: BigUInt) throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("balanceOfAt", parameters: [investor, checkpointId] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func createCheckpoint(from: EthereumAddress) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        let tx = contract.write("createCheckpoint", parameters: [AnyObject](), transactionOptions: basicOptions)!
        return tx
    }

    public func getInvestorsLength() throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("getInvestorsLength", parameters: [AnyObject](), extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
}
