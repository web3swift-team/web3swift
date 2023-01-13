//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

// Non-Fungible Token Standard
protocol IERC721: IERC165 {

    func getBalance(account: EthereumAddress) async throws -> BigUInt

    func getOwner(tokenId: BigUInt) async throws -> EthereumAddress

    func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt) async throws -> WriteOperation

    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt) async throws -> WriteOperation

    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, data: [UInt8]) async throws -> WriteOperation

    func transfer(from: EthereumAddress, to: EthereumAddress, tokenId: BigUInt) async throws -> WriteOperation

    func approve(from: EthereumAddress, approved: EthereumAddress, tokenId: BigUInt) async throws -> WriteOperation

    func setApprovalForAll(from: EthereumAddress, operator user: EthereumAddress, approved: Bool) async throws -> WriteOperation

    func getApproved(tokenId: BigUInt) async throws -> EthereumAddress

    func isApprovedForAll(owner: EthereumAddress, operator user: EthereumAddress) async throws -> Bool
}

protocol IERC721Metadata {

    func name() async throws -> String

    func symbol() async throws -> String

    func tokenURI(tokenId: BigUInt) async throws -> String

}

protocol IERC721Enumerable {

    func totalSupply() async throws -> BigUInt

    func tokenByIndex(index: BigUInt) async throws -> BigUInt

    func tokenOfOwnerByIndex(owner: EthereumAddress, index: BigUInt) async throws -> BigUInt
}

// This namespace contains functions to work with ERC721 tokens.
// can be imperatively read and saved
public class ERC721: IERC721 {

    private var _tokenId: BigUInt?
    private var _hasReadProperties: Bool = false

    public var transaction: CodableTransaction
    public var web3: Web3
    public var provider: Web3Provider
    public var address: EthereumAddress

    lazy var contract: Web3.Contract = {
        let contract = self.web3.contract(Web3.Utils.erc721ABI, at: self.address, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()

    public init(web3: Web3, provider: Web3Provider, address: EthereumAddress, transaction: CodableTransaction = .emptyTransaction) {
        self.web3 = web3
        self.provider = provider
        self.address = address
        self.transaction = transaction

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
        let contract = self.contract
        guard contract.contract.address != nil else {return}
        self.transaction.callOnBlock = .latest

        async let tokenIdPromise = contract.createReadOperation("tokenId", parameters: [Any](), extraData: Data())?.callContractMethod()

        guard let tokenIdResult = try await tokenIdPromise else {return}
        guard let tokenId = tokenIdResult["0"] as? BigUInt else {return}
        self._tokenId = tokenId

        self._hasReadProperties = true

    }

    public func getBalance(account: EthereumAddress) async throws -> BigUInt {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("balanceOf", parameters: [account], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getOwner(tokenId: BigUInt) async throws -> EthereumAddress {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("ownerOf", parameters: [tokenId], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func getApproved(tokenId: BigUInt) async throws -> EthereumAddress {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("getApproved", parameters: [tokenId], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func transfer(from: EthereumAddress, to: EthereumAddress, tokenId: BigUInt) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address

        let tx = contract.createWriteOperation("transfer", parameters: [to, tokenId])!
        return tx
    }

    public func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address

        let tx = contract.createWriteOperation("transferFrom", parameters: [originalOwner, to, tokenId])!
        return tx
    }

    public func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address

        let tx = contract.createWriteOperation("safeTransferFrom", parameters: [originalOwner, to, tokenId])!
        return tx
    }

    public func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt, data: [UInt8]) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address

        let tx = contract.createWriteOperation("safeTransferFrom", parameters: [originalOwner, to, tokenId, data])!
        return tx
    }

    public func approve(from: EthereumAddress, approved: EthereumAddress, tokenId: BigUInt) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address

        let tx = contract.createWriteOperation("approve", parameters: [approved, tokenId])!
        return tx
    }

    public func setApprovalForAll(from: EthereumAddress, operator user: EthereumAddress, approved: Bool) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address

        let tx = contract.createWriteOperation("setApprovalForAll", parameters: [user, approved])!
        return tx
    }

    public func isApprovedForAll(owner: EthereumAddress, operator user: EthereumAddress) async throws -> Bool {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("isApprovedForAll", parameters: [owner, user], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func supportsInterface(interfaceID: String) async throws -> Bool {
        let contract = self.contract
        transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("supportsInterface", parameters: [interfaceID], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

}

extension ERC721: IERC721Enumerable {

    public func totalSupply() async throws -> BigUInt {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("totalSupply", parameters: [Any](), extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func tokenByIndex(index: BigUInt) async throws -> BigUInt {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("tokenByIndex", parameters: [index], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func tokenOfOwnerByIndex(owner: EthereumAddress, index: BigUInt) async throws -> BigUInt {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("tokenOfOwnerByIndex", parameters: [owner, index], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

}

// FIXME: Rewrite this to CodableTransaction
extension ERC721: IERC721Metadata {

    public func name() async throws -> String {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("name", parameters: [Any](), extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? String else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func symbol() async throws -> String {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("symbol", parameters: [Any](), extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? String else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func tokenURI(tokenId: BigUInt) async throws -> String {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("tokenURI", parameters: [tokenId], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? String else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

}
