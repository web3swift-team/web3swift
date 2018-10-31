//
//  Web3+ERC721.swift
//  web3swift-iOS
//
//  Created by Anton Grigorev on 17.10.2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import Result
import EthereumAddress

// This namespace contains functions to work with ERC721 tokens.
// can be imperatively read and saved
public class ERC721 {
    private var _name: String? = nil
    private var _symbol: String? = nil
    private var _tokenId: BigUInt? = nil
    private var _tokenURI: String? = nil
    private var _hasReadProperties: Bool = false
    
    public var options: Web3Options
    public var web3: web3
    public var provider: Web3Provider
    public var address: EthereumAddress
    
    lazy var contract: web3.web3contract = {
        let contract = self.web3.contract(Web3.Utils.erc721ABI, at: self.address, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()
    
    public init(web3: web3, provider: Web3Provider, address: EthereumAddress) {
        self.web3 = web3
        self.provider = provider
        self.address = address
        var mergedOptions = web3.options
        mergedOptions.to = address
        self.options = mergedOptions
    }
    
    public var name: String {
        self.readProperties()
        if self._name != nil {
            return self._name!
        }
        return ""
    }
    
    public var symbol: String {
        self.readProperties()
        if self._symbol != nil {
            return self._symbol!
        }
        return ""
    }
    
    public var tokenId: BigUInt {
        self.readProperties()
        if self._tokenId != nil {
            return self._tokenId!
        }
        return 0
    }
    
    public var tokenURI: String {
        self.readProperties()
        if self._tokenURI != nil {
            return self._tokenURI!
        }
        return ""
    }
    
    public func readProperties() {
        if self._hasReadProperties {
            return
        }
        defer { self._hasReadProperties = true }
        let contract = self.contract
        guard contract.contract.address != nil else {return}
        guard let nameResult = contract.method("name", parameters: [] as [AnyObject], extraData: Data(), options: self.options)?.call(options: nil, onBlock: "latest") else {return}
        switch nameResult {
        case .success(let returned):
            guard let res = returned["0"] as? String else {break}
            self._name = res
        default:
            self._name = ""
        }
        
        guard let symbol = contract.method("symbol", parameters: [] as [AnyObject], extraData: Data(), options: self.options)?.call(options: nil, onBlock: "latest") else {return}
        switch symbol {
        case .success(let returned):
            guard let res = returned["0"] as? String else {break}
            self._symbol = res
        default:
            self._symbol = ""
        }
        
        guard let tokenId = contract.method("tokenId", parameters: [] as [AnyObject], extraData: Data(), options: self.options)?.call(options: nil, onBlock: "latest") else {return}
        switch tokenId {
        case .success(let returned):
            guard let res = returned["0"] as? BigUInt else {break}
            self._tokenId = res
        default:
            self._tokenId = 0
        }
        
        guard let tokenURI = contract.method("tokenURI", parameters: [_tokenId] as [AnyObject], extraData: Data(), options: self.options)?.call(options: nil, onBlock: "latest") else {return}
        switch tokenURI {
        case .success(let returned):
            guard let res = returned["0"] as? String else {return}
            self._tokenURI = res
        default:
            self._tokenURI = ""
        }
    }
    
    public func getBalance(account: EthereumAddress) -> Result<BigUInt, Web3Error> {
        let contract = self.contract
        let result = contract.method("balanceOf", parameters: [account] as [AnyObject], extraData: Data(), options: self.options)!.call(options: nil, onBlock: "latest")
        switch result {
        case .success(let returned):
            guard let res = returned["0"] as? BigUInt else {return Result.failure(Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node"))}
            return Result(res)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    public func getOwner(tokenId: BigUInt) -> Result<EthereumAddress, Web3Error> {
        let contract = self.contract
        let result = contract.method("ownerOf", parameters: [tokenId] as [AnyObject], extraData: Data(), options: self.options)!.call(options: nil, onBlock: "latest")
        switch result {
        case .success(let returned):
            guard let res = returned["0"] as? EthereumAddress else {return Result.failure(Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node"))}
            return Result(res)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    public func getApproved(tokenId: BigUInt) -> Result<EthereumAddress, Web3Error> {
        let contract = self.contract
        let result = contract.method("getApproved", parameters: [tokenId] as [AnyObject], extraData: Data(), options: self.options)!.call(options: nil, onBlock: "latest")
        switch result {
        case .success(let returned):
            guard let res = returned["0"] as? EthereumAddress else {return Result.failure(Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node"))}
            return Result(res)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    public func tokenByIndex(index: BigUInt) -> Result<BigUInt, Web3Error> {
        let contract = self.contract
        let result = contract.method("tokenByIndex", parameters: [index] as [AnyObject], extraData: Data(), options: self.options)!.call(options: nil, onBlock: "latest")
        switch result {
        case .success(let returned):
            guard let res = returned["0"] as? BigUInt else {return Result.failure(Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node"))}
            return Result(res)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    public func tokenOfOwnerByIndex(owner: EthereumAddress, index: BigUInt) -> Result<BigUInt, Web3Error> {
        let contract = self.contract
        let result = contract.method("tokenOfOwnerByIndex", parameters: [owner, index] as [AnyObject], extraData: Data(), options: self.options)!.call(options: nil, onBlock: "latest")
        switch result {
        case .success(let returned):
            guard let res = returned["0"] as? BigUInt else {return Result.failure(Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node"))}
            return Result(res)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    public func transfer(from: EthereumAddress, to: EthereumAddress, tokenId: BigUInt) -> Result<TransactionIntermediate, Web3Error> {
        let contract = self.contract
        var basicOptions = Web3Options()
        basicOptions.from = from
        basicOptions.to = self.address
        
        let intermediateToSend = contract.method("transfer", parameters: [to, tokenId] as [AnyObject], options: basicOptions)!
        return Result(intermediateToSend)
    }
    
    public func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt) -> Result<TransactionIntermediate, Web3Error> {
        let contract = self.contract
        var basicOptions = Web3Options()
        basicOptions.from = from
        basicOptions.to = self.address
        
        let intermediateToSend = contract.method("transferFrom", parameters: [originalOwner, to, tokenId] as [AnyObject], options: basicOptions)!
        return Result(intermediateToSend)
    }
    
}
