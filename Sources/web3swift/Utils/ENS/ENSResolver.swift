//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core

public extension ENS {
    class Resolver {
        public let web3: web3
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

            func hash() -> String {
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

        lazy var resolverContract: web3.Contract = {
            let contract = self.web3.contract(Web3.Utils.resolverABI, at: self.resolverContractAddress, abiVersion: 2)
            precondition(contract != nil)
            return contract!
        }()

        // FIXME: Rewrite this to CodableTransaction
        lazy var defaultOptions: CodableTransaction = {
            return CodableTransaction.emptyTransaction
        }()

        public init(web3: web3, resolverContractAddress: EthereumAddress) {
            self.web3 = web3
            self.resolverContractAddress = resolverContractAddress
        }

        public func supportsInterface(interfaceID: Data) async throws -> Bool {
            guard let supports = try? await supportsInterface(interfaceID: interfaceID.toHexString()) else {throw Web3Error.processingError(desc: "Can't get answer")}
            return supports
        }

        public func supportsInterface(interfaceID: String) async throws -> Bool {
            guard let transaction = self.resolverContract.createReadOperation("supportsInterface", parameters: [interfaceID as AnyObject], extraData: Data() ) else {throw Web3Error.transactionSerializationError}
            guard let result = try? await transaction.callContractMethod() else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let supports = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Can't get answer")}
            return supports
        }

        public func interfaceImplementer(forNode node: String, interfaceID: String) async throws -> EthereumAddress {
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.createReadOperation("interfaceImplementer", parameters: [nameHash, interfaceID] as [AnyObject], extraData: Data() ) else {throw Web3Error.transactionSerializationError}
            guard let result = try? await transaction.callContractMethod() else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let address = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Can't get address")}
            return address
        }

        public func getAddress(forNode node: String) async throws -> EthereumAddress {
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.createReadOperation("addr", parameters: [nameHash as AnyObject], extraData: Data() ) else {throw Web3Error.transactionSerializationError}
            guard let result = try? await transaction.callContractMethod() else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let address = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Can't get address")}
            return address
        }

        // FIXME: Rewrite this to CodableTransaction
        @available(*, message: "Available for only owner")
        public func setAddress(forNode node: String, address: EthereumAddress, options: CodableTransaction? = nil, password: String? = nil) async throws -> TransactionSendingResult {
            var options = options ?? defaultOptions
            options.to = self.resolverContractAddress
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.createWriteOperation("setAddr", parameters: [nameHash, address] as [AnyObject], extraData: Data() ) else {throw Web3Error.transactionSerializationError}
            guard let result = await password == nil
                    ? try? transaction.writeToChain(password: "web3swift")
                    : try? transaction.writeToChain(password: password!)
            else {throw Web3Error.processingError(desc: "Can't send transaction")}
            return result
        }

        public func getCanonicalName(forNode node: String) async throws -> String {
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.createReadOperation("name", parameters: [nameHash as AnyObject], extraData: Data() ) else {throw Web3Error.transactionSerializationError}
            guard let result = try? await transaction.callContractMethod() else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let name = result["0"] as? String else {throw Web3Error.processingError(desc: "Can't get name")}
            return name
        }

        // FIXME: Rewrite this to CodableTransaction
        @available(*, message: "Available for only owner")
        func setCanonicalName(forNode node: String, name: String, options: CodableTransaction? = nil, password: String? = nil) async throws -> TransactionSendingResult {
            var options = options ?? defaultOptions
            options.to = self.resolverContractAddress
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.createWriteOperation("setName", parameters: [nameHash, name] as [AnyObject], extraData: Data() ) else {throw Web3Error.transactionSerializationError}
            guard let result = await password == nil
                    ? try? transaction.writeToChain(password: "web3swift")
                    : try? transaction.writeToChain(password: password!)
            else {throw Web3Error.processingError(desc: "Can't send transaction")}
            return result
        }

        func getContentHash(forNode node: String) async throws -> Data {
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.createReadOperation("contenthash", parameters: [nameHash] as [AnyObject], extraData: Data() ) else {throw Web3Error.transactionSerializationError}
            guard let result = try? await transaction.callContractMethod() else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let content = result["0"] as? Data else {throw Web3Error.processingError(desc: "Can't get content")}
            return content
        }

        // FIXME: Rewrite this to CodableTransaction
        @available(*, message: "Available for only owner")
        func setContentHash(forNode node: String, hash: String, options: CodableTransaction? = nil, password: String? = nil) async throws -> TransactionSendingResult {
            var options = options ?? defaultOptions
            options.to = self.resolverContractAddress
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.createWriteOperation("setContenthash", parameters: [nameHash, hash] as [AnyObject], extraData: Data() ) else {throw Web3Error.transactionSerializationError}
            guard let result = await password == nil
                    ? try? transaction.writeToChain(password: "web3swift")
                    : try? transaction.writeToChain(password: password!)
            else {throw Web3Error.processingError(desc: "Can't send transaction")}
            return result
        }

        public func getContractABI(forNode node: String, contentType: ENS.Resolver.ContentType) async throws -> (BigUInt, Data) {
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.createReadOperation("ABI", parameters: [nameHash, contentType.rawValue] as [AnyObject], extraData: Data() ) else {throw Web3Error.transactionSerializationError}
            guard let result = try? await transaction.callContractMethod() else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let encoding = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Can't get encoding")}
            guard let data = result["1"] as? Data else {throw Web3Error.processingError(desc: "Can't get data")}
            return (encoding, data)
        }

        // FIXME: Rewrite this to CodableTransaction
        @available(*, message: "Available for only owner")
        func setContractABI(forNode node: String, contentType: ENS.Resolver.ContentType, data: Data, options: CodableTransaction? = nil, password: String? = nil) async throws -> TransactionSendingResult {
            var options = options ?? defaultOptions
            options.to = self.resolverContractAddress
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.createWriteOperation("setABI", parameters: [nameHash, contentType.rawValue, data] as [AnyObject], extraData: Data() ) else {throw Web3Error.transactionSerializationError}
            guard let result = await password == nil
                    ? try? transaction.writeToChain(password: "web3swift")
                    : try? transaction.writeToChain(password: password!)
            else {throw Web3Error.processingError(desc: "Can't send transaction")}
            return result
        }

        public func getPublicKey(forNode node: String) async throws -> PublicKey {
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.createReadOperation("pubkey", parameters: [nameHash as AnyObject], extraData: Data() ) else {throw Web3Error.transactionSerializationError}
            guard let result = try? await transaction.callContractMethod() else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let x = result["x"] as? Data else {throw Web3Error.processingError(desc: "Can't get x")}
            guard let y = result["y"] as? Data else {throw Web3Error.processingError(desc: "Can't get y")}
            let pubkey = PublicKey(x: "0x" + x.toHexString(), y: "0x" + y.toHexString())
            return pubkey
        }

        // FIXME: Rewrite this to CodableTransaction
        @available(*, message: "Available for only owner")
        public func setPublicKey(forNode node: String, publicKey: PublicKey, options: CodableTransaction? = nil, password: String? = nil) async throws -> TransactionSendingResult {
            var options = options ?? defaultOptions
            options.to = self.resolverContractAddress
            let pubkeyWithoutPrefix = publicKey.getComponentsWithoutPrefix()
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.createWriteOperation("setPubkey", parameters: [nameHash, pubkeyWithoutPrefix.x, pubkeyWithoutPrefix.y] as [AnyObject], extraData: Data() ) else {throw Web3Error.transactionSerializationError}
            guard let result = await password == nil
                    ? try? transaction.writeToChain(password: "web3swift")
                    : try? transaction.writeToChain(password: password!)
            else {throw Web3Error.processingError(desc: "Can't send transaction")}
            return result
        }

        public func getTextData(forNode node: String, key: String) async throws -> String {
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.createReadOperation("text", parameters: [nameHash, key] as [AnyObject], extraData: Data() ) else {throw Web3Error.transactionSerializationError}
            guard let result = try? await transaction.callContractMethod() else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let text = result["0"] as? String else {throw Web3Error.processingError(desc: "Can't get text")}
            return text
        }

        // FIXME: Rewrite this to CodableTransaction
        @available(*, message: "Available for only owner")
        public func setTextData(forNode node: String, key: String, value: String, options: CodableTransaction? = nil, password: String? = nil) async throws -> TransactionSendingResult {
            var options = options ?? defaultOptions
            options.to = self.resolverContractAddress
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.createWriteOperation("setText", parameters: [nameHash, key, value] as [AnyObject], extraData: Data() ) else {throw Web3Error.transactionSerializationError}
            guard let result = await password == nil
                    ? try? transaction.writeToChain(password: "web3swift")
                    : try? transaction.writeToChain(password: password!)
            else {throw Web3Error.processingError(desc: "Can't send transaction")}
            return result
        }
    }
}
