//
//  ENSReverseRegistrar.swift
//
//  Created by Anton on 20/04/2019.
//  Copyright © 2019 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

public extension ENS {
    class ReverseRegistrar {
        public let web3: Web3
        public let address: EthereumAddress

        lazy var contract: Web3.Contract = {
            let contract = self.web3.contract(Web3.Utils.reverseRegistrarABI, at: self.address, abiVersion: 2)
            precondition(contract != nil)
            return contract!
        }()

        // FIXME: Rewrite this to CodableTransaction
        lazy var defaultOptions: CodableTransaction = {
            return CodableTransaction.emptyTransaction
        }()

        public init(web3: Web3, address: EthereumAddress) {
            self.web3 = web3
            self.address = address
        }

        public func claimAddress(from: EthereumAddress, owner: EthereumAddress) throws -> WriteOperation {
            defaultOptions.from = from
            defaultOptions.to = self.address

            guard let transaction = self.contract.createWriteOperation("claim", parameters: [owner as AnyObject]) else {throw Web3Error.transactionSerializationError}

            return transaction
        }

        public func claimAddressWithResolver(from: EthereumAddress, owner: EthereumAddress, resolver: EthereumAddress) throws -> WriteOperation {
            defaultOptions.from = from
            defaultOptions.to = self.address

            guard let transaction = self.contract.createWriteOperation("claimWithResolver", parameters: [owner, resolver]) else {throw Web3Error.transactionSerializationError}

            return transaction
        }

        public func setName(from: EthereumAddress, name: String) throws -> WriteOperation {
            defaultOptions.from = from
            defaultOptions.to = self.address

            guard let transaction = self.contract.createWriteOperation("setName", parameters: [name]) else {throw Web3Error.transactionSerializationError}

            return transaction
        }

        public func getReverseRecordName(address: EthereumAddress) async throws -> Data {
            guard let transaction = self.contract.createReadOperation("node", parameters: [address]) else {throw Web3Error.transactionSerializationError}

            guard let result = try? await transaction.callContractMethod() else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let name = result["0"] as? Data else {throw Web3Error.processingError(desc: "Can't get answer")}
            return name
        }

        public func getDefaultResolver() async throws -> EthereumAddress {
            guard let transaction = self.contract.createReadOperation("defaultResolver", parameters: []) else {throw Web3Error.transactionSerializationError}

            guard let result = try? await transaction.callContractMethod() else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let address = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Can't get answer")}
            return address
        }
    }
}
