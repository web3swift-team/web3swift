//
//  Web3+ERC721x.swift
//  web3swift-iOS
//
//  Created by Anton Grigorev on 20/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import BigInt
import Foundation

// A Smarter Token for the Future of Crypto Collectibles
// ERC721x is an extension of ERC721 that adds support for multi-fungible tokens and batch transfers, while being fully backward-compatible.

protocol IERC721x: IERC721, IERC721Metadata, IERC721Enumerable {
    func implementsERC721X() async throws -> Bool
    func getOwner(tokenId: BigUInt) async throws -> EthereumAddress
    func getBalance(account: EthereumAddress) async throws -> BigUInt
    func getBalance(account: EthereumAddress, tokenId: BigUInt) async throws -> BigUInt

    func tokensOwned(account: EthereumAddress) async throws -> ([BigUInt], [BigUInt])

    func transfer(from: EthereumAddress, to: EthereumAddress, tokenId: BigUInt, quantity: BigUInt) async throws -> WriteTransaction
    func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, quantity: BigUInt) async throws -> WriteTransaction

    // Fungible Safe Transfer From
    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, amount: BigUInt) async throws -> WriteTransaction
    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, amount: BigUInt, data: [UInt8]) async throws -> WriteTransaction

    // Batch Safe Transfer From
    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenIds: [BigUInt], amounts: [BigUInt], data: [UInt8]) async throws -> WriteTransaction

    func name() async throws -> String
    func symbol() async throws -> String
}

public class ERC721x: IERC721x {

    private var _tokenId: BigUInt?
    private var _hasReadProperties = false

    public var transactionOptions: TransactionOptions
    public var web3: Web3
    public var provider: Web3Provider
    public var address: EthereumAddress
    public var abi: String

    lazy var contract: Web3.Web3contract? = {
        web3.contract(abi, at: address)
    }()

    public init(web3: Web3, provider: Web3Provider, address: EthereumAddress, abi: String = Web3.Utils.erc721xABI) {
        self.web3 = web3
        self.provider = provider
        self.address = address
        var mergedOptions = web3.transactionOptions
        mergedOptions.to = address
        self.abi = abi
        self.transactionOptions = mergedOptions
    }

    public func tokenId() async throws -> BigUInt {
        try await self.readProperties()
        return self._tokenId ?? 0
    }

    public func readProperties() async throws {
        if self._hasReadProperties {
            return
        }
        let contract = self.contract
        guard contract?.contract.address != nil else {return}
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.callOnBlock = .latest

        guard let tokenIdPromise = try await contract?.read("tokenId", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)?.decodedData() else {return}

        guard let tokenId = tokenIdPromise["0"] as? BigUInt else {return}
        self._tokenId = tokenId

        self._hasReadProperties = true
    }

    public func getBalance(account: EthereumAddress) async throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract?.read("balanceOf", parameters: [account] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getOwner(tokenId: BigUInt) async throws -> EthereumAddress {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract?.read("ownerOf", parameters: [tokenId] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getApproved(tokenId: BigUInt) async throws -> EthereumAddress {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract?.read("getApproved", parameters: [tokenId] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func transfer(from: EthereumAddress, to: EthereumAddress, tokenId: BigUInt) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        guard let tx = contract?.write("transfer", parameters: [to, tokenId] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write contract")
        }
        return tx
    }

    public func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        guard let tx = contract?.write("transferFrom", parameters: [originalOwner, to, tokenId] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write contract")
        }
        return tx
    }

    public func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        guard let tx = contract?.write("safeTransferFrom", parameters: [originalOwner, to, tokenId] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write contract")
        }
        return tx
    }

    public func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, data: [UInt8]) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        guard let tx = contract?.write("safeTransferFrom", parameters: [originalOwner, to, tokenId, data] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write contract")
        }
        return tx
    }

    public func approve(from: EthereumAddress, approved: EthereumAddress, tokenId: BigUInt) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        guard let tx = contract?.write("approve", parameters: [approved, tokenId] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write contract")
        }
        return tx
    }

    public func setApprovalForAll(from: EthereumAddress, operator user: EthereumAddress, approved: Bool) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        guard let tx = contract?.write("setApprovalForAll", parameters: [user, approved] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write contract")
        }
        return tx
    }

    public func isApprovedForAll(owner: EthereumAddress, operator user: EthereumAddress) async throws -> Bool {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.callOnBlock = .latest
        let result = try await contract?.read("isApprovedForAll", parameters: [owner, user] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func supportsInterface(interfaceID: String) async throws -> Bool {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        transactionOptions.gasLimit = .manual(30000)
        let result = try await contract?.read("supportsInterface", parameters: [interfaceID] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func totalSupply() async throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract?.read("totalSupply", parameters: [AnyObject](), extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func tokenByIndex(index: BigUInt) async throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract?.read("tokenByIndex", parameters: [index] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func tokenOfOwnerByIndex(owner: EthereumAddress, index: BigUInt) async throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract?.read("tokenOfOwnerByIndex", parameters: [owner, index] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func name() async throws -> String {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract?.read("name", parameters: [AnyObject](), extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? String else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func symbol() async throws -> String {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract?.read("symbol", parameters: [AnyObject](), extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? String else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func tokenURI(tokenId: BigUInt) async throws -> String {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract?.read("tokenURI", parameters: [tokenId] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? String else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func implementsERC721X() async throws -> Bool {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract?.read("implementsERC721X", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func getBalance(account: EthereumAddress, tokenId: BigUInt) async throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract?.read("balanceOf", parameters: [account, tokenId] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func tokensOwned(account: EthereumAddress) async throws -> ([BigUInt], [BigUInt]) {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try await contract?.read("tokensOwned", parameters: [account] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)?.call(transactionOptions: transactionOptions)
        guard let res = result?["0"] as? ([BigUInt], [BigUInt]) else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func transfer(from: EthereumAddress, to: EthereumAddress, tokenId: BigUInt, quantity: BigUInt) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        guard let tx = contract?.write("transfer", parameters: [to, tokenId, quantity] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write contract")
        }
        return tx
    }

    func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, quantity: BigUInt) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        guard let tx = contract?.write("transferFrom", parameters: [originalOwner, to, tokenId, quantity] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write contract")
        }
        return tx
    }

    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, amount: BigUInt) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        guard let tx = contract?.write("safeTransferFrom", parameters: [originalOwner, to, tokenId, amount] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write contract")
        }
        return tx
    }

    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, amount: BigUInt, data: [UInt8]) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        guard let tx = contract?.write("safeTransferFrom", parameters: [originalOwner, to, tokenId, amount, data] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write contract")
        }
        return tx
    }

    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenIds: [BigUInt], amounts: [BigUInt], data: [UInt8]) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address

        guard let tx = contract?.write("safeTransferFrom", parameters: [originalOwner, to, tokenIds, amounts, data] as [AnyObject], transactionOptions: basicOptions) else {
            throw Web3Error.processingError(desc: "Failed to write contract")
        }
        return tx
    }
}
