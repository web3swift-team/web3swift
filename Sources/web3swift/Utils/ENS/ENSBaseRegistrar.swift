//
//  BaseRegistrar.swift
//  web3swift
//
//  Created by Anton on 15/04/2019.
//  Copyright © 2019 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt

public extension ENS {
    class BaseRegistrar: ERC721 {
        lazy var defaultOptions: TransactionOptions = {
            return TransactionOptions.defaultOptions
        }()

        public init(web3: web3, address: EthereumAddress) {
            super.init(web3: web3, provider: web3.provider, address: address)
            guard let contract = self.web3.contract(Web3.Utils.baseRegistrarABI, at: self.address, abiVersion: 2) else {
                return
            }
            self.contract = contract
        }

        override public init(web3: web3, provider: Web3Provider, address: EthereumAddress) {
            super.init(web3: web3, provider: provider, address: address)
            guard let contract = self.web3.contract(Web3.Utils.baseRegistrarABI, at: self.address, abiVersion: 2) else {
                return
            }
            self.contract = contract
        }

        @available(*, message: "Available for only owner")
        public func addController(from: EthereumAddress, controllerAddress: EthereumAddress) throws -> WriteTransaction {
            defaultOptions.from = from
            defaultOptions.to = self.address
            guard let transaction = self.contract.write("addController", parameters: [controllerAddress as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            return transaction
        }

        @available(*, message: "Available for only owner")
        public func removeController(from: EthereumAddress, controllerAddress: EthereumAddress) throws -> WriteTransaction {
            defaultOptions.from = from
            defaultOptions.to = self.address
            guard let transaction = self.contract.write("removeController", parameters: [controllerAddress as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            return transaction
        }

        @available(*, message: "Available for only owner")
        public func setResolver(from: EthereumAddress, resolverAddress: EthereumAddress) throws -> WriteTransaction {
            defaultOptions.from = from
            defaultOptions.to = self.address
            guard let transaction = self.contract.write("setResolver", parameters: [resolverAddress as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            return transaction
        }

        public func getNameExpirity(name: BigUInt) throws -> BigUInt {
            guard let transaction = self.contract.read("nameExpires", parameters: [name as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let expirity = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Can't get answer")}
            return expirity
        }

        @available(*, message: "This function should not be used to check if a name can be registered by a user. To check if a name can be registered by a user, check name availablility via the controller")
        public func isNameAvailable(name: BigUInt) throws -> Bool {
            guard let transaction = self.contract.read("available", parameters: [name as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let available = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Can't get answer")}
            return available
        }

        public func reclaim(from: EthereumAddress, record: BigUInt) throws -> WriteTransaction {
            defaultOptions.from = from
            defaultOptions.to = self.address
            guard let transaction = self.contract.write("reclaim", parameters: [record as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            return transaction
        }

    }
}
