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
            // swiftlint:disable force_unwrapping
            let contract = self.web3.contract(Web3.Utils.reverseRegistrarABI, at: self.address, abiVersion: 2)
            precondition(contract != nil)
            return contract!
            // swiftlint:enable force_unwrapping
        }()

        public init(web3: Web3, address: EthereumAddress) {
            self.web3 = web3
            self.address = address
        }

        public func claimAddress(from: EthereumAddress, owner: EthereumAddress) throws -> WriteOperation {
            try contract.createWriteFunctionCall("claim", parameters: [owner])
        }

        public func claimAddressWithResolver(from: EthereumAddress, owner: EthereumAddress, resolver: EthereumAddress) throws -> WriteOperation {
            try contract.createWriteFunctionCall("claimWithResolver", parameters: [owner, resolver])
        }

        public func setName(from: EthereumAddress, name: String) throws -> WriteOperation {
            try contract.createWriteFunctionCall("setName", parameters: [name])
        }

        public func getReverseRecordName(address: EthereumAddress) async throws -> Data {
            try await contract.callReadOnlyFunction("node", parameters: [address])
        }

        public func getDefaultResolver() async throws -> EthereumAddress {
            try await contract.callReadOnlyFunction("defaultResolver")
        }
    }
}
