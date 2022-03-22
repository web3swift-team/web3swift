//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

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

        lazy var resolverContract: web3.web3contract = {
            let contract = self.web3.contract(Web3.Utils.resolverABI, at: self.resolverContractAddress, abiVersion: 2)
            precondition(contract != nil)
            return contract!
        }()

        lazy var defaultOptions: TransactionOptions = {
            return TransactionOptions.defaultOptions
        }()

        public init(web3: web3, resolverContractAddress: EthereumAddress) {
            self.web3 = web3
            self.resolverContractAddress = resolverContractAddress
        }

        public func supportsInterface(interfaceID: Data) throws -> Bool {
            guard let supports = try? supportsInterface(interfaceID: interfaceID.toHexString()) else {throw Web3Error.processingError(desc: "Can't get answer")}
            return supports
        }

        public func supportsInterface(interfaceID: String) throws -> Bool {
            guard let transaction = self.resolverContract.read("supportsInterface", parameters: [interfaceID as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let supports = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Can't get answer")}
            return supports
        }

        public func interfaceImplementer(forNode node: String, interfaceID: String) throws -> EthereumAddress {
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.read("interfaceImplementer", parameters: [nameHash, interfaceID] as [AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let address = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Can't get address")}
            return address
        }

        public func getAddress(forNode node: String) throws -> EthereumAddress {
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.read("addr", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let address = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Can't get address")}
            return address
        }

        @available(*, message: "Available for only owner")
        public func setAddress(forNode node: String, address: EthereumAddress, options: TransactionOptions? = nil, password: String? = nil) throws -> TransactionSendingResult {
            var options = options ?? defaultOptions
            options.to = self.resolverContractAddress
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.write("setAddr", parameters: [nameHash, address] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
            guard let result = password == nil ? try? transaction.send(): try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
            return result
        }

        public func getCanonicalName(forNode node: String) throws -> String {
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.read("name", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let name = result["0"] as? String else {throw Web3Error.processingError(desc: "Can't get name")}
            return name
        }

        @available(*, message: "Available for only owner")
        func setCanonicalName(forNode node: String, name: String, options: TransactionOptions? = nil, password: String? = nil) throws -> TransactionSendingResult {
            var options = options ?? defaultOptions
            options.to = self.resolverContractAddress
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.write("setName", parameters: [nameHash, name] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
            guard let result = password == nil ? try? transaction.send(): try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
            return result
        }

        func getContentHash(forNode node: String) throws -> Data {
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.read("contenthash", parameters: [nameHash] as [AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let content = result["0"] as? Data else {throw Web3Error.processingError(desc: "Can't get content")}
            return content
        }

        @available(*, message: "Available for only owner")
        func setContentHash(forNode node: String, hash: String, options: TransactionOptions? = nil, password: String? = nil) throws -> TransactionSendingResult {
            var options = options ?? defaultOptions
            options.to = self.resolverContractAddress
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.write("setContenthash", parameters: [nameHash, hash] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
            guard let result = password == nil ? try? transaction.send(): try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
            return result
        }

        public func getContractABI(forNode node: String, contentType: ENS.Resolver.ContentType) throws -> (BigUInt, Data) {
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.read("ABI", parameters: [nameHash, contentType.rawValue] as [AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let encoding = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Can't get encoding")}
            guard let data = result["1"] as? Data else {throw Web3Error.processingError(desc: "Can't get data")}
            return (encoding, data)
        }

        @available(*, message: "Available for only owner")
        func setContractABI(forNode node: String, contentType: ENS.Resolver.ContentType, data: Data, options: TransactionOptions? = nil, password: String? = nil) throws -> TransactionSendingResult {
            var options = options ?? defaultOptions
            options.to = self.resolverContractAddress
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.write("setABI", parameters: [nameHash, contentType.rawValue, data] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
            guard let result = password == nil ? try? transaction.send(): try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
            return result
        }

        public func getPublicKey(forNode node: String) throws -> PublicKey {
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.read("pubkey", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let x = result["x"] as? Data else {throw Web3Error.processingError(desc: "Can't get x")}
            guard let y = result["y"] as? Data else {throw Web3Error.processingError(desc: "Can't get y")}
            let pubkey = PublicKey(x: "0x" + x.toHexString(), y: "0x" + y.toHexString())
            return pubkey
        }

        @available(*, message: "Available for only owner")
        public func setPublicKey(forNode node: String, publicKey: PublicKey, options: TransactionOptions? = nil, password: String? = nil) throws -> TransactionSendingResult {
            var options = options ?? defaultOptions
            options.to = self.resolverContractAddress
            let pubkeyWithoutPrefix = publicKey.getComponentsWithoutPrefix()
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.write("setPubkey", parameters: [nameHash, pubkeyWithoutPrefix.x, pubkeyWithoutPrefix.y] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
            guard let result = password == nil ? try? transaction.send(): try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
            return result
        }

        public func getTextData(forNode node: String, key: String) throws -> String {
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.read("text", parameters: [nameHash, key] as [AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let text = result["0"] as? String else {throw Web3Error.processingError(desc: "Can't get text")}
            return text
        }

        @available(*, message: "Available for only owner")
        public func setTextData(forNode node: String, key: String, value: String, options: TransactionOptions? = nil, password: String? = nil) throws -> TransactionSendingResult {
            var options = options ?? defaultOptions
            options.to = self.resolverContractAddress
            guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
            guard let transaction = self.resolverContract.write("setText", parameters: [nameHash, key, value] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
            guard let result = password == nil ? try? transaction.send(): try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
            return result
        }
    }
}
