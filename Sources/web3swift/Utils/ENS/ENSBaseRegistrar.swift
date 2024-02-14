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
            try contract.createWriteFunctionCall("addController", parameters: [controllerAddress])
        }

        @available(*, message: "Available for only owner")
        public func removeController(from: EthereumAddress, controllerAddress: EthereumAddress) throws -> WriteOperation {
            try contract.createWriteFunctionCall("removeController", parameters: [controllerAddress])
        }

        @available(*, message: "Available for only owner")
        public func setResolver(from: EthereumAddress, resolverAddress: EthereumAddress) throws -> WriteOperation {
            try contract.createWriteFunctionCall("setResolver", parameters: [resolverAddress])
        }

        public func getNameExpirity(name: BigUInt) async throws -> BigUInt {
            try await contract.callReadOnlyFunction("nameExpires", parameters: [name])
        }

        @available(*, message: "This function should not be used to check if a name can be registered by a user. To check if a name can be registered by a user, check name availability via the controller")
        public func isNameAvailable(name: BigUInt) async throws -> Bool {
            try await contract.callReadOnlyFunction("available", parameters: [name])
        }

        public func reclaim(from: EthereumAddress, record: BigUInt) throws -> WriteOperation {
            try contract.createWriteFunctionCall("reclaim", parameters: [record])
        }

    }
}
