//
//  ENSResolver.swift
//  web3swift-iOS
//
//  Created by NewUser on 21/09/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import Result
import EthereumAddress

extension ResolverENS {
    
    //function setAddr(bytes32 node, address addr)
    @available(*, deprecated, message: "Don't use Result and Web3Options")
    mutating public func setAddr(node: String, address: EthereumAddress, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError)}
        guard let transaction = self.resolverContract.method("setAddr", parameters: [nameHash, address] as [AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = password == nil ? transaction.send(options: nil) : transaction.send(password: password!, options: options)
        return result
    }
    
    @available(*, deprecated, message: "Don't use Result and Web3Options")
    mutating func setName(node: String, name: String, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error>{
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.resolverContract.method("setName", parameters: [nameHash, name] as [AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = password == nil ? transaction.send(options: nil) : transaction.send(password: password!, options: options)
        return result
    }
    
    @available(*, deprecated, message: "Don't use Result and Web3Options")
    mutating func setABI(node: String, contentType: BigUInt, data: Data, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.resolverContract.method("setABI", parameters: [nameHash, contentType, data] as [AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = password == nil ? transaction.send(options: nil) : transaction.send(password: password!, options: options)
        return result
    }
    
    @available(*, deprecated, message: "Don't use Result and Web3Options")
    mutating public func setPubkey(node: String, x: String, y: String, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.resolverContract.method("getPubkey", parameters: [nameHash, x, y] as [AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = password == nil ? transaction.send(options: nil) : transaction.send(password: password!, options: options)
        return result
    }
    
    @available(*, deprecated, message: "Don't use Result and Web3Options")
    mutating func setContent(node: String, hash: String, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.resolverContract.method("setContent", parameters: [nameHash, hash] as [AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = password == nil ? transaction.send(options: nil) : transaction.send(password: password!, options: options)
        return result
    }
    
    //function setMultihash(bytes32 node, bytes hash) public only_owner(node)
    @available(*, deprecated, message: "Don't use Result and Web3Options")
    mutating public func setMultihash(node: String, hash: Data, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.transactionSerializationError) }
        let options = getOptions(options)
        guard let transaction = self.resolverContract.method("setMultihash", parameters: [nameHash, hash] as [AnyObject], options: options) else { return Result.failure(Web3Error.dataError) }
        let result = password == nil ? transaction.send(options: nil) : transaction.send(password: password!, options: options)
        return result
    }
    
    //function setText(bytes32 node, string key, string value) public only_owner(node)
    @available(*, deprecated, message: "Don't use Result and Web3Options")
    mutating public func setText(node: String, key: String, value: String, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.resolverContract.method("setText", parameters: [nameHash, key, value] as [AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = password == nil ? transaction.send(options: nil) : transaction.send(password: password!, options: options)
        return result
    }
    
    @available(*, deprecated, message: "Use TransacionOptions type instead")
    private func getOptions(_ options: Web3Options) -> Web3Options {
        var options = options
        options.to = self.resolverAddress
        return options
    }
}
