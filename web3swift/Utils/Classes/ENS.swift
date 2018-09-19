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
    
    
    //MARK: - Returns resolver for the given domain
    mutating func resolver(forDomain domain: String) -> Result<ResolverENS, Web3Error> {
        guard let nameHash = NameHash.nameHash(domain) else { return Result.failure(Web3Error.dataError) }
        let options = Web3Options.defaultOptions()
        guard let transaction = self.registryContract.method("resolver", parameters: [nameHash as AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = transaction.call(options: options)
        switch result {
        case .success(let res):
            guard let resolverAddress = res["0"] as? EthereumAddress else { return Result.failure(Web3Error.dataError) }
            return Result(ResolverENS(web3: self.web3, resolverAddress: resolverAddress))
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    public mutating func getAddress(_ domain: String) -> Result<EthereumAddress, Web3Error> {
        let resolver = self.resolver(forDomain: domain)
        switch resolver {
        case .success(var resolver):
            let isAddrSupports = resolver.supportsInterface(interfaceID: ResolverENS.InterfaceName.addr.hash())
            switch  isAddrSupports{
            case .success(let isSupported):
                if isSupported {
                    let result = resolver.addr(forDomain: domain)
                    switch result {
                    case .success(let address):
                        return Result(address)
                    case .failure(let error):
                        return Result.failure(error)
                    }
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
    
    /*
        TODO: -
    */
//
//    public func setAddress(domain: String, address: EthereumAddress, options: Web3Options? = nil) {
//
//    }
//
//    public func getPubkey(domain: String) -> Result<[String: String], Web3Error> {
//
//    }
//
//    public func setPubkey(domain: String, x: String, y: String, options: Web3Options? = nil) {
//
//    }
//
//    public func getContent(domain: String) -> Result<String, Web3Error> {
//
//    }
//
//    public func setContent(domain: String, hash: String, optioins: Web3Options? = nil) {
//
//    }
//
//    public func getMultihash(domain: String) -> String {
//        
//    }
}

public struct ResolverENS {
    let web3: web3
    let resolverAddress: EthereumAddress
    
    public enum InterfaceName {
        case addr
        case name
        case ABI
        case pubkey
        
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
            }
        }
    }
    
    private lazy var resolverContract: web3.web3contract = {
        let contract = self.web3.contract(Web3.Utils.resolverABI, at: self.resolverAddress, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()
    
    init(web3: web3, resolverAddress: EthereumAddress) {
        self.web3 = web3
        self.resolverAddress = resolverAddress
    }
    
    mutating func supportsInterface(interfaceID: Data) -> Result<Bool, Web3Error> {
        return supportsInterface(interfaceID: interfaceID.toHexString())
    }
    
    //MARK: - returns true if the contract supports given interface
    mutating func supportsInterface(interfaceID: String) -> Result<Bool, Web3Error> {
        let options = Web3Options.defaultOptions()
        guard let transaction = self.resolverContract.method("supportsInterface", parameters: [interfaceID as AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = transaction.call(options: options)
        switch result {
        case .success(let res):
            guard let supports = res["0"] as? Bool else { return Result.failure(Web3Error.dataError) }
            return Result(supports)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    //MARK: - returns address for the given domain at given resolver
    mutating func addr(forDomain domain: String) -> Result<EthereumAddress, Web3Error> {
        guard let nameHash = NameHash.nameHash(domain) else { return Result.failure(Web3Error.dataError) }
        let options = Web3Options.defaultOptions()
        guard let transaction = self.resolverContract.method("addr", parameters: [nameHash as AnyObject], options: options) else  { return Result.failure(Web3Error.dataError) }
        let result = transaction.call(options: options)
        switch result {
        case .success(let res):
            return Result(res["0"] as! EthereumAddress)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    //MARK: - returns corresponding ENS to the requested node
    mutating func name(node: String) -> Result<String, Web3Error> {
        let options = Web3Options.defaultOptions()
        guard let transaction = self.resolverContract.method("name", parameters: [node.lowercased() as AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError)}
        let result = transaction.call(options: options)
        switch result {
        case .success(let res):
            return Result(res["0"] as! String)
        case .failure(let error):
            return Result.failure(error)
        }
        
    }
    
    //MARK: - returns ABI in the requested encodings
    mutating func ABI(node: String, contentType: BigUInt) -> Result<(BigUInt, Data), Web3Error> {
        let options = Web3Options.defaultOptions()
        guard let transaction = self.resolverContract.method("ABI", parameters: [node, contentType] as [AnyObject], options: options) else { return Result.failure(Web3Error.transactionSerializationError) }
        let result = transaction.call(options: options)
        switch result {
        case .success(let res):
            guard let encoding = res["0"] as? BigUInt else { return Result.failure(Web3Error.dataError) }
            guard let data = res["1"] as? Data else { return Result.failure(Web3Error.dataError) }
            return Result((encoding, data))
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    //TODO: - func pubkey()
}

