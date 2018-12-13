//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit
import EthereumAddress

protocol IERC721 {
    
    func getBalance(account: EthereumAddress) throws -> BigUInt
    
    func getOwner(tokenId: BigUInt) throws -> EthereumAddress
    
    func tokenByIndex(index: BigUInt) throws -> BigUInt

    func tokenOfOwnerByIndex(owner: EthereumAddress, index: BigUInt) throws -> BigUInt
    
    func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt) throws -> WriteTransaction
    
    func transfer(from: EthereumAddress, to: EthereumAddress, tokenId: BigUInt) throws -> WriteTransaction
    
    func approve(approved: EthereumAddress, tokenId: BigUInt) throws -> WriteTransaction
    
    func setApprovalForAll(operator address: EthereumAddress, approved: Bool) throws -> WriteTransaction
    
    func getApproved(tokenId: BigUInt) throws -> EthereumAddress
    
    func isApprovedForAll(operator address: EthereumAddress, approved: Bool) throws -> Bool
}

// This namespace contains functions to work with ERC721 tokens.
// can be imperatively read and saved
public class ERC721: IERC721 {
    
    @available(*, deprecated, renamed: "transactionOptions")
    public var options: Web3Options = .init()
    
    private var _name: String? = nil
    private var _symbol: String? = nil
    private var _tokenId: BigUInt? = nil
    private var _tokenURI: String? = nil
    private var _totalSupply: BigUInt? = nil
    private var _hasReadProperties: Bool = false
    
    public var transactionOptions: TransactionOptions
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
        var mergedOptions = web3.transactionOptions
        mergedOptions.to = address
        self.transactionOptions = mergedOptions
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
    
    public var totalSupply: BigUInt {
        self.readProperties()
        if self._totalSupply != nil {
            return self._totalSupply!
        }
        return 0
    }
    
    public func readProperties() {
        if self._hasReadProperties {
            return
        }
        let contract = self.contract
        guard contract.contract.address != nil else {return}
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.callOnBlock = .latest
        guard let namePromise = contract.read("name", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)?.callPromise() else {return}
        
        guard let symbolPromise = contract.read("symbol", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)?.callPromise() else {return}
        
        guard let tokenIdPromise = contract.read("tokenId", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)?.callPromise() else {return}
        
        guard let tokenURIpromise = contract.read("tokenURI", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)?.callPromise() else {return}
        
        guard let totalSupplyPromise = contract.read("totalSupply", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)?.callPromise() else {return}
        
        let allPromises = [namePromise, symbolPromise, tokenIdPromise, tokenURIpromise, totalSupplyPromise]
        let queue = self.web3.requestDispatcher.queue
        when(resolved: allPromises).map(on: queue) { (resolvedPromises) -> Void in
            guard case .fulfilled(let nameResult) = resolvedPromises[0] else {return}
            guard let name = nameResult["0"] as? String else {return}
            self._name = name
            
            guard case .fulfilled(let symbolResult) = resolvedPromises[1] else {return}
            guard let symbol = symbolResult["0"] as? String else {return}
            self._symbol = symbol
            
            guard case .fulfilled(let tokenIdResult) = resolvedPromises[2] else {return}
            guard let tokenId = tokenIdResult["0"] as? BigUInt else {return}
            self._tokenId = tokenId
            
            guard case .fulfilled(let tokenURIresult) = resolvedPromises[3] else {return}
            guard let uri = tokenURIresult["0"] as? String else {return}
            self._tokenURI = uri
            
            guard case .fulfilled(let totalSupplyResult) = resolvedPromises[4] else {return}
            guard let totalSupply = totalSupplyResult["0"] as? BigUInt else {return}
            self._totalSupply = totalSupply
            
            self._hasReadProperties = true
            }.wait()
    }
    
    public func getBalance(account: EthereumAddress) throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("balanceOf", parameters: [account] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
    
    public func getOwner(tokenId: BigUInt) throws -> EthereumAddress {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("ownerOf", parameters: [tokenId] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
    
    public func getApproved(tokenId: BigUInt) throws -> EthereumAddress {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("getApproved", parameters: [tokenId] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
    
    public func tokenByIndex(index: BigUInt) throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("tokenByIndex", parameters: [index] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
    
    public func tokenOfOwnerByIndex(owner: EthereumAddress, index: BigUInt) throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("tokenOfOwnerByIndex", parameters: [owner, index] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
    
    public func transfer(from: EthereumAddress, to: EthereumAddress, tokenId: BigUInt) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        
        let tx = contract.write("transfer", parameters: [to, tokenId] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    public func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, tokenId: BigUInt) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        
        let tx = contract.write("transferFrom", parameters: [originalOwner, to, tokenId] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    public func approve(from: EthereumAddress, approved: EthereumAddress, tokenId: BigUInt) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        
        let tx = contract.write("approve", parameters: [approved, tokenId] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    public func setApprovalForAll(operator address: EthereumAddress, from: EthereumAddress, approved: Bool) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        
        let tx = contract.write("setApprovalForAll", parameters: [address, approved] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    public func isApprovedForAll(operator address: EthereumAddress, approved: Bool) throws -> Bool {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.callOnBlock = .latest
        let result = try contract.read("setApprovalForAll", parameters: [address, approved] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
}
