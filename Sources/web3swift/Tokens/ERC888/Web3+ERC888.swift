//
//  Web3+ERC888.swift
//  web3swift-iOS
//
//  Created by Anton Grigorev on 15/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

// MultiDimensional Token Standard
protocol IERC888 {
    func getBalance(account: EthereumAddress) throws -> BigUInt
    func transfer(from: EthereumAddress, to: EthereumAddress, amount: String) throws -> WriteTransaction
}

public class ERC888: IERC888 {

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

    public init(web3: web3, provider: Web3Provider, address: EthereumAddress, abi: String = Web3.Utils.erc888ABI) {
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

    public func getBalance(account: EthereumAddress) throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("balanceOf", parameters: [account] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
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

}
