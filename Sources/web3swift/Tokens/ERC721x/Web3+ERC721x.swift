//
//  Web3+ERC721x.swift
//  web3swift-iOS
//
//  Created by Anton Grigorev on 20/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

// A Smarter Token for the Future of Crypto Collectibles
// ERC721x is an extension of ERC721 that adds support for multi-fungible tokens and batch transfers, while being fully backward-compatible.

protocol IERC721x: IERC721, IERC721Metadata, IERC721Enumerable {
    func implementsERC721X() throws -> Bool
    func getOwner(tokenId: BigUInt) throws -> EthereumAddress
    func getBalance(account: EthereumAddress) throws -> BigUInt
    func getBalance(account: EthereumAddress, tokenId: BigUInt) throws -> BigUInt

    func tokensOwned(account: EthereumAddress) throws -> ([BigUInt], [BigUInt])

    func transfer(from: EthereumAddress, to: EthereumAddress, tokenId: BigUInt, quantity: BigUInt) throws -> WriteTransaction
    func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, quantity: BigUInt) throws -> WriteTransaction

    // Fungible Safe Transfer From
    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, amount: BigUInt) throws -> WriteTransaction
    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, amount: BigUInt, data: [UInt8]) throws -> WriteTransaction

    // Batch Safe Transfer From
    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenIds: [BigUInt], amounts: [BigUInt], data: [UInt8]) throws -> WriteTransaction

    func name() throws -> String
    func symbol() throws -> String
}

public class ERC721x: IERC721x {

    private var _tokenId: BigUInt? = nil
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

    public init(web3: web3, provider: Web3Provider, address: EthereumAddress, abi: String = Web3.Utils.erc721xABI) {
        self.web3 = web3
        self.provider = provider
        self.address = address
        var mergedOptions = web3.transactionOptions
        mergedOptions.to = address
        self.abi = abi
        self.transactionOptions = mergedOptions
    }

    public var tokenId: BigUInt {
        self.readProperties()
        if self._tokenId != nil {
            return self._tokenId!
        }
        return 0
    }

    public func readProperties() {
        if self._hasReadProperties {
            return
        }
        let contract = self.contract
        guard contract.contract.address != nil else {return}
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.callOnBlock = .latest

        guard let tokenIdPromise = contract.read("tokenId", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)?.callPromise() else {return}

        let allPromises = [tokenIdPromise]
        let queue = self.web3.requestDispatcher.queue
        when(resolved: allPromises).map(on: queue) { (resolvedPromises) -> Void in
            guard case .fulfilled(let tokenIdResult) = resolvedPromises[0] else {return}
            guard let tokenId = tokenIdResult["0"] as? BigUInt else {return}
            self._tokenId = tokenId

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

    public func getOwner(tokenId: BigUInt) throws -> EthereumAddress {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("ownerOf", parameters: [tokenId] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getApproved(tokenId: BigUInt) throws -> EthereumAddress {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("getApproved", parameters: [tokenId] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func transfer(from: EthereumAddress, to: EthereumAddress, tokenId: BigUInt) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        let tx = contract.write("transfer", parameters: [to, tokenId] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        let tx = contract.write("transferFrom", parameters: [originalOwner, to, tokenId] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        let tx = contract.write("safeTransferFrom", parameters: [originalOwner, to, tokenId] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, data: [UInt8]) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        let tx = contract.write("safeTransferFrom", parameters: [originalOwner, to, tokenId, data] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func approve(from: EthereumAddress, approved: EthereumAddress, tokenId: BigUInt) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        let tx = contract.write("approve", parameters: [approved, tokenId] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func setApprovalForAll(from: EthereumAddress, operator user: EthereumAddress, approved: Bool) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        let tx = contract.write("setApprovalForAll", parameters: [user, approved] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    public func isApprovedForAll(owner: EthereumAddress, operator user: EthereumAddress) throws -> Bool {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.callOnBlock = .latest
        let result = try contract.read("isApprovedForAll", parameters: [owner, user] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
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

    public func totalSupply() throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("totalSupply", parameters: [AnyObject](), extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func tokenByIndex(index: BigUInt) throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("tokenByIndex", parameters: [index] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func tokenOfOwnerByIndex(owner: EthereumAddress, index: BigUInt) throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("tokenOfOwnerByIndex", parameters: [owner, index] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func name() throws -> String {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("name", parameters: [AnyObject](), extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? String else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func symbol() throws -> String {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("symbol", parameters: [AnyObject](), extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? String else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func tokenURI(tokenId: BigUInt) throws -> String {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("tokenURI", parameters: [tokenId] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? String else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func implementsERC721X() throws -> Bool {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("implementsERC721X", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func getBalance(account: EthereumAddress, tokenId: BigUInt) throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("balanceOf", parameters: [account, tokenId] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func tokensOwned(account: EthereumAddress) throws -> ([BigUInt], [BigUInt]) {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("tokensOwned", parameters: [account] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? ([BigUInt], [BigUInt]) else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func transfer(from: EthereumAddress, to: EthereumAddress, tokenId: BigUInt, quantity: BigUInt) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        let tx = contract.write("transfer", parameters: [to, tokenId, quantity] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, quantity: BigUInt) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        let tx = contract.write("transferFrom", parameters: [originalOwner, to, tokenId, quantity] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, amount: BigUInt) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        let tx = contract.write("safeTransferFrom", parameters: [originalOwner, to, tokenId, amount] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, amount: BigUInt, data: [UInt8]) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        let tx = contract.write("safeTransferFrom", parameters: [originalOwner, to, tokenId, amount, data] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }

    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenIds: [BigUInt], amounts: [BigUInt], data: [UInt8]) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        let tx = contract.write("safeTransferFrom", parameters: [originalOwner, to, tokenIds, amounts, data] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
}
