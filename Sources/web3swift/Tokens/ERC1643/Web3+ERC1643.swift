//
//  Web3+ERC1643.swift
//  web3swift-iOS
//
//  Created by Anton Grigorev on 19/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt

//Document Management Standard
protocol IERC1643: IERC20 {
    
    // Document Management
    func getDocument(name: Data) async throws -> (String, Data)
    func setDocument(from: EthereumAddress, name: Data, uri: String, documentHash: Data) async throws -> WriteTransaction
    func removeDocument(from: EthereumAddress, name: Data) async throws -> WriteTransaction
    func getAllDocuments() async throws -> [Data]
    
}

public class ERC1643: IERC1643, ERC20BaseProperties {
    
    internal var _name: String? = nil
    internal var _symbol: String? = nil
    internal var _decimals: UInt8? = nil
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
    
    public init(web3: web3, provider: Web3Provider, address: EthereumAddress, abi: String = Web3.Utils.erc1643ABI) {
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
    
    //ERC1643 methods
    public func getDocument(name: Data) async throws -> (String, Data) {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("getDocument", parameters: [name] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? (String, Data) else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
    
    public func setDocument(from: EthereumAddress, name: Data, uri: String, documentHash: Data) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        
        guard let tx = contract.write("setDocument", parameters: [name, uri, documentHash] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }
    
    public func removeDocument(from: EthereumAddress, name: Data) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        
        guard let tx = contract.write("removeDocument", parameters: [name] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write to contract")
        }
        return tx
    }
    
    public func getAllDocuments() async throws -> [Data] {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("getAllDocuments", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? [Data] else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
}
