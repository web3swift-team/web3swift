
//  Web3+Contract.swift
//  web3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
import BigInt
import AwaitKit

extension web3 {
    
    public func contract(_ abiString: String, at: EthereumAddress? = nil) -> web3contract? {
        return web3contract(self.provider, abiString: abiString, at: at)
    }
    
    public struct web3contract {
        var contract: Contract
        var provider: Web3Provider
        public var options: Web3Options? = Web3Options.defaultOptions()
        
        public init?(_ provider: Web3Provider, abiString: String, at: EthereumAddress? = nil, options: Web3Options? = nil) {
            do {
                self.provider = provider
                let jsonData = abiString.data(using: .utf8)
                let abi = try JSONDecoder().decode([ABIRecord].self, from: jsonData!)
                let abiNative = try abi.map({ (record) -> ABIElement in
                    return try record.parse()
                })
                var mergedOptions = Web3Options.merge(self.options, with: options)
                contract = Contract(abi: abiNative)
                if at != nil {
                    contract.address = at
                    mergedOptions?.to = at
                } else if let addr = mergedOptions?.to {
                    contract.address = addr
                }
                self.options = mergedOptions
                if contract.address == nil {
                    return nil
                }
            }
            catch{
                print(error)
                return nil
            }
        }
        
        public struct transactionIntermediate{
            public var transaction:EthereumTransaction
            public var provider: Web3Provider
            public var contract: Contract
            public var method: String
            public var options: Web3Options? = Web3Options.defaultOptions()
            
            public init (transaction: EthereumTransaction, provider: Web3Provider, contract: Contract, method: String, options: Web3Options?) {
                self.transaction = transaction
                self.provider = provider
                self.contract = contract
                self.contract.options = options
                self.method = method
                self.options = options
            }
            
            public mutating func setNonce(_ nonce: BigUInt, network: Networks? = nil) throws {
                self.transaction.nonce = nonce
                if (network != nil) {
                    self.transaction.chainID = network?.chainID
                }
            }
            
            public mutating func sign(_ privateKey: Data, network: Networks? = nil) throws {
                if (network != nil) {
                    self.transaction.chainID = network?.chainID
                }
                let _ = self.transaction.sign(privateKey: privateKey)
            }
            
            public func send(network: Networks = .Mainnet) -> Promise<[String:Any]?> {
                return async {
                    print(self.transaction)
                    let res = try await(self.provider.send(transaction: self.transaction, network: network))
                    if res == nil {
                        return nil
                    }
                    let hash = res?.toHexString().addHexPrefix().lowercased()
                    return ["txhash": hash as Any, "txhashCalculated" : self.transaction.txhash as Any]
                    
                }
            }
            public func call(options: Web3Options?, network: Networks = .Mainnet) -> Promise<[String:Any]?> {
                return async {
                    let mergedOptions = Web3Options.merge(self.options, with: options)
                    let res = try await(self.provider.call(transaction: self.transaction, options: mergedOptions, network: network))
                    if res == nil {
                        return nil
                    }
                    if (self.method == "fallback") {
                        let resultAsBigUInt = BigUInt(res!)
                        return ["result": resultAsBigUInt as Any]
                    }
                    let foundMethod = self.contract.methods.filter { (key, value) -> Bool in
                        return key == self.method
                    }
                    guard foundMethod.count == 1 else {return nil}
                    let abiMethod = foundMethod[self.method]
                    guard let decodedData = abiMethod?.decodeReturnData(res!) else {return nil}
                    return decodedData
                }
            }
            public func estimateGas(options: Web3Options?, network: Networks = .Mainnet) -> Promise<BigUInt?> {
                return async {
                    let mergedOptions = Web3Options.merge(self.options, with: options)
                    let res = try await(self.provider.estimateGas(transaction: self.transaction, options: mergedOptions, network: network))
                    if res == nil {
                        return nil
                    }
                    let gas = BigUInt(res!)
                    return gas
                }
            }
        }
        
        public func method(_ method:String = "fallback", parameters: [AnyObject] = [AnyObject](), nonce: BigUInt = BigUInt(0), extraData:Data = Data(), options: Web3Options?) -> transactionIntermediate? {
            
            let mergedOptions = Web3Options.merge(self.options, with: options)
            
            guard let tx = self.contract.method(method, parameters: parameters, nonce: nonce, extraData:extraData, options: mergedOptions, toAddress:self.contract.address) else {return nil}
            let intermediate = transactionIntermediate(transaction: tx, provider: self.provider, contract: self.contract, method: method, options: mergedOptions)
            return intermediate
        }
    }
}
