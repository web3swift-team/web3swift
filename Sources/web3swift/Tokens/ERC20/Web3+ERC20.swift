//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

// Token Standard
protocol IERC20 {
    func getBalance(account: EthereumAddress) async throws -> BigUInt
    func getAllowance(originalOwner: EthereumAddress, delegate: EthereumAddress) async throws -> BigUInt
    func transfer(from: EthereumAddress, to: EthereumAddress, amount: String) async throws -> WriteTransaction
    func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String) async throws -> WriteTransaction
    func setAllowance(from: EthereumAddress, to: EthereumAddress, newAmount: String) async throws -> WriteTransaction
    func approve(from: EthereumAddress, spender: EthereumAddress, amount: String) async throws -> WriteTransaction
    func totalSupply() async throws -> BigUInt
}

// This namespace contains functions to work with ERC20 tokens.
// variables are lazyly evaluated or global token information (name, ticker, total supply)
// can be imperatively read and saved
public class ERC20: IERC20, ERC20BaseProperties {
    var _name: String?
    var _symbol: String?
    var _decimals: UInt8?
    var _hasReadProperties: Bool = false

    public var transactionOptions: TransactionOptions
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
        var mergedOptions = web3.transactionOptions
        mergedOptions.to = address
        self.transactionOptions = mergedOptions
    }

    public func getBalance(account: EthereumAddress) async throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("balanceOf", parameters: [account] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getAllowance(originalOwner: EthereumAddress, delegate: EthereumAddress) async throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("allowance", parameters: [originalOwner, delegate] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func transfer(from: EthereumAddress, to: EthereumAddress, amount: String) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: basicOptions)!.call()
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

    public func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: basicOptions)!.call()
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

    public func setAllowance(from: EthereumAddress, to: EthereumAddress, newAmount: String) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: basicOptions)!.call()
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

    public func approve(from: EthereumAddress, spender: EthereumAddress, amount: String) async throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract.read("decimals", transactionOptions: basicOptions)!.call()
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

    public func totalSupply() async throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract.read("totalSupply", parameters: [AnyObject](), extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

}

protocol ERC20BaseProperties: AnyObject {
    var contract: web3.web3contract { get }
    var _name: String? { get set }
    var _symbol: String? { get set }
    var _decimals: UInt8? { get set }
    var _hasReadProperties: Bool { get set }
    func readProperties() async throws
    func name() async throws -> String
    func symbol() async throws -> String
    func decimals() async throws -> UInt8
}
extension ERC20BaseProperties {
    public func name() async throws -> String {
        try await self.readProperties()
        return self._name ?? ""
    }

    public func symbol() async throws -> String {
        try await self.readProperties()
        return self._symbol ?? ""
    }

    public func decimals() async throws -> UInt8 {
        try await self.readProperties()
        return self._decimals ?? 255
    }

    func readProperties() async throws {
        if self._hasReadProperties {
            return
        }
        let contract = self.contract
        guard contract.contract.address != nil else {return}
        var transactionOptionsVAR = TransactionOptions.defaultOptions
        transactionOptionsVAR.callOnBlock = .latest
        let transactionOptions = transactionOptionsVAR
        async let namePromise = contract.read("name", parameters: [AnyObject](), extraData: Data(), transactionOptions: transactionOptions)?.decodedData()

        async let symbolPromise = try await contract.read("symbol", parameters: [AnyObject](), extraData: Data(), transactionOptions: transactionOptions)?.decodedData()

        async let decimalPromise = try await contract.read("decimals", parameters: [AnyObject](), extraData: Data(), transactionOptions: transactionOptions)?.decodedData()

        let resolvedPromises = try await ["name":namePromise, "symbol":symbolPromise, "decimals":decimalPromise]

        if let nameResult = resolvedPromises["name"], let name = nameResult?["0"] as? String {
            _name = name
        }

        if let symbolResult = resolvedPromises["symbol"], let symbol = symbolResult?["0"] as? String {
            _symbol = symbol
        }

        if let decimalsResult = resolvedPromises["decimals"], let decimals = decimalsResult?["0"] as? BigUInt {
            _decimals = UInt8(decimals)
        }

        self._hasReadProperties = true
    }
}
