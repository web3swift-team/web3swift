//
//  ENSRegistry.swift
//
//  Created by Anton on 17/04/2019.
//  Copyright © 2019 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import Core

public extension ENS {
    class Registry {
        public let web3: web3
        public let registryContractAddress: EthereumAddress?

        public init?(web3: web3) {
            self.web3 = web3
            switch web3.provider.network {
            case .Mainnet?:
                registryContractAddress = EthereumAddress("0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e")
            case .Rinkeby?:
                registryContractAddress = EthereumAddress("0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e")
            case .Ropsten?:
                registryContractAddress = EthereumAddress("0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e")
            default:
                let url = web3.provider.url.absoluteString
                if url.contains("https://rpc.goerli.mudit.blog")
                    || url.contains("http://goerli.blockscout.com")
                    || url.contains("http://goerli.prylabs.net")
                    || url.contains("https://rpc.slock.it/goerli") {
                    registryContractAddress = EthereumAddress("0x112234455c3a32fd11230c42e7bccd4a84e02010")
                }
                return nil
            }
        }

        // FIXME: Rewrite this to CodableTransaction
        lazy var defaultOptions: CodableTransaction = {
            return CodableTransaction.emptyTransaction
        }()

        lazy var registryContract: web3.web3contract = {
            let contract = self.web3.contract(Web3.Utils.ensRegistryABI, at: self.registryContractAddress, abiVersion: 2)
            precondition(contract != nil)
            return contract!
        }()

        public func getOwner(node: String) async throws -> EthereumAddress {
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.registryContract.read("owner", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            guard let result = try? await transaction.decodedData() else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let address = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "No address in result")}
            return address
        }

        public func getResolver(forDomain domain: String) async throws -> Resolver {
            guard let nameHash = NameHash.nameHash(domain) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.registryContract.read("resolver", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            guard let result = try? await transaction.decodedData() else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let resolverAddress = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "No address in result")}
            return Resolver(web3: self.web3, resolverContractAddress: resolverAddress)
        }

        public func getTTL(node: String) async throws -> BigUInt {
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.registryContract.read("ttl", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            guard let result = try? await transaction.decodedData() else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let ans = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "No answer in result")}
            return ans
        }

        // FIXME: Rewrite this to CodableTransaction
        public func setOwner(node: String, owner: EthereumAddress, options: CodableTransaction?, password: String? = nil) async throws -> TransactionSendingResult {
            var options = options ?? defaultOptions
            if let contractAddress = self.registryContractAddress {
                options.to = contractAddress
            }
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.registryContract.write("setOwner", parameters: [nameHash, owner] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
            guard let result = await password == nil
                    ? try? transaction.send(password: "web3swift")
                    : try? transaction.send(password: password!)
            else {throw Web3Error.processingError(desc: "Can't send transaction")}
            return result
        }

        // FIXME: Rewrite this to CodableTransaction
        public func setSubnodeOwner(node: String, label: String, owner: EthereumAddress, options: CodableTransaction?, password: String? = nil) async throws -> TransactionSendingResult {
            var options = options ?? defaultOptions
            if let contractAddress = self.registryContractAddress {
                options.to = contractAddress
            }
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let labelHash = NameHash.nameHash(label) else {throw Web3Error.processingError(desc: "Failed to get label hash")}
            guard let transaction = self.registryContract.write("setSubnodeOwner", parameters: [nameHash, labelHash, owner] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
            guard let result = await password == nil
                    ? try? transaction.send(password: "web3swift")
                    : try? transaction.send(password: password!)
            else {throw Web3Error.processingError(desc: "Can't send transaction")}
            return result
        }

        // FIXME: Rewrite this to CodableTransaction
        public func setResolver(node: String, resolver: EthereumAddress, options: CodableTransaction?, password: String? = nil) async throws -> TransactionSendingResult {
            var options = options ?? defaultOptions
            if let contractAddress = self.registryContractAddress {
                options.to = contractAddress
            }
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.registryContract.write("setResolver", parameters: [nameHash, resolver] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
            guard let result = await password == nil
                    ? try? transaction.send(password: "web3swift")
                    : try? transaction.send(password: password!)
            else {throw Web3Error.processingError(desc: "Can't send transaction")}
            return result
        }

        // FIXME: Rewrite this to CodableTransaction
        public func setTTL(node: String, ttl: BigUInt, options: CodableTransaction?, password: String? = nil) async throws -> TransactionSendingResult {
            var options = options ?? defaultOptions
            if let contractAddress = self.registryContractAddress {
                options.to = contractAddress
            }
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.registryContract.write("setTTL", parameters: [nameHash, ttl] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
            guard let result = await password == nil
                    ? try? transaction.send(password: "web3swift")
                    : try? transaction.send(password: password!)
            else {throw Web3Error.processingError(desc: "Can't send transaction")}
            return result
        }
    }
}
