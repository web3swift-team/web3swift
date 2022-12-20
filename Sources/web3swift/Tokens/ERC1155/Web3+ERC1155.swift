//
//  Web3+ERC1155.swift
//
//  Created by Anton Grigorev on 20/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

// Multi Token Standard
// FIXME: Rewrite this to CodableTransaction
protocol IERC1155: IERC165 {

    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, id: BigUInt, value: BigUInt, data: [UInt8]) async throws -> WriteOperation

    func safeBatchTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, ids: [BigUInt], values: [BigUInt], data: [UInt8]) async throws -> WriteOperation

    func balanceOf(account: EthereumAddress, id: BigUInt) async throws -> BigUInt

    func setApprovalForAll(from: EthereumAddress, operator user: EthereumAddress, approved: Bool, scope: Data) async throws -> WriteOperation

    func isApprovedForAll(owner: EthereumAddress, operator user: EthereumAddress, scope: Data) async throws -> Bool
}

protocol IERC1155Metadata {
    func uri(id: BigUInt) throws -> String
    func name(id: BigUInt) throws -> String
}

public class ERC1155: IERC1155 {

    private var _tokenId: BigUInt?
    private var _hasReadProperties: Bool = false

    public var transaction: CodableTransaction
    public var web3: Web3
    public var provider: Web3Provider
    public var address: EthereumAddress
    public var abi: String

    lazy var contract: Web3.Contract = {
        let contract = self.web3.contract(self.abi, at: self.address, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()

    public init(web3: Web3, provider: Web3Provider, address: EthereumAddress, abi: String = Web3.Utils.erc1155ABI, transaction: CodableTransaction = .emptyTransaction) {
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
        let contract = self.contract
        guard contract.contract.address != nil else {return}
        self.transaction.callOnBlock = .latest

        guard let tokenIdPromise = try await contract.createReadOperation("id", parameters: [] as [AnyObject], extraData: Data())?.callContractMethod() else {return}

        guard let tokenId = tokenIdPromise["0"] as? BigUInt else {return}
        self._tokenId = tokenId

        self._hasReadProperties = true
    }

    public func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, id: BigUInt, value: BigUInt, data: [UInt8]) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address

        let tx = contract.createWriteOperation("safeTransferFrom", parameters: [originalOwner, to, id, value, data] as [AnyObject] )!
        return tx
    }

    public func safeBatchTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, ids: [BigUInt], values: [BigUInt], data: [UInt8]) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address

        let tx = contract
            .createWriteOperation("safeBatchTransferFrom", parameters: [originalOwner, to, ids, values, data] as [AnyObject] )!
        return tx
    }

    public func balanceOf(account: EthereumAddress, id: BigUInt) async throws -> BigUInt {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract
            .createReadOperation("balanceOf", parameters: [account, id] as [AnyObject], extraData: Data() )!
            .callContractMethod()

        /*
         let result = try await contract
             .prepareToRead("balanceOf", parameters: [account, id] as [AnyObject], extraData: Data() )!
             .execute()
             .decodeData()

         */
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func setApprovalForAll(from: EthereumAddress, operator user: EthereumAddress, approved: Bool, scope: Data) throws -> WriteOperation {
        let contract = self.contract
        self.transaction.from = from
        self.transaction.to = self.address

        let tx = contract.createWriteOperation("setApprovalForAll", parameters: [user, approved, scope] as [AnyObject] )!
        return tx
    }

    public func isApprovedForAll(owner: EthereumAddress, operator user: EthereumAddress, scope: Data) async throws -> Bool {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("isApprovedForAll", parameters: [owner, user, scope] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }

    public func supportsInterface(interfaceID: String) async throws -> Bool {
        let contract = self.contract
        self.transaction.callOnBlock = .latest
        let result = try await contract.createReadOperation("supportsInterface", parameters: [interfaceID] as [AnyObject], extraData: Data() )!.callContractMethod()
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
}
