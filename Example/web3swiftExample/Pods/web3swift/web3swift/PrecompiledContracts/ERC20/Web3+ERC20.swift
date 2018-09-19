//
//  Web3+ERC721.swift
//  web3swift
//
//  Created by Alex Vlasov on 28.08.2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Result

// This namespace contains functions to work with ERC20 tokens.
// variables are lazyly evaluated or global token information (name, ticker, total supply)
// can be imperatively read and saved
class ERC20 {
    private var _name: String? = nil
    private var _symbol: String? = nil
    private var _decimals: UInt8? = nil
    private var _hasReadProperties: Bool = false
    
    public var options: Web3Options
    public var web3: web3
    public var provider: Web3Provider
    public var address: EthereumAddress
    
    lazy var contract: web3.web3contract = {
        let contract = self.web3.contract(Web3.Utils.erc20ABI, at: self.address, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()
    
    public init(web3: web3, provider: Web3Provider, address: EthereumAddress) {
        self.web3 = web3
        self.provider = provider
        self.address = address
        var mergedOptions = web3.options
        mergedOptions.to = address
        self.options = mergedOptions
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
        return 255
    }
    
    public func readProperties() {
        if self._hasReadProperties {
            return
        }
        defer { self._hasReadProperties = true }
        let contract = self.contract
        guard contract.contract.address != nil else {return}
        guard let nameResult = contract.method("name", parameters: [] as [AnyObject], extraData: Data(), options: self.options)?.call(options: nil, onBlock: "latest") else {return}
        switch nameResult {
        case .success(let returned):
            guard let res = returned["0"] as? String else {break}
            self._name = res
        default:
            self._name = ""
        }
        
        guard let symbol = contract.method("symbol", parameters: [] as [AnyObject], extraData: Data(), options: self.options)?.call(options: nil, onBlock: "latest") else {return}
        switch symbol {
        case .success(let returned):
            guard let res = returned["0"] as? String else {break}
            self._symbol = res
        default:
            self._symbol = ""
        }
        
        guard let decimalsResult = contract.method("decimals", parameters: [] as [AnyObject], extraData: Data(), options: self.options)?.call(options: nil, onBlock: "latest") else {return}
        switch decimalsResult {
        case .success(let returned):
            guard let res = returned["0"] as? BigUInt else {return}
            self._decimals = UInt8(res)
        default:
            self._decimals = 255
        }
    }
    
    func getBalance(account: EthereumAddress) -> Result<BigUInt, Web3Error> {
        let contract = self.contract
        let result = contract.method("balanceOf", parameters: [account] as [AnyObject], extraData: Data(), options: self.options)!.call(options: nil, onBlock: "latest")
        switch result {
        case .success(let returned):
            guard let res = returned["0"] as? BigUInt else {return Result.failure(Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node"))}
            return Result(res)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    func getAllowance(originalOwner: EthereumAddress, delegate: EthereumAddress) -> Result<BigUInt, Web3Error> {
        let contract = self.contract
        let result = contract.method("allowance", parameters: [originalOwner, delegate] as [AnyObject], extraData: Data(), options: self.options)!.call(options: nil, onBlock: "latest")
        switch result {
        case .success(let returned):
            guard let res = returned["0"] as? BigUInt else {return Result.failure(Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node"))}
            return Result(res)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    func transfer(from: EthereumAddress, to: EthereumAddress, amount: String) -> Result<TransactionIntermediate, Web3Error> {
        let contract = self.contract
        var basicOptions = Web3Options()
        basicOptions.from = from
        basicOptions.to = self.address
        
        // get the decimals manually
        let intermediate = contract.method("decimals", options: basicOptions)!
        let callResult = intermediate.call(options: basicOptions, onBlock: "latest")
        var decimals = BigUInt(0)
        switch callResult {
        case .success(let response):
            guard let dec = response["0"], let decTyped = dec as? BigUInt else {
                return Result.failure(Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals"))}
            decimals = decTyped
            break
        case .failure(let error):
            return Result.failure(error)
        }
        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            return Result.failure(Web3Error.inputError(desc: "Can not parse inputted amount"))
        }
        let intermediateToSend = contract.method("transfer", parameters: [to, value] as [AnyObject], options: basicOptions)!
        return Result(intermediateToSend)
    }

    func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String) -> Result<TransactionIntermediate, Web3Error> {
        let contract = self.contract
        var basicOptions = Web3Options()
        basicOptions.from = from
        basicOptions.to = self.address
        
        // get the decimals manually
        let intermediate = contract.method("decimals", options: basicOptions)!
        let callResult = intermediate.call(options: basicOptions, onBlock: "latest")
        var decimals = BigUInt(0)
        switch callResult {
        case .success(let response):
            guard let dec = response["0"], let decTyped = dec as? BigUInt else {
                return Result.failure(Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals"))}
            decimals = decTyped
            break
        case .failure(let error):
            return Result.failure(error)
        }
        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            return Result.failure(Web3Error.inputError(desc: "Can not parse inputted amount"))
        }
        let intermediateToSend = contract.method("transferFrom", parameters: [originalOwner, to, value] as [AnyObject], options: basicOptions)!
        return Result(intermediateToSend)
    }

    func setAllowance(from: EthereumAddress, to: EthereumAddress, newAmount: String) -> Result<TransactionIntermediate, Web3Error> {
        let contract = self.contract
        var basicOptions = Web3Options()
        basicOptions.from = from
        basicOptions.to = self.address
        
        // get the decimals manually
        let intermediate = contract.method("setAllowance", options: basicOptions)!
        let callResult = intermediate.call(options: basicOptions, onBlock: "latest")
        var decimals = BigUInt(0)
        switch callResult {
        case .success(let response):
            guard let dec = response["0"], let decTyped = dec as? BigUInt else {
                return Result.failure(Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals"))}
            decimals = decTyped
            break
        case .failure(let error):
            return Result.failure(error)
        }
        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(newAmount, decimals: intDecimals) else {
            return Result.failure(Web3Error.inputError(desc: "Can not parse inputted amount"))
        }
        let intermediateToSend = contract.method("setAllowance", parameters: [to, value] as [AnyObject], options: basicOptions)!
        return Result(intermediateToSend)
    }
    
    
}
