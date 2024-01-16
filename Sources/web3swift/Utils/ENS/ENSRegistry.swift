//
//  ENSRegistry.swift
//
//  Created by Anton on 17/04/2019.
//  Copyright © 2019 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

public extension ENS {
    class Registry {

        internal static let ethereumMainnetENSRegistryAddress: EthereumAddress? = EthereumAddress("0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e")
        internal static let goerliTestnetENSRegistryAddress: EthereumAddress? = EthereumAddress("0x112234455c3a32fd11230c42e7bccd4a84e02010")

        public let web3: Web3
        public let registryContractAddress: EthereumAddress

        public init?(web3: Web3) {
            self.web3 = web3
            switch web3.provider.network {
            case .Mainnet?, .Rinkeby?, .Ropsten?:
                registryContractAddress = Registry.ethereumMainnetENSRegistryAddress!
            default:
                let url = web3.provider.url.absoluteString
                if url.contains("https://rpc.goerli.mudit.blog")
                    || url.contains("http://goerli.blockscout.com")
                    || url.contains("http://goerli.prylabs.net")
                    || url.contains("https://rpc.slock.it/goerli") {
                    registryContractAddress = Registry.goerliTestnetENSRegistryAddress!
                }
                return nil
            }
        }

        lazy var registryContract: Web3.Contract = {
            let contract = self.web3.contract(Web3.Utils.ensRegistryABI, at: self.registryContractAddress, abiVersion: 2)
            precondition(contract != nil)
            return contract!
        }()

        private func nameHash(_ value: String) throws -> Data {
            guard let nameHash = NameHash.nameHash(value) else {
                throw Web3Error.processingError(desc: "NameHash.nameHash(\(value) failed. Please check the given value.")
            }
            return nameHash
        }

        private func writeToChain(_ methodName: String, parameters: [Any], password: String) async throws -> TransactionSendingResult {
            let writeOperation = try registryContract.createWriteFunctionCall(methodName, parameters: parameters)
            writeOperation.transaction.to = registryContractAddress
            return try await writeOperation.writeToChain(password: password)
        }

        public func getOwner(node: String) async throws -> EthereumAddress {
            try await registryContract.callReadOnlyFunction("owner", parameters: [try nameHash(node)])
        }

        public func getResolver(forDomain domain: String) async throws -> Resolver {
            let resolverAddress: EthereumAddress = try await registryContract.callReadOnlyFunction("resolver", parameters: [try nameHash(domain)])
            return Resolver(web3: self.web3, resolverContractAddress: resolverAddress)
        }

        public func getTTL(node: String) async throws -> BigUInt {
            try await registryContract.callReadOnlyFunction("ttl", parameters: [try nameHash(node)])
        }

        // FIXME: Rewrite this to CodableTransaction
        public func setOwner(node: String, owner: EthereumAddress, transaction: CodableTransaction?, password: String) async throws -> TransactionSendingResult {
            try await writeToChain("setOwner", parameters: [try nameHash(node), owner], password: password)
        }

        // FIXME: Rewrite this to CodableTransaction
        public func setSubnodeOwner(node: String, label: String, owner: EthereumAddress, transaction: CodableTransaction?, password: String) async throws -> TransactionSendingResult {
            try await writeToChain("setSubnodeOwner", parameters: [try nameHash(node), try nameHash(label), owner], password: password)
        }

        // FIXME: Rewrite this to CodableTransaction
        public func setResolver(node: String, resolver: EthereumAddress, transaction: CodableTransaction?, password: String) async throws -> TransactionSendingResult {
            try await writeToChain("setResolver", parameters: [try nameHash(node), resolver], password: password)
        }

        // FIXME: Rewrite this to CodableTransaction
        public func setTTL(node: String, ttl: BigUInt, transaction: CodableTransaction?, password: String) async throws -> TransactionSendingResult {
            try await writeToChain("setTTL", parameters: [try nameHash(node), ttl], password: password)
        }
    }
}
