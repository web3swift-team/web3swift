//
//  Web3+ERC1155.swift
//  web3swift-iOS
//
//  Created by Anton Grigorev on 20/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit
//import EthereumAddress

//Multi Token Standard
protocol IERC1155: IERC165 {
    
    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, id: BigUInt, value: BigUInt, data: [UInt8]) throws -> WriteTransaction
    
    func safeBatchTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, ids: [BigUInt], values: [BigUInt], data: [UInt8]) throws -> WriteTransaction
    
    func balanceOf(account: EthereumAddress, id: BigUInt) throws -> BigUInt
    
    func setApprovalForAll(from: EthereumAddress, operator user: EthereumAddress, approved: Bool, scope: Data) throws -> WriteTransaction
    
    func isApprovedForAll(owner: EthereumAddress, operator user: EthereumAddress, scope: Data) throws -> Bool
}

protocol IERC1155Metadata {
    func uri(id: BigUInt) throws -> String
    func name(id: BigUInt) throws -> String
}

public class ERC1155: IERC1155 {
    
    private var _tokenId: BigUInt? = nil
    private var _hasReadProperties: Bool = false
    
    public var transactionOptions: TransactionOptions
    public var web3: web3
    public var provider: Web3Provider
    public var address: EthereumAddress
    public var abi: String
    
    lazy var contract: web3.web3contract = {
        let contract = self.web3.contract(self.abi, at: self.address, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()
    
    public init(web3: web3, provider: Web3Provider, address: EthereumAddress, abi: String = Web3.Utils.erc1155ABI) {
        self.web3 = web3
        self.provider = provider
        self.address = address
        var mergedOptions = web3.transactionOptions
        mergedOptions.to = address
        self.abi = abi
        self.transactionOptions = mergedOptions
    }
    
    public var tokenId: BigUInt {
        self.readProperties()
        if self._tokenId != nil {
            return self._tokenId!
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
        
        guard let tokenIdPromise = contract.read("id", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)?.callPromise() else {return}
        
        let allPromises = [tokenIdPromise]
        let queue = self.web3.requestDispatcher.queue
        when(resolved: allPromises).map(on: queue) { (resolvedPromises) -> Void in
            guard case .fulfilled(let tokenIdResult) = resolvedPromises[0] else {return}
            guard let tokenId = tokenIdResult["0"] as? BigUInt else {return}
            self._tokenId = tokenId
            
            self._hasReadProperties = true
            }.wait()
    }
    
    func safeTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, id: BigUInt, value: BigUInt, data: [UInt8]) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        
        let tx = contract.write("safeTransferFrom", parameters: [originalOwner, to, id, value, data] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    func safeBatchTransferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, ids: [BigUInt], values: [BigUInt], data: [UInt8]) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        
        let tx = contract.write("safeBatchTransferFrom", parameters: [originalOwner, to, ids, values, data] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    func balanceOf(account: EthereumAddress, id: BigUInt) throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("balanceOf", parameters: [account, id] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
    
    func setApprovalForAll(from: EthereumAddress, operator user: EthereumAddress, approved: Bool, scope: Data) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        
        let tx = contract.write("setApprovalForAll", parameters: [user, approved, scope] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    func isApprovedForAll(owner: EthereumAddress, operator user: EthereumAddress, scope: Data) throws -> Bool {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.callOnBlock = .latest
        let result = try contract.read("isApprovedForAll", parameters: [owner, user, scope] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
    
    func supportsInterface(interfaceID: String) throws -> Bool {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        transactionOptions.gasLimit = .manual(30000)
        let result = try contract.read("supportsInterface", parameters: [interfaceID] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
}
