//
//  Web3+ERC721x.swift
//
//  Created by Anton Grigorev on 20/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

// A Smarter Token for the Future of Crypto Collectibles
// ERC721x is an extension of ERC721 that adds support for multi-fungible tokens and batch transfers, while being fully backward-compatible.

protocol IERC721x: IERC721, IERC721Metadata, IERC721Enumerable {
    func implementsERC721X() async throws -> Bool
    func getOwner(tokenId: BigUInt) async throws -> EthereumAddress
    func getBalance(account: EthereumAddress) async throws -> BigUInt
    func getBalance(account: EthereumAddress, tokenId: BigUInt) async throws -> BigUInt

    func tokensOwned(account: EthereumAddress) async throws -> ([BigUInt], [BigUInt])

    func transfer(from: EthereumAddress, to: EthereumAddress, tokenId: BigUInt, quantity: BigUInt) async throws -> WriteOperation
    func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, quantity: BigUInt) async throws -> WriteOperation

    // Fungible Safe Transfer From
    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, amount: BigUInt) async throws -> WriteOperation
    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, amount: BigUInt, data: [UInt8]) async throws -> WriteOperation

    // Batch Safe Transfer From
    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenIds: [BigUInt], amounts: [BigUInt], data: [UInt8]) async throws -> WriteOperation

    func name() async throws -> String
    func symbol() async throws -> String
}

// FIXME: Rewrite this to CodableTransaction
public class ERC721x: IERC721x {

    private var _tokenId: BigUInt?
    private var _hasReadProperties: Bool = false

    public var transaction: CodableTransaction
    public var web3: Web3
    public var provider: Web3Provider
    public var address: EthereumAddress
    public var abi: String

    lazy var contract: Web3.Contract = {
        // swiftlint:disable force_unwrapping
        let contract = self.web3.contract(self.abi, at: self.address, abiVersion: 2)
        precondition(contract != nil)
        return contract!
        // swiftlint:enable force_unwrapping
    }()

    public init(web3: Web3, provider: Web3Provider, address: EthereumAddress, abi: String = Web3.Utils.erc721xABI, transaction: CodableTransaction = .emptyTransaction) {
        self.web3 = web3
        self.provider = provider
        self.address = address
        self.transaction = transaction
        self.transaction.to = address
        self.abi = abi
    }

    public func tokenId() async throws -> BigUInt {
        try await self.readProperties()
        if self._tokenId != nil {
            return self._tokenId!
        }
        return 0
    }

    public func readProperties() async throws {
        if self._hasReadProperties {
            return
        }
        guard contract.contract.address != nil else { return }
        transaction.callOnBlock = .latest

        guard let tokenIdPromise = try await contract.createReadOperation("tokenId")?.callContractMethod() else { return }

        guard let tokenId = tokenIdPromise["0"] as? BigUInt else { return }
        self._tokenId = tokenId

        self._hasReadProperties = true
    }

    public func getBalance(account: EthereumAddress) async throws -> BigUInt {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("balanceOf", parameters: [account])!.callContractMethod()

        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getOwner(tokenId: BigUInt) async throws -> EthereumAddress {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("ownerOf", parameters: [tokenId])!.callContractMethod()

        guard let res = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getApproved(tokenId: BigUInt) async throws -> EthereumAddress {
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("getApproved", parameters: [tokenId])!.callContractMethod()

        guard let res = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func transfer(from: EthereumAddress, to: EthereumAddress, tokenId: BigUInt) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("transfer", parameters: [to, tokenId])!
        return tx
    }

    public func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("transferFrom", parameters: [originalOwner, to, tokenId])!
        return tx
    }

    public func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("safeTransferFrom", parameters: [originalOwner, to, tokenId])!
        return tx
    }

    public func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, data: [UInt8]) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("safeTransferFrom", parameters: [originalOwner, to, tokenId, data])!
        return tx
    }

    public func approve(from: EthereumAddress, approved: EthereumAddress, tokenId: BigUInt) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("approve", parameters: [approved, tokenId])!
        return tx
    }

    public func setApprovalForAll(from: EthereumAddress, operator user: EthereumAddress, approved: Bool) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("setApprovalForAll", parameters: [user, approved])!
        return tx
    }

    public func isApprovedForAll(owner: EthereumAddress, operator user: EthereumAddress) async throws -> Bool {
        let result = try await contract.createReadOperation("isApprovedForAll", parameters: [owner, user])!.callContractMethod()

        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func supportsInterface(interfaceID: String) async throws -> Bool {
        let result = try await contract.createReadOperation("supportsInterface", parameters: [interfaceID])!.callContractMethod()

        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func totalSupply() async throws -> BigUInt {
        let result = try await contract.createReadOperation("totalSupply")!.callContractMethod()

        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func tokenByIndex(index: BigUInt) async throws -> BigUInt {
        let result = try await contract.createReadOperation("tokenByIndex", parameters: [index])!.callContractMethod()

        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func tokenOfOwnerByIndex(owner: EthereumAddress, index: BigUInt) async throws -> BigUInt {
        let result = try await contract.createReadOperation("tokenOfOwnerByIndex", parameters: [owner, index])!.callContractMethod()

        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func name() async throws -> String {
        let result = try await contract.createReadOperation("name")!.callContractMethod()

        guard let res = result["0"] as? String else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func symbol() async throws -> String {
        let result = try await contract.createReadOperation("symbol")!.callContractMethod()

        guard let res = result["0"] as? String else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func tokenURI(tokenId: BigUInt) async throws -> String {
        let result = try await contract.createReadOperation("tokenURI", parameters: [tokenId])!.callContractMethod()

        guard let res = result["0"] as? String else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func implementsERC721X() async throws -> Bool {
        let result = try await contract.createReadOperation("implementsERC721X")!.callContractMethod()

        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func getBalance(account: EthereumAddress, tokenId: BigUInt) async throws -> BigUInt {
        let result = try await contract.createReadOperation("balanceOf", parameters: [account, tokenId])!.callContractMethod()

        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func tokensOwned(account: EthereumAddress) async throws -> ([BigUInt], [BigUInt]) {
        let result = try await contract.createReadOperation("tokensOwned", parameters: [account])!.callContractMethod()

        guard let res = result["0"] as? ([BigUInt], [BigUInt]) else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    func transfer(from: EthereumAddress, to: EthereumAddress, tokenId: BigUInt, quantity: BigUInt) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("transfer", parameters: [to, tokenId, quantity])!
        return tx
    }

    func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, quantity: BigUInt) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("transferFrom", parameters: [originalOwner, to, tokenId, quantity])!
        return tx
    }

    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, amount: BigUInt) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("safeTransferFrom", parameters: [originalOwner, to, tokenId, amount])!
        return tx
    }

    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, amount: BigUInt, data: [UInt8]) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("safeTransferFrom", parameters: [originalOwner, to, tokenId, amount, data])!
        return tx
    }

    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenIds: [BigUInt], amounts: [BigUInt], data: [UInt8]) throws -> WriteOperation {
        updateTransactionAndContract(from: from)
        let tx = contract.createWriteOperation("safeTransferFrom", parameters: [originalOwner, to, tokenIds, amounts, data])!
        return tx
    }
}

// MARK: - Private

extension ERC721x {

    private func updateTransactionAndContract(from: EthereumAddress) {
        transaction.from = from
        transaction.to = address
        contract.transaction = transaction
    }

}
