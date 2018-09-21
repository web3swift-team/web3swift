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

public struct ResolverENS {
    let web3: web3
    let resolverAddress: EthereumAddress
    
    public enum InterfaceName {
        case addr
        case name
        case ABI
        case pubkey
        case setAddr
        case content
        
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
            case .setAddr:
                return "0x01ffc9a7"
            }
        }
    }
    
    private lazy var resolverContract: web3.web3contract = {
        let contract = self.web3.contract(Web3.Utils.resolverABI, at: self.resolverAddress, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()
    
    private lazy var defaultOptions: Web3Options = {
        return Web3Options.defaultOptions()
    }()
    
    init(web3: web3, resolverAddress: EthereumAddress) {
        self.web3 = web3
        self.resolverAddress = resolverAddress
    }
    
    mutating public func supportsInterface(interfaceID: Data) -> Result<Bool, Web3Error> {
        return supportsInterface(interfaceID: interfaceID.toHexString())
    }
    
    //MARK: - returns true if the contract supports given interface
    mutating public func supportsInterface(interfaceID: String) -> Result<Bool, Web3Error> {
        guard let transaction = self.resolverContract.method("supportsInterface", parameters: [interfaceID as AnyObject], options: defaultOptions) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = transaction.call(options: defaultOptions)
        switch result {
        case .success(let res):
            guard let supports = res["0"] as? Bool else { return Result.failure(Web3Error.dataError) }
            return Result(supports)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    //MARK: - returns address for the given domain at given resolver
    mutating public func addr(forDomain domain: String) -> Result<EthereumAddress, Web3Error> {
        guard let nameHash = NameHash.nameHash(domain) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.resolverContract.method("addr", parameters: [nameHash as AnyObject], options: defaultOptions) else  { return Result.failure(Web3Error.dataError) }
        let result = transaction.call(options: defaultOptions)
        switch result {
        case .success(let res):
            return Result(res["0"] as! EthereumAddress)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    //function setAddr(bytes32 node, address addr)
    mutating public func setAddr(node: String, address: EthereumAddress, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError)}
        guard let transaction = self.resolverContract.method("setAddr", parameters: [nameHash, address] as [AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = password == nil ? transaction.send() : transaction.send(password: password!, options: options)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let value):
            return Result(value)
        }
    }
    
    //MARK: - returns corresponding ENS to the requested node
    mutating public func name(node: String) -> Result<String, Web3Error> {
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.resolverContract.method("name", parameters: [nameHash as AnyObject], options: defaultOptions) else { return Result.failure(Web3Error.transactionSerializationError)}
        let result = transaction.call(options: defaultOptions)
        switch result {
        case .success(let res):
            return Result(res["0"] as! String)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    mutating func setName(node: String, name: String, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error>{
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.resolverContract.method("setName", parameters: [nameHash, name] as [AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = password == nil ? transaction.send() : transaction.send(password: password!, options: options)
        switch result {
        case .success(let value):
            return Result(value)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    //MARK: - returns ABI in the requested encodings
    mutating public func ABI(node: String, contentType: BigUInt) -> Result<(BigUInt, Data), Web3Error> {
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.resolverContract.method("ABI", parameters: [nameHash, contentType] as [AnyObject], options: defaultOptions) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = transaction.call(options: defaultOptions)
        switch result {
        case .success(let res):
            guard let encoding = res["0"] as? BigUInt else { return Result.failure(Web3Error.dataError) }
            guard let data = res["1"] as? Data else { return Result.failure(Web3Error.dataError) }
            return Result((encoding, data))
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    mutating func setABI(node: String, contentType: BigUInt, data: Data, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.resolverContract.method("setABI", parameters: [nameHash, contentType, data] as [AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = password == nil ? transaction.send() : transaction.send(password: password!, options: options)
        switch result {
        case .success(let value):
            return Result(value)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    //MARK: - returns x and y coordinates
    mutating public func pubkey(node: String) -> Result<Point, Web3Error> {
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.resolverContract.method("pubkey", parameters: [nameHash as AnyObject], options: defaultOptions) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = transaction.call(options: defaultOptions)
        switch result {
        case .success(let value):
            print(value)
            guard let x = value["x"] as? Data else { return Result.failure(Web3Error.dataError) }
            guard let y = value["y"] as? Data else { return Result.failure(Web3Error.dataError) }
            return Result(Point(x: "0x" + x.toHexString(), y: "0x" + y.toHexString()))
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    mutating public func setPubkey(node: String, x: String, y: String, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.resolverContract.method("getPubkey", parameters: [nameHash, x, y] as [AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = password == nil ? transaction.send() : transaction.send(password: password!, options: options)
        switch result {
        case .success(let value):
            return Result(value)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    mutating func content(node: String) -> Result<String, Web3Error> {
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.resolverContract.method("content", parameters: [nameHash] as [AnyObject], options: defaultOptions) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = transaction.call(options: defaultOptions)
        switch result {
        case .success(let value):
            guard let value = value["0"] as? String else { return Result.failure(Web3Error.dataError) }
            return Result(value)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    mutating func setContent(node: String, hash: String, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error>{
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.resolverContract.method("setContent", parameters: [nameHash, hash] as [AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = password == nil ? transaction.send() : transaction.send(password: password!, options: options)
        switch result {
        case .success(let value):
            return Result(value)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    private func getOptions(_ options: Web3Options) -> Web3Options {
        var options = options
        options.to = self.resolverAddress
        return options
    }
}

public struct Point {
    let x: String
    let y: String
}
