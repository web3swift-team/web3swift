//
//  BaseRegistrar.swift
//
//  Created by Anton on 15/04/2019.
//  Copyright © 2019 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

// FIXME: Rewrite this to CodableTransaction
public extension ENS {
    class BaseRegistrar: ERC721 {
        lazy var defaultTransaction: CodableTransaction = {
            return CodableTransaction.emptyTransaction
        }()

        public init(web3: Web3, address: EthereumAddress) {
            super.init(web3: web3, provider: web3.provider, address: address)
            guard let contract = self.web3.contract(Web3.Utils.baseRegistrarABI, at: self.address, abiVersion: 2) else {
                return
            }
            self.contract = contract
        }

        override public init(web3: Web3, provider: Web3Provider, address: EthereumAddress, transaction: CodableTransaction = .emptyTransaction) {
            super.init(web3: web3, provider: provider, address: address, transaction: transaction)
            guard let contract = self.web3.contract(Web3.Utils.baseRegistrarABI, at: self.address, abiVersion: 2) else {
                return
            }
            self.contract = contract
        }

        @available(*, message: "Available for only owner")
        public func addController(from: EthereumAddress, controllerAddress: EthereumAddress) throws -> WriteOperation {
            defaultTransaction.from = from
            defaultTransaction.to = self.address
            guard let transaction = self.contract.createWriteOperation("addController", parameters: [controllerAddress]) else { throw Web3Error.transactionSerializationError }
            return transaction
        }

        @available(*, message: "Available for only owner")
        public func removeController(from: EthereumAddress, controllerAddress: EthereumAddress) throws -> WriteOperation {
            defaultTransaction.from = from
            defaultTransaction.to = self.address
            guard let transaction = self.contract.createWriteOperation("removeController", parameters: [controllerAddress]) else { throw Web3Error.transactionSerializationError }
            return transaction
        }

        @available(*, message: "Available for only owner")
        public func setResolver(from: EthereumAddress, resolverAddress: EthereumAddress) throws -> WriteOperation {
            defaultTransaction.from = from
            defaultTransaction.to = self.address
            guard let transaction = self.contract.createWriteOperation("setResolver", parameters: [resolverAddress]) else { throw Web3Error.transactionSerializationError }
            return transaction
        }

        public func getNameExpirity(name: BigUInt) async throws -> BigUInt {
            guard let transaction = self.contract.createReadOperation("nameExpires", parameters: [name]) else { throw Web3Error.transactionSerializationError }

            guard let result = try? await transaction.callContractMethod() else { throw Web3Error.processingError(desc: "Can't call transaction") }
            guard let expirity = result["0"] as? BigUInt else { throw Web3Error.processingError(desc: "Can't get answer") }
            return expirity
        }

        @available(*, message: "This function should not be used to check if a name can be registered by a user. To check if a name can be registered by a user, check name availablility via the controller")
        public func isNameAvailable(name: BigUInt) async throws -> Bool {
            guard let transaction = self.contract.createReadOperation("available", parameters: [name]) else { throw Web3Error.transactionSerializationError }

            guard let result = try? await transaction.callContractMethod() else { throw Web3Error.processingError(desc: "Can't call transaction") }
            guard let available = result["0"] as? Bool else { throw Web3Error.processingError(desc: "Can't get answer") }
            return available
        }

        public func reclaim(from: EthereumAddress, record: BigUInt) throws -> WriteOperation {
            defaultTransaction.from = from
            defaultTransaction.to = self.address
            guard let transaction = self.contract.createWriteOperation("reclaim", parameters: [record]) else { throw Web3Error.transactionSerializationError }
            return transaction
        }

    }
}
