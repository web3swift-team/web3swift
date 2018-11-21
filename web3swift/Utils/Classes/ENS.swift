//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import EthereumAddress

public class ENS {
    
    let web3: web3
    let ensContractAddress: EthereumAddress?
    
    init(web3: web3) {
        self.web3 = web3
        switch web3.provider.network {
        case .Mainnet?:
            ensContractAddress = EthereumAddress("0x314159265dd8dbb310642f98f50c066173c1259b")
        case .Rinkeby?:
            ensContractAddress = EthereumAddress("0xe7410170f87102df0055eb195163a03b7f2bff4a")
        case .Ropsten?:
            ensContractAddress = EthereumAddress("0x112234455c3a32fd11230c42e7bccd4a84e02010")
        default:
            ensContractAddress = nil
        }
    }
    
    lazy var registryContract: web3.web3contract = {
        let contract = self.web3.contract(Web3.Utils.ensRegistryABI, at: self.ensContractAddress, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()
    
    lazy var defaultOptions: TransactionOptions = {
        return TransactionOptions.defaultOptions
    }()
    
    //MARK: - Convenience methods
    public func getAddress(_ domain: String) throws -> EthereumAddress {
        guard var resolver = try? self.resolver(forDomain: domain) else {throw Web3Error.processingError(desc: "Failed to get resolver for domain")}
        guard let isAddrSupports = try? resolver.supportsInterface(interfaceID: ResolverENS.InterfaceName.addr.hash()) else {throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")}
        guard isAddrSupports else {throw Web3Error.processingError(desc: "Address isn't supported")}
        guard let addr = try? resolver.addr(forDomain: domain) else {throw Web3Error.processingError(desc: "Can't get address")}
        return addr
    }
    
    
    public func setAddress(domain: String, address: EthereumAddress, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        guard var resolver = try? self.resolver(forDomain: domain) else {throw Web3Error.processingError(desc: "Failed to get resolver for domain")}
        guard let isAddrSupports = try? resolver.supportsInterface(interfaceID: ResolverENS.InterfaceName.addr.hash()) else {throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")}
        guard isAddrSupports else {throw Web3Error.processingError(desc: "Address isn't supported")}
        guard let result = try? resolver.setAddr(node: domain, address: address, options: options, password: password) else {throw Web3Error.processingError(desc: "Can't get result")}
        return result
    }
    
    public func getPubkey(domain: String) throws -> PublicKey {
        guard var resolver = try? self.resolver(forDomain: domain) else {throw Web3Error.processingError(desc: "Failed to get resolver for domain")}
        guard let isPubkeySupports = try? resolver.supportsInterface(interfaceID: ResolverENS.InterfaceName.pubkey.hash()) else {throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")}
        guard isPubkeySupports else {throw Web3Error.processingError(desc: "Pubkey isn't supported")}
        guard let pubkey = try? resolver.pubkey(node: domain) else {throw Web3Error.processingError(desc: "Can't get pubkey")}
        return pubkey
    }
    
    public func setPubkey(domain: String, x: String, y: String, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        guard var resolver = try? self.resolver(forDomain: domain) else {throw Web3Error.processingError(desc: "Failed to get resolver for domain")}
        guard let result = try? resolver.setPubkey(node: domain, x: x, y: y, options: options, password: password) else {throw Web3Error.processingError(desc: "Can't get result")}
        return result
    }
    
    public func getContent(domain: String) throws -> String {
        guard var resolver = try? self.resolver(forDomain: domain) else {throw Web3Error.processingError(desc: "Failed to get resolver for domain")}
        guard let content = try? resolver.content(node: domain) else {throw Web3Error.processingError(desc: "Can't get content")}
        return content
    }
    
    public func setContent(domain: String, hash: String, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        guard var resolver = try? self.resolver(forDomain: domain) else {throw Web3Error.processingError(desc: "Failed to get resolver for domain")}
        guard let result = try? resolver.setContent(node: domain, hash: hash, options: options, password: password) else {throw Web3Error.processingError(desc: "Can't get result")}
        return result
    }
    
    public func getMultihash(domain: String) throws -> Data {
        guard var resolver = try? self.resolver(forDomain: domain) else {throw Web3Error.processingError(desc: "Failed to get resolver for domain")}
        guard let multihash = try? resolver.multihash(node: domain) else {throw Web3Error.processingError(desc: "Can't get multihash")}
        return multihash
    }
    
    
    //MARK: - Returns resolver for the given domain
    public func resolver(forDomain domain: String) throws -> ResolverENS {
        guard let nameHash = NameHash.nameHash(domain) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.registryContract.read("resolver", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let resolverAddress = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "No address in result")}
        return ResolverENS(web3: self.web3, resolverAddress: resolverAddress)
    }
    
    //Returns node's owner address
    public func owner(node: String) throws -> EthereumAddress {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.registryContract.read("owner", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let address = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "No address in result")}
        return address
    }
    
    //Untested
    public func ttl(node: String) throws -> BigUInt {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.registryContract.read("ttl", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let ans = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "No answer in result")}
        return ans
    }
    
    //    function setOwner(bytes32 node, address owner);
    public func setOwner(node: String, owner: EthereumAddress, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.registryContract.write("setOwner", parameters: [nameHash, owner] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    
    //    function setSubnodeOwner(bytes32 node, bytes32 label, address owner);
    public func setSubnodeOwner(node: String, label: String, owner: EthereumAddress, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let labelHash = NameHash.nameHash(label) else {throw Web3Error.processingError(desc: "Failed to get label hash")}
        guard let transaction = self.registryContract.write("setSubnodeOwner", parameters: [nameHash, labelHash, owner] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    
    //    function setResolver(bytes32 node, address resolver);
    public func setResolver(node: String, resolver: EthereumAddress, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.registryContract.write("setResolver", parameters: [nameHash, resolver] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    
    //    function setTTL(bytes32 node, uint64 ttl);
    public func setTTL(node: String, ttl: BigUInt, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.registryContract.write("setTTL", parameters: [nameHash, ttl] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    
    private func getOptions(_ options: TransactionOptions) -> TransactionOptions {
        var options = options
        options.to = self.ensContractAddress
        return options
    }
}

