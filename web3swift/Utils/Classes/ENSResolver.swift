//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import EthereumAddress

public struct ResolverENS {
    let web3: web3
    let resolverAddress: EthereumAddress
    
    public enum InterfaceName {
        case addr
        case name
        case ABI
        case pubkey
        case content
        case multihash
        case text
        
        func hash() -> String {
            switch self {
            case .ABI:
                return "0x2203ab56"
            case .addr:
                return "0x3b3b57de"
            case .name:
                return "0x691f3431"
            case .pubkey:
                return "0xc8690233"
            case .content:
                return "0xd8389dc5"
            case .multihash:
                return "0xe89401a1"
            case .text:
                return "0x59d1d43c"
            }
        }
    }
    
    lazy var resolverContract: web3.web3contract = {
        let contract = self.web3.contract(Web3.Utils.resolverABI, at: self.resolverAddress, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()
    
    lazy var defaultOptions: TransactionOptions = {
        return TransactionOptions.defaultOptions
    }()
    
    init(web3: web3, resolverAddress: EthereumAddress) {
        self.web3 = web3
        self.resolverAddress = resolverAddress
    }
    
    mutating public func supportsInterface(interfaceID: Data) throws -> Bool {
        guard let supports = try? supportsInterface(interfaceID: interfaceID.toHexString()) else {throw Web3Error.processingError(desc: "Can't get answer")}
        return supports
    }
    
    //MARK: - returns true if the contract supports given interface
    mutating public func supportsInterface(interfaceID: String) throws -> Bool {
        guard let transaction = self.resolverContract.read("supportsInterface", parameters: [interfaceID as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let supports = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Can't get answer")}
        return supports
    }
    
    //MARK: - returns address for the given domain at given resolver
    mutating public func addr(forDomain domain: String) throws -> EthereumAddress {
        guard let nameHash = NameHash.nameHash(domain) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.read("addr", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let address = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Can't get address")}
        return address
    }
    
    //function setAddr(bytes32 node, address addr)
    mutating public func setAddr(node: String, address: EthereumAddress, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.write("setAddr", parameters: [nameHash, address] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    
    //MARK: - returns corresponding ENS to the requested node
    mutating public func name(node: String) throws -> String {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.read("name", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let name = result["0"] as? String else {throw Web3Error.processingError(desc: "Can't get name")}
        return name
    }
    
    mutating func setName(node: String, name: String, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.write("setName", parameters: [nameHash, name] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    
    //MARK: - returns ABI in the requested encodings
    mutating public func ABI(node: String, contentType: BigUInt) throws -> (BigUInt, Data) {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.read("ABI", parameters: [nameHash, contentType] as [AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let encoding = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Can't get encoding")}
        guard let data = result["1"] as? Data else {throw Web3Error.processingError(desc: "Can't get data")}
        return (encoding, data)
    }
    
    mutating func setABI(node: String, contentType: BigUInt, data: Data, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.write("setABI", parameters: [nameHash, contentType, data] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    
    //MARK: - returns x and y coordinates
    mutating public func pubkey(node: String) throws -> PublicKey {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.read("pubkey", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let x = result["x"] as? Data else {throw Web3Error.processingError(desc: "Can't get x")}
        guard let y = result["y"] as? Data else {throw Web3Error.processingError(desc: "Can't get y")}
        let pubkey = PublicKey(x: "0x" + x.toHexString(), y: "0x" + y.toHexString())
        return pubkey
    }
    
    mutating public func setPubkey(node: String, x: String, y: String, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.write("setPubkey", parameters: [nameHash, x, y] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    
    mutating func content(node: String) throws -> String {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.read("content", parameters: [nameHash] as [AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let content = result["0"] as? String else {throw Web3Error.processingError(desc: "Can't get content")}
        return content
    }
    
    mutating func setContent(node: String, hash: String, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.write("setContent", parameters: [nameHash, hash] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    //function multihash(bytes32 node) public view returns (bytes)
    mutating public func multihash(node: String) throws -> Data {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.read("multihash", parameters: [nameHash] as [AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let multihash = result["0"] as? Data else {throw Web3Error.processingError(desc: "Can't get multihash")}
        return multihash
    }
    //function setMultihash(bytes32 node, bytes hash) public only_owner(node)
    mutating public func setMultihash(node: String, hash: Data, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.write("setMultihash", parameters: [nameHash, hash] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    //function text(bytes32 node, string key) public view returns (string)
    mutating public func text(node: String, key: String) throws -> String {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.read("text", parameters: [nameHash, key] as [AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let text = result["0"] as? String else {throw Web3Error.processingError(desc: "Can't get text")}
        return text
    }
    //function setText(bytes32 node, string key, string value) public only_owner(node)
    mutating public func setText(node: String, key: String, value: String, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.write("setText", parameters: [nameHash, key, value] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    private func getOptions(_ options: TransactionOptions) -> TransactionOptions {
        var options = options
        options.to = self.resolverAddress
        return options
    }
}

public struct PublicKey {
    let x: String
    let y: String
}
