//
//  ENS.swift
//  web3swift-iOS
//

import Foundation
import BigInt
import Result

public struct ENS {
    
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
    
    private lazy var registryContract: web3.web3contract = {
        let contract = self.web3.contract(Web3.Utils.ensRegistryABI, at: self.ensContractAddress, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()
    
    private lazy var defaultOptions: Web3Options = {
        return Web3Options.defaultOptions()
    }()
    
    //MARK: - Convenience methods
    public mutating func getAddress(_ domain: String) -> Result<EthereumAddress, Web3Error> {
        let resolver = self.resolver(forDomain: domain)
        switch resolver {
        case .success(var resolver):
            let isAddrSupports = resolver.supportsInterface(interfaceID: ResolverENS.InterfaceName.addr.hash())
            switch  isAddrSupports{
            case .success(let isSupported):
                if isSupported {
                    return resolver.addr(forDomain: domain)
                } else {
                    return Result.failure(Web3Error.dataError)
                }
            case .failure(let error):
                return Result.failure(error)
            }
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    
    public mutating func setAddress(domain: String, address: EthereumAddress, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error>{
        let resolver = self.resolver(forDomain: domain)
        switch resolver {
        case .success(var resolver):
            let isSetAddrSupported = resolver.supportsInterface(interfaceID: ResolverENS.InterfaceName.addr.hash())
            switch isSetAddrSupported {
            case .success(let value):
                if value {
                    return resolver.setAddr(node: domain, address: address, options: options, password: password)
                } else {
                    return Result.failure(Web3Error.dataError)
                }
            case .failure(let error):
                return Result.failure(error)
            }
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    public mutating func getPubkey(domain: String) -> Result<PublicKey, Web3Error> {
        let resolver = self.resolver(forDomain: domain)
        switch resolver {
        case .success(var resolver):
            let isPubkeySupports = resolver.supportsInterface(interfaceID: ResolverENS.InterfaceName.pubkey.hash())
            switch isPubkeySupports {
            case .success(let value):
                if value {
                    return resolver.pubkey(node: domain)
                } else {
                    return Result.failure(Web3Error.dataError)
                }
            case .failure(let error):
                return Result.failure(error)
            }
            
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    mutating public func setPubkey(domain: String, x: String, y: String, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
        let resolver = self.resolver(forDomain: domain)
        switch resolver {
        case .success(var value):
            return value.setPubkey(node: domain, x: x, y: y, options: options, password: password)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    mutating public func getContent(domain: String) -> Result<String, Web3Error> {
        let resolver = self.resolver(forDomain: domain)
        switch resolver {
        case .success(var value):
            return value.content(node: domain)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    public mutating func setContent(domain: String, hash: String, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
        let resolver = self.resolver(forDomain: domain)
        switch resolver {
        case .success(var value):
            return value.setContent(node: domain, hash: hash, options: options, password: password)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    
    public mutating func getMultihash(domain: String) -> Result<Data, Web3Error> {
        let resolver = self.resolver(forDomain: domain)
        switch resolver {
        case .success(var value):
            return value.multihash(node: domain)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    
    //MARK: - Returns resolver for the given domain
    mutating func resolver(forDomain domain: String) -> Result<ResolverENS, Web3Error> {
        guard let nameHash = NameHash.nameHash(domain) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.registryContract.method("resolver", parameters: [nameHash as AnyObject], options: defaultOptions) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = transaction.call(options: defaultOptions)
        switch result {
        case .success(let res):
            guard let resolverAddress = res["0"] as? EthereumAddress else { return Result.failure(Web3Error.dataError) }
            return Result(ResolverENS(web3: self.web3, resolverAddress: resolverAddress))
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    //Returns node's owner address
    mutating func owner(node: String) -> Result<EthereumAddress, Web3Error> {
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.registryContract.method("owner", parameters: [nameHash as AnyObject], options: defaultOptions) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = transaction.call(options: defaultOptions)
        switch result {
        case .success(let value):
            guard let address = value["0"] as? EthereumAddress else { return Result.failure(Web3Error.dataError) }
            return Result(address)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    //Untested
    mutating func ttl(node: String) -> Result<BigUInt, Web3Error> {
        guard let nameHash = NameHash.nameHash(node) else { return Result.failure(Web3Error.dataError) }
        guard let transaction = self.registryContract.method("ttl", parameters: [nameHash as AnyObject], options: defaultOptions) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = transaction.call(options: defaultOptions)
        switch result {
        case .success(let value):
            guard let ans = value["0"] as? BigUInt else { return Result.failure(Web3Error.dataError) }
            return Result(ans)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    //    function setOwner(bytes32 node, address owner);
    mutating func setOwner(node: String, owner: EthereumAddress, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
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
    mutating func setSubnodeOwner(node: String, label: String, owner: EthereumAddress, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
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
    mutating func setResolver(node: String, resolver: EthereumAddress, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
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
    mutating func setTTL(node: String, ttl: BigUInt, options: Web3Options, password: String? = nil) -> Result<TransactionSendingResult, Web3Error> {
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
    
    private func getOptions(_ options: Web3Options) -> Web3Options {
        var options = options
        options.to = self.ensContractAddress
        return options
    }
}

