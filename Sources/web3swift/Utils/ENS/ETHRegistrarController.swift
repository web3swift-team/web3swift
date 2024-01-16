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

        public init(web3: Web3, address: EthereumAddress) {
            self.web3 = web3
            self.address = address
        }

        public func getRentPrice(name: String, duration: UInt) async throws -> BigUInt {
            try await contract.callReadOnlyFunction("rentPrice", parameters: [name, duration])
        }

        public func checkNameValidity(name: String) async throws -> Bool {
            try await contract.callReadOnlyFunction("valid", parameters: [name])
        }

        public func isNameAvailable(name: String) async throws -> Bool {
            try await contract.callReadOnlyFunction("available", parameters: [name])
        }

        public func calculateCommitmentHash(name: String, owner: EthereumAddress, secret: String) async throws -> Data {
            try await contract.callReadOnlyFunction("makeCommitment", parameters: [name, owner, secret])
        }

        public func sumbitCommitment(from: EthereumAddress, commitment: Data) throws -> WriteOperation {
            try contract.createWriteFunctionCall("commit", parameters: [commitment])
        }

        public func registerName(from: EthereumAddress, name: String, owner: EthereumAddress, duration: UInt, secret: String, price: String) throws -> WriteOperation {
            guard let amount = Utilities.parseToBigUInt(price, units: .ether) else { throw Web3Error.inputError(desc: "Wrong price: no way for parsing to ether units") }
            return try contract.createWriteFunctionCall("register", parameters: [name, owner.address, duration, secret])
        }

        public func extendNameRegistration(from: EthereumAddress, name: String, duration: UInt32, price: String) throws -> WriteOperation {
            guard let amount = Utilities.parseToBigUInt(price, units: .ether) else { throw Web3Error.inputError(desc: "Wrong price: no way for parsing to ether units") }
            return try contract.createWriteFunctionCall("renew", parameters: [name, duration])
        }

        @available(*, message: "Available for only owner")
        public func withdraw(from: EthereumAddress) throws -> WriteOperation {
            try contract.createWriteFunctionCall("withdraw")
        }
    }
}
