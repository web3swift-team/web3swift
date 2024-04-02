//
//  RegistrarController.swift
//
//  Created by Anton on 15/04/2019.
//  Copyright © 2019 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

public extension ENS {
    class ETHRegistrarController {
        public let web3: Web3
        public let address: EthereumAddress

        lazy var contract: Web3.Contract = {
            // swiftlint:disable force_unwrapping
            let contract = self.web3.contract(Web3.Utils.ethRegistrarControllerABI, at: self.address, abiVersion: 2)
            precondition(contract != nil)
            return contract!
            // swiftlint:enable force_unwrapping
        }()

        lazy var defaultTransaction: CodableTransaction = {
            return CodableTransaction.emptyTransaction
        }()

        public init(web3: Web3, address: EthereumAddress) {
            self.web3 = web3
            self.address = address
        }

        public func getRentPrice(name: String, duration: UInt) async throws -> BigUInt {
            guard let transaction = self.contract.createReadOperation("rentPrice", parameters: [name, duration]) else { throw Web3Error.transactionSerializationError }
            guard let result = try? await transaction.callContractMethod() else { throw Web3Error.processingError(desc: "Can't call transaction") }
            guard let price = result["0"] as? BigUInt else { throw Web3Error.processingError(desc: "Can't get answer") }
            return price
        }

        public func checkNameValidity(name: String) async throws -> Bool {
            guard let transaction = self.contract.createReadOperation("valid", parameters: [name]) else { throw Web3Error.transactionSerializationError }
            guard let result = try? await transaction.callContractMethod() else { throw Web3Error.processingError(desc: "Can't call transaction") }
            guard let valid = result["0"] as? Bool else { throw Web3Error.processingError(desc: "Can't get answer") }
            return valid
        }

        public func isNameAvailable(name: String) async throws -> Bool {
            guard let transaction = self.contract.createReadOperation("available", parameters: [name]) else { throw Web3Error.transactionSerializationError }
            guard let result = try? await transaction.callContractMethod() else { throw Web3Error.processingError(desc: "Can't call transaction") }
            guard let available = result["0"] as? Bool else { throw Web3Error.processingError(desc: "Can't get answer") }
            return available
        }

        public func calculateCommitmentHash(name: String, owner: EthereumAddress, secret: String) async throws -> Data {
            guard let transaction = self.contract.createReadOperation("makeCommitment", parameters: [name, owner.address, secret]) else { throw Web3Error.transactionSerializationError }
            guard let result = try? await transaction.callContractMethod() else { throw Web3Error.processingError(desc: "Can't call transaction") }
            guard let hash = result["0"] as? Data else { throw Web3Error.processingError(desc: "Can't get answer") }
            return hash
        }

        public func sumbitCommitment(from: EthereumAddress, commitment: Data) throws -> WriteOperation {
            defaultTransaction.from = from
            defaultTransaction.to = self.address
            guard let transaction = self.contract.createWriteOperation("commit", parameters: [commitment]) else { throw Web3Error.transactionSerializationError }
            return transaction
        }

        public func registerName(from: EthereumAddress, name: String, owner: EthereumAddress, duration: UInt, secret: String, price: String) throws -> WriteOperation {
            guard let amount = Utilities.parseToBigUInt(price, units: .ether) else { throw Web3Error.inputError(desc: "Wrong price: no way for parsing to ether units") }
            defaultTransaction.value = amount
            defaultTransaction.from = from
            defaultTransaction.to = self.address
            guard let transaction = self.contract.createWriteOperation("register", parameters: [name, owner.address, duration, secret]) else { throw Web3Error.transactionSerializationError }
            return transaction
        }

        public func extendNameRegistration(from: EthereumAddress, name: String, duration: UInt32, price: String) throws -> WriteOperation {
            guard let amount = Utilities.parseToBigUInt(price, units: .ether) else { throw Web3Error.inputError(desc: "Wrong price: no way for parsing to ether units") }
            defaultTransaction.value = amount
            defaultTransaction.from = from
            defaultTransaction.to = self.address
            guard let transaction = self.contract.createWriteOperation("renew", parameters: [name, duration]) else { throw Web3Error.transactionSerializationError }
            return transaction
        }

        @available(*, message: "Available for only owner")
        public func withdraw(from: EthereumAddress) throws -> WriteOperation {
            defaultTransaction.from = from
            defaultTransaction.to = self.address
            guard let transaction = self.contract.createWriteOperation("withdraw") else { throw Web3Error.transactionSerializationError }
            return transaction
        }
    }
}
