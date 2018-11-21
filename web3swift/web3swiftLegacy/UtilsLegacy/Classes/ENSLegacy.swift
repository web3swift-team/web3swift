//
//  ENS.swift
//  web3swift-iOS
//

import Foundation
import BigInt
import Result
import EthereumAddress

extension ENS {
    
    @available(*, deprecated, message: "Don't use Web3Options and Result")
    public func setAddress(domain: String, address: EthereumAddress, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error>{
        do {
            var resolver = try self.resolver(forDomain: domain)
            let isSetAddrSupported = try resolver.supportsInterface(interfaceID: ResolverENS.InterfaceName.addr.hash())
            if isSetAddrSupported {
                return resolver.setAddr(node: domain, address: address, options: options, password: password)
            } else {
                return Result.failure(Web3Error.dataError)
            }
        } catch {
            return Result.failure(Web3Error.dataError)
        }
    }
    
    @available(*, deprecated, message: "Don't use Web3Options and Result")
    public func setPubkey(domain: String, x: String, y: String, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
        do {
            var resolver = try self.resolver(forDomain: domain)
            return resolver.setPubkey(node: domain, x: x, y: y, options: options, password: password)
        } catch {
            return Result.failure(Web3Error.dataError)
        }
    }
    
    @available(*, deprecated, message: "Don't use Web3Options and Result")
    public func setContent(domain: String, hash: String, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
        do {
            var resolver = try self.resolver(forDomain: domain)
            return resolver.setContent(node: domain, hash: hash, options: options, password: password)
        } catch {
            return Result.failure(Web3Error.dataError)
        }
    }
    
    //    function setOwner(bytes32 node, address owner);
    @available(*, deprecated, message: "Don't use Web3Options and Result")
    public func setOwner(node: String, owner: EthereumAddress, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.registryContract.method("setOwner", parameters: [nameHash, owner] as [AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError)}
        let result = password == nil ? transaction.send() : transaction.send(password: password!, options: options)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let value):
            return Result(value)
        }
    }
    
    //    function setSubnodeOwner(bytes32 node, bytes32 label, address owner);
    @available(*, deprecated, message: "Don't use Web3Options and Result")
    public func setSubnodeOwner(node: String, label: String, owner: EthereumAddress, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let labelHash = NameHash.nameHash(label) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.registryContract.method("setSubnodeOwner", parameters: [nameHash, labelHash, owner] as [AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError)}
        let result = password == nil ? transaction.send() : transaction.send(password: password!, options: options)
        switch result {
        case .success(let value):
            return Result(value)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    //    function setResolver(bytes32 node, address resolver);
    @available(*, deprecated, message: "Don't use Web3Options and Result")
    public func setResolver(node: String, resolver: EthereumAddress, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.registryContract.method("setResolver", parameters: [nameHash, resolver] as [AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = password == nil ? transaction.send() : transaction.send(password: password!, options: options)
        switch result {
        case .success(let value):
            return Result(value)
        case .failure(let error):
            return Result.failure(error)
        }
        
    }
    
    //    function setTTL(bytes32 node, uint64 ttl);
    @available(*, deprecated, message: "Don't use Web3Options and Result")
    public func setTTL(node: String, ttl: BigUInt, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.registryContract.method("setTTL", parameters: [nameHash, ttl] as [AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = password == nil ? transaction.send() : transaction.send(password: password!, options: options)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let value):
            return Result(value)
        }
    }
    
    @available(*, deprecated, message: "Don't use Web3Options")
    private func getOptions(_ options: Web3Options) -> Web3Options {
        var options = options
        options.to = self.ensContractAddress
        return options
    }
}

