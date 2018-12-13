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
import EthereumAddress

protocol IERC777 {
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

// This namespace contains functions to work with ERC721 tokens.
// can be imperatively read and saved
public class ERC777: IERC777 {
    
    private var _name: String? = nil
    private var _symbol: String? = nil
    private var _decimals: UInt8? = nil
    private var _totalSupply: BigUInt? = nil
    private var _granularity: BigUInt? = nil
    private var _defaultOperators: [EthereumAddress]? = nil
    
    private var _hasReadProperties: Bool = false
    
    public var transactionOptions: TransactionOptions
    public var web3: web3
    public var provider: Web3Provider
    public var address: EthereumAddress
    
    lazy var contract: web3.web3contract = {
        // TODO: - need erc777abi
        let contract = self.web3.contract(Web3.Utils.erc777ABI, at: self.address, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()
    
    public init(web3: web3, provider: Web3Provider, address: EthereumAddress) {
        self.web3 = web3
        self.provider = provider
        self.address = address
        var mergedOptions = web3.transactionOptions
        mergedOptions.to = address
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
    
    public var decimals: UInt8 {
        self.readProperties()
        if self._decimals != nil {
            return self._decimals!
        }
        return 18
    }
    
    public var totalSupply: BigUInt {
        self.readProperties()
        if self._totalSupply != nil {
            return self._totalSupply!
        }
        return 0
    }
    
    public var granularity: BigUInt {
        self.readProperties()
        if self._granularity != nil {
            return self._granularity!
        }
        return 1
    }
    
    public var defaultOperators: [EthereumAddress] {
        self.readProperties()
        if self._defaultOperators != nil {
            return self._defaultOperators!
        }
        return []
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
        
        guard let totalSupplyPromise = contract.read("totalSupply", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)?.callPromise() else {return}
        
        guard let granularityPromise = contract.read("granularity", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)?.callPromise() else {return}
        
        guard let defaultOperatorsPromise = contract.read("defaultOperators", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)?.callPromise() else {return}
        
        let allPromises = [namePromise, symbolPromise, decimalPromise, totalSupplyPromise, granularityPromise, defaultOperatorsPromise]
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
            
            guard case .fulfilled(let totalSupplyResult) = resolvedPromises[3] else {return}
            guard let totalSupply = totalSupplyResult["0"] as? BigUInt else {return}
            self._totalSupply = totalSupply
            
            guard case .fulfilled(let granularityResult) = resolvedPromises[4] else {return}
            guard let granularity = granularityResult["0"] as? BigUInt else {return}
            self._granularity = granularity
            
            guard case .fulfilled(let defaultOperatorsResult) = resolvedPromises[5] else {return}
            guard let defaultOperators = defaultOperatorsResult["0"] as? [EthereumAddress] else {return}
            self._defaultOperators = defaultOperators
            
            self._hasReadProperties = true
            }.wait()
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
    
    /// ERC777 methods
    public func authorize(from: EthereumAddress, operator user: EthereumAddress) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.callOnBlock = .latest
        
        let tx = contract.write("authorizeOperator", parameters: [user] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    public func revoke(from: EthereumAddress, operator user: EthereumAddress) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
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
}
