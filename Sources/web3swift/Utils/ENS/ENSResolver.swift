//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

public extension ENS {
    class Resolver {
        public let web3: Web3
        public let resolverContractAddress: EthereumAddress

        public enum ContentType: BigUInt {
            case JSON = 1
            case zlibCompressedJSON = 2
            case CBOR = 4
            case URI = 8
        }

        public enum InterfaceName {
            case addr
            case name
            case content
            case ABI
            case pubkey
            case text
            var hash: String {
                switch self {
                case .addr:
                    return "0x3b3b57de"
                case .name:
                    return "0x691f3431"
                case .content:
                    return "0xbc1c58d1"
                case .ABI:
                    return "0x2203ab56"
                case .pubkey:
                    return "0xc8690233"
                case .text:
                    return "0x59d1d43c"
                }
            }

        }

        lazy var resolverContract: Web3.Contract = {
            let contract = self.web3.contract(Web3.Utils.resolverABI, at: self.resolverContractAddress, abiVersion: 2)
            precondition(contract != nil)
            return contract!
        }()

        public init(web3: Web3, resolverContractAddress: EthereumAddress) {
            self.web3 = web3
            self.resolverContractAddress = resolverContractAddress
        }

        private func nameHash(_ value: String) throws -> Data {
            guard let nameHash = NameHash.nameHash(value) else {
                throw Web3Error.processingError(desc: "NameHash.nameHash(\(value) failed. Please check the given value.")
            }
            return nameHash
        }

        private func writeToChain(_ methodName: String, parameters: [Any], password: String) async throws -> TransactionSendingResult {
            let writeOperation = try resolverContract.createWriteFunctionCall(methodName, parameters: parameters)
            writeOperation.transaction.to = resolverContractAddress
            return try await writeOperation.writeToChain(password: password)
        }

        public func supportsInterface(interfaceID: Data) async throws -> Bool {
            try await supportsInterface(interfaceID: interfaceID.toHexString())
        }

        public func supportsInterface(interfaceID: InterfaceName) async throws -> Bool {
            try await supportsInterface(interfaceID: interfaceID.hash)
        }

        public func supportsInterface(interfaceID: String) async throws -> Bool {
            try await resolverContract.callReadOnlyFunction("supportsInterface", parameters: [interfaceID])
        }

        public func interfaceImplementer(forNode node: String, interfaceID: String) async throws -> EthereumAddress {
            try await resolverContract.callReadOnlyFunction("interfaceImplementer", parameters: [try nameHash(node), interfaceID])
        }

        public func getAddress(forNode node: String) async throws -> EthereumAddress {
            try await resolverContract.callReadOnlyFunction("addr", parameters: [try nameHash(node)])
        }

        // FIXME: Rewrite this to CodableTransaction
        @available(*, message: "Available for only owner")
        public func setAddress(forNode node: String, address: EthereumAddress, transaction: CodableTransaction? = nil, password: String) async throws -> TransactionSendingResult {
            try await writeToChain("setAddr", parameters: [try nameHash(node), address], password: password)
        }

        public func getCanonicalName(forNode node: String) async throws -> String {
            try await resolverContract.callReadOnlyFunction("name", parameters: [try nameHash(node)])
        }

        // FIXME: Rewrite this to CodableTransaction
        @available(*, message: "Available for only owner")
        func setCanonicalName(forNode node: String, name: String, transaction: CodableTransaction? = nil, password: String) async throws -> TransactionSendingResult {
            try await writeToChain("setName", parameters: [try nameHash(node), name], password: password)
        }

        func getContentHash(forNode node: String) async throws -> Data {
            try await resolverContract.callReadOnlyFunction("contenthash", parameters: [try nameHash(node)])
        }

        // FIXME: Rewrite this to CodableTransaction
        @available(*, message: "Available for only owner")
        func setContentHash(forNode node: String, hash: String, transaction: CodableTransaction? = nil, password: String) async throws -> TransactionSendingResult {
            try await writeToChain("setContenthash", parameters: [try nameHash(node), hash], password: password)
        }

        public func getContractABI(forNode node: String, contentType: ENS.Resolver.ContentType) async throws -> (BigUInt, Data) {
            let parameters: [Any] = [try nameHash(node), contentType.rawValue]
            guard let transaction = self.resolverContract.createReadOperation("ABI", parameters: parameters) else {
                throw Web3Error.transactionSerializationError(desc: "Failed to encode `ABI` function call with given parameters \(String(describing: parameters)). Make sure contract contains `ABI` function ABI and the order of given parameters is correct.")
            }

            let result = try await transaction.call()

            guard let encoding = result["0"] as? BigUInt else {
                throw Web3Error.processingError(desc: "Response value for key \"0\" cannot be cast to type BigUInt. Response is: \(String(describing: result["0"])).")
            }
            guard let data = result["1"] as? Data else {
                throw Web3Error.processingError(desc: "Response value for key \"1\" cannot be cast to type Data. Response is: \(String(describing: result["1"])).")
            }
            return (encoding, data)
        }

        // FIXME: Rewrite this to CodableTransaction
        @available(*, message: "Available for only owner")
        func setContractABI(forNode node: String, contentType: ENS.Resolver.ContentType, data: Data, transaction: CodableTransaction? = nil, password: String) async throws -> TransactionSendingResult {
            try await writeToChain("setABI", parameters: [try nameHash(node), contentType.rawValue, data], password: password)
        }

        public func getPublicKey(forNode node: String) async throws -> PublicKey {
            let parameters: [Any] = [try nameHash(node)]
            guard let transaction = self.resolverContract.createReadOperation("pubkey", parameters: parameters) else  {
                throw Web3Error.transactionSerializationError(desc: "Failed to encode `pubkey` function call with given parameters \(String(describing: parameters)). Make sure contract contains `pubkey` function ABI and the order of given parameters is correct.")
            }
            guard let result = try? await transaction.call() else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let x = result["x"] as? Data else {
                throw Web3Error.processingError(desc: "Response value for key \"x\" cannot be cast to type Data. Response is: \(String(describing: result["x"])).")
            }
            guard let y = result["y"] as? Data else {
                throw Web3Error.processingError(desc: "Response value for key \"y\" cannot be cast to type Data. Response is: \(String(describing: result["y"])).")
            }
            let pubkey = PublicKey(x: "0x" + x.toHexString(), y: "0x" + y.toHexString())
            return pubkey
        }

        // FIXME: Rewrite this to CodableTransaction
        @available(*, message: "Available for only owner")
        public func setPublicKey(forNode node: String, publicKey: PublicKey, transaction: CodableTransaction? = nil, password: String) async throws -> TransactionSendingResult {
            let pubkeyWithoutPrefix = publicKey.getComponentsWithoutPrefix()
            return try await writeToChain("setPubkey", parameters: [try nameHash(node), pubkeyWithoutPrefix.x, pubkeyWithoutPrefix.y], password: password)
        }

        public func getTextData(forNode node: String, key: String) async throws -> String {
            try await resolverContract.callReadOnlyFunction("text", parameters: [try nameHash(node), key])
        }

        // FIXME: Rewrite this to CodableTransaction
        @available(*, message: "Available for only owner")
        public func setTextData(forNode node: String, key: String, value: String, transaction: CodableTransaction? = nil, password: String) async throws -> TransactionSendingResult {
            try await writeToChain("setText", parameters: [try nameHash(node), key, value], password: password)
        }
    }
}
