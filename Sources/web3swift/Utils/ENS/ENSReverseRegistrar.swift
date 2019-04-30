//
//  ENSReverseRegistrar.swift
//  web3swift
//
//  Created by Anton on 20/04/2019.
//  Copyright © 2019 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
//import EthereumAddress

public extension ENS {
    class ReverseRegistrar {
        public let web3: web3
        public let address: EthereumAddress
        
        lazy var contract: web3.web3contract = {
            let contract = self.web3.contract(Web3.Utils.reverseRegistrarABI, at: self.address, abiVersion: 2)
            precondition(contract != nil)
            return contract!
        }()
        
        lazy var defaultOptions: TransactionOptions = {
            return TransactionOptions.defaultOptions
        }()
        
        public init(web3: web3, address: EthereumAddress) {
            self.web3 = web3
            self.address = address
        }
        
        public func claimAddress(from: EthereumAddress, owner: EthereumAddress) throws -> WriteTransaction {
            defaultOptions.from = from
            defaultOptions.to = self.address
            guard let transaction = self.contract.write("claim", parameters: [owner as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            return transaction
        }
        
        public func claimAddressWithResolver(from: EthereumAddress, owner: EthereumAddress, resolver: EthereumAddress) throws -> WriteTransaction {
            defaultOptions.from = from
            defaultOptions.to = self.address
            guard let transaction = self.contract.write("claimWithResolver", parameters: [owner, resolver] as [AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            return transaction
        }
        
        public func setName(from: EthereumAddress, name: String) throws -> WriteTransaction {
            defaultOptions.from = from
            defaultOptions.to = self.address
            guard let transaction = self.contract.write("setName", parameters: [name] as [AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            return transaction
        }
        
        public func getReverseRecordName(address: EthereumAddress) throws -> Data {
            guard let transaction = self.contract.read("node", parameters: [address] as [AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let name = result["0"] as? Data else {throw Web3Error.processingError(desc: "Can't get answer")}
            return name
        }
        
        public func getDefaultResolver() throws -> EthereumAddress {
            guard let transaction = self.contract.read("defaultResolver", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
            guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
            guard let address = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Can't get answer")}
            return address
        }
    }
}
