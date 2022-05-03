//
//  Web3+ERC777.swift
//  web3swift
//
//  Created by Anton Grigorev on 07/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//
import Foundation
import BigInt
import PromiseKit

// A New Advanced Token Standard
protocol IERC777: IERC20, IERC820 {
    func getDefaultOperators() throws -> [EthereumAddress]
    func getGranularity() throws -> BigUInt
    func getBalance(account: EthereumAddress) throws -> BigUInt
    func getAllowance(originalOwner: EthereumAddress, delegate: EthereumAddress) throws -> BigUInt
    func transfer(from: EthereumAddress, to: EthereumAddress, amount: String) throws -> WriteTransaction
    func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String) throws -> WriteTransaction
    func setAllowance(from: EthereumAddress, to: EthereumAddress, newAmount: String) throws -> WriteTransaction
    func authorize(from: EthereumAddress, operator user: EthereumAddress) throws -> WriteTransaction
    func revoke(from: EthereumAddress, operator user: EthereumAddress) throws -> WriteTransaction
    func isOperatorFor(operator user: EthereumAddress, tokenHolder: EthereumAddress) throws -> Bool
    func send(from: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8]) throws -> WriteTransaction
    func operatorSend(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) throws -> WriteTransaction
    func burn(from: EthereumAddress, amount: String, data: [UInt8]) throws -> WriteTransaction
    func operatorBurn(from: EthereumAddress, amount: String, originalOwner: EthereumAddress, data: [UInt8], operatorData: [UInt8]) throws -> WriteTransaction
}

// This namespace contains functions to work with ERC777 tokens.
// can be imperatively read and saved
public class ERC777: IERC777 {

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

    public init(web3: web3, provider: Web3Provider, address: EthereumAddress, abi: String = Web3.Utils.erc777ABI) {
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

    public func getGranularity() throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("granularity", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getDefaultOperators() throws -> [EthereumAddress] {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("defaultOperators", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? [EthereumAddress] else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
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

    public func totalSupply() throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("totalSupply", parameters: [AnyObject](), extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    // ERC777 methods
    public func authorize(from: EthereumAddress, operator user: EthereumAddress) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        let tx = contract.write("authorizeOperator", parameters: [user] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func revoke(from: EthereumAddress, operator user: EthereumAddress) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        let tx = contract.write("revokeOperator", parameters: [user] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func isOperatorFor(operator user: EthereumAddress, tokenHolder: EthereumAddress) throws -> Bool {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("isOperatorFor", parameters: [user, tokenHolder] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func send(from: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8]) throws -> WriteTransaction {
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
        let tx = contract.write("send", parameters: [to, value, data] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func operatorSend(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) throws -> WriteTransaction {
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
        let tx = contract.write("operatorSend", parameters: [originalOwner, to, value, data, operatorData] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func burn(from: EthereumAddress, amount: String, data: [UInt8]) throws -> WriteTransaction {
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
        let tx = contract.write("burn", parameters: [value, data] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func operatorBurn(from: EthereumAddress, amount: String, originalOwner: EthereumAddress, data: [UInt8], operatorData: [UInt8]) throws -> WriteTransaction {
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
        let tx = contract.write("burn", parameters: [originalOwner, value, data, operatorData] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func canImplementInterfaceForAddress(interfaceHash: Data, addr: EthereumAddress) throws -> Data {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("canImplementInterfaceForAddress", parameters: [interfaceHash, addr] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? Data else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getInterfaceImplementer(addr: EthereumAddress, interfaceHash: Data) throws -> EthereumAddress {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("getInterfaceImplementer", parameters: [addr, interfaceHash] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func setInterfaceImplementer(from: EthereumAddress, addr: EthereumAddress, interfaceHash: Data, implementer: EthereumAddress) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        let tx = contract.write("setInterfaceImplementer", parameters: [addr, interfaceHash, implementer] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func setManager(from: EthereumAddress, addr: EthereumAddress, newManager: EthereumAddress) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        let tx = contract.write("setManager", parameters: [addr, newManager] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func interfaceHash(interfaceName: String) throws -> Data {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("interfaceHash", parameters: [interfaceName] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? Data else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func updateERC165Cache(from: EthereumAddress, contract: EthereumAddress, interfaceId: [UInt8]) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        let tx = contract.write("updateERC165Cache", parameters: [contract, interfaceId] as [AnyObject], transactionOptions: basicOptions)!
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

    public func supportsInterface(interfaceID: String) throws -> Bool {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        transactionOptions.gasLimit = .manual(30000)
        let result = try contract.read("supportsInterface", parameters: [interfaceID] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

}
