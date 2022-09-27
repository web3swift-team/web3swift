//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core


// Token Standard
protocol IERC20 {
    func getBalance(account: EthereumAddress) async throws -> BigUInt
    func getAllowance(originalOwner: EthereumAddress, delegate: EthereumAddress) async throws -> BigUInt
    func transfer(from: EthereumAddress, to: EthereumAddress, amount: String) async throws -> WriteOperation
    func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String) async throws -> WriteOperation
    func setAllowance(from: EthereumAddress, to: EthereumAddress, newAmount: String) async throws -> WriteOperation
    func approve(from: EthereumAddress, spender: EthereumAddress, amount: String) async throws -> WriteOperation
    func totalSupply() async throws -> BigUInt
}

// This namespace contains functions to work with ERC20 tokens.
// variables are lazyly evaluated or global token information (name, ticker, total supply)
// can be imperatively read and saved
// FIXME: Rewrite this to CodableTransaction
public class ERC20: IERC20, ERC20BaseProperties {
    var _name: String?
    var _symbol: String?
    var _decimals: UInt8?
    var _hasReadProperties: Bool = false

    public var transaction: CodableTransaction
    public var web3: Web3
    public var provider: Web3Provider
    public var address: EthereumAddress

    lazy var contract: Web3.Contract = {
        let contract = self.web3.contract(Web3.Utils.erc20ABI, at: self.address, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()

    public init(web3: Web3, provider: Web3Provider, address: EthereumAddress, transaction: CodableTransaction = .emptyTransaction) {
        self.web3 = web3
        self.provider = provider
        self.address = address
        self.transaction = transaction
    }

    public func getBalance(account: EthereumAddress) async throws -> BigUInt {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract
            .createReadOperation("balanceOf", parameters: [account] as [AnyObject], extraData: Data() )!
            .callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getAllowance(originalOwner: EthereumAddress, delegate: EthereumAddress) async throws -> BigUInt {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract
            .createReadOperation("allowance", parameters: [originalOwner, delegate] as [AnyObject], extraData: Data() )!
            .callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func transfer(from: EthereumAddress, to: EthereumAddress, amount: String) async throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address
        self.transaction.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract
            .createReadOperation("decimals" )!
            .callContractMethod()
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
        let callResult = try await contract
            .createReadOperation("decimals" )!
            .callContractMethod()
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
        let callResult = try await contract
            .createReadOperation("decimals" )!
            .callContractMethod()
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

    public func approve(from: EthereumAddress, spender: EthereumAddress, amount: String) async throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address
        self.transaction.callOnBlock = .latest

        // get the decimals manually
        let callResult = try await contract
            .createReadOperation("decimals" )!
            .callContractMethod()
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

    public func totalSupply() async throws -> BigUInt {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract
            .createReadOperation("totalSupply", parameters: [AnyObject](), extraData: Data() )!
            .callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

}

protocol ERC20BaseProperties: AnyObject {
    var contract: Web3.Contract { get }
    var _name: String? { get set }
    var _symbol: String? { get set }
    var _decimals: UInt8? { get set }
    var _hasReadProperties: Bool { get set }
    func readProperties() async throws
    func name() -> String?
    func symbol() -> String?
    func decimals() -> UInt8?
}

extension ERC20BaseProperties {
    public func name() -> String? {
        _name
    }

    public func symbol() -> String? {
        _symbol
    }

    public func decimals() -> UInt8? {
        _decimals
    }

    public func readProperties() async throws {
        guard !_hasReadProperties else { return }
        guard contract.contract.address != nil else {return}
        _name = try await contract
            .createReadOperation("name")?
            .callContractMethod()["0"] as? String

        _symbol = try await contract
            .createReadOperation("symbol")?
            .callContractMethod()["0"] as? String

        let decimals = try await contract
            .createReadOperation("decimals")?
            .callContractMethod()["0"] as? BigUInt
        _decimals = decimals != nil ? UInt8(decimals!) : nil
        _hasReadProperties = true
    }
}
