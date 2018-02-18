
//  Web3+Contract.swift
//  web3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import Alamofire
import BigInt

extension web3 {
    
    public func contract(_ abiString: String, at: EthereumAddress? = nil) -> web3contract? {
        return web3contract(web3: self, abiString: abiString, at: at, options: self.options)
    }
    
    public class web3contract {
        var contract: Contract
        var web3 : web3
        public var options: Web3Options? = nil
        
        public init?(web3 web3Instance:web3, abiString: String, at: EthereumAddress? = nil, options: Web3Options? = nil) {
            do {
                self.web3 = web3Instance
                self.options = web3.options
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
        
        public func method(_ method:String = "fallback", parameters: [AnyObject] = [AnyObject](), nonce: BigUInt = BigUInt(0), extraData: Data = Data(), options: Web3Options?) -> TransactionIntermediate? {
            
            let mergedOptions = Web3Options.merge(self.options, with: options)
            guard let tx = self.contract.method(method, parameters: parameters, nonce: nonce, extraData: extraData, options: mergedOptions) else {return nil}
            let intermediate = TransactionIntermediate(transaction: tx, web3: self.web3, contract: self.contract, method: method, options: mergedOptions)
            return intermediate
        }
        
        public func parseEvent(_ eventLog: EventLog) -> (eventName:String?, eventData:[String:Any]?) {
            return self.contract.parseEvent(eventLog)
        }
        
        public class TransactionIntermediate{
            public var transaction:EthereumTransaction
            public var contract: Contract
            public var method: String
            public var options: Web3Options? = Web3Options.defaultOptions()
            var web3: web3
            public init (transaction: EthereumTransaction, web3 web3Instance: web3, contract: Contract, method: String, options: Web3Options?) {
                self.transaction = transaction
                self.web3 = web3Instance
                self.contract = contract
                self.contract.options = options
                self.method = method
                self.options = Web3Options.merge(web3.options, with: options)
            }
            
            public func setNonce(_ nonce: BigUInt, network: Networks? = nil) throws {
                self.transaction.nonce = nonce
                if (network != nil) {
                    self.transaction.chainID = network?.chainID
                } else if (self.web3.provider.network != nil) {
                    self.transaction.chainID = self.web3.provider.network?.chainID
                }
            }
            
            public func sign(_ privateKey: Data, network: Networks? = nil) throws {
                if (network != nil) {
                    self.transaction.chainID = network?.chainID
                } else if (self.web3.provider.network != nil) {
                    self.transaction.chainID = self.web3.provider.network?.chainID
                }
                let _ = self.transaction.sign(privateKey: privateKey)
            }
            
            public func send(password: String = "BANKEXFOUNDATION", options: Web3Options? = nil) -> [String:Any]? {
                do {
                    guard var mergedOptions = Web3Options.merge(self.options, with: options) else {return nil}
                    guard let from = mergedOptions.from else {return nil}
                    guard let nonce = self.web3.eth.getTransactionCount(address: from, onBlock: "pending") else {return nil}
                    try self.setNonce(nonce, network: self.web3.provider.network)
                    if options?.gas == nil {
                        guard let estimatedGas = self.estimateGas(options: self.options) else {return nil}
                        mergedOptions.gas = estimatedGas
                    }
                    self.options = mergedOptions
                    guard let keystoreManager = self.web3.provider.attachedKeystoreManager else {return nil}
                    try keystoreManager.signIntermediate(intermediate: self, password: password, account: from)
                    print(self.transaction)
                    guard let request = EthereumTransaction.createRawTransaction(transaction: self.transaction) else {return nil}
                    let response = self.web3.provider.sendSync(request: request)
                    if response == nil {
                        return nil
                    }
                    guard let res = response else {return nil}
                    if let error = res["error"] as? String {
                        print(error as String)
                        return nil
                    }
                    guard let resultString = res["result"] as? String else {return nil}
                    let hash = resultString.addHexPrefix().lowercased()
                    return ["txhash": hash as Any, "txhashCalculated" : self.transaction.txhash as Any]
                }
                catch {
                    return nil
                }
            }
            
            public func sendSigned() -> [String:Any]? {
                print(self.transaction)
                guard let request = EthereumTransaction.createRawTransaction(transaction: self.transaction) else {return nil}
                let response = self.web3.provider.sendSync(request: request)
                if response == nil {
                    return nil
                }
                guard let res = response else {return nil}
                if let error = res["error"] as? String {
                    print(error as String)
                    return nil
                }
                guard let resultString = res["result"] as? String else {return nil}
                let hash = resultString.addHexPrefix().lowercased()
                return ["txhash": hash as Any, "txhashCalculated" : self.transaction.txhash as Any]
            }
            
            
            public func call(options: Web3Options?, onBlock: String = "latest") -> [String:Any]? {
                let mergedOptions = Web3Options.merge(self.options, with: options)
                guard let request = EthereumTransaction.createRequest(method: JSONRPCmethod.call, transaction: self.transaction, onBlock: onBlock, options: mergedOptions) else {return nil}
                let response = self.web3.provider.sendSync(request: request)
                if response == nil {
                    return nil
                }
                guard let res = response else {return nil}
                if let error = res["error"] as? String {
                    print(error as String)
                    return nil
                }
                guard let resultString = res["result"] as? String else {return nil}
                if (self.method == "fallback") {
                    let resultAsBigUInt = BigUInt(resultString.stripHexPrefix(), radix : 16)
                    return ["result": resultAsBigUInt as Any]
                }
                let foundMethod = self.contract.methods.filter { (key, value) -> Bool in
                    return key == self.method
                }
                guard foundMethod.count == 1 else {return nil}
                let abiMethod = foundMethod[self.method]
                let responseData = Data(Array<UInt8>(hex: resultString.lowercased().stripHexPrefix()))
                guard responseData != Data() else {return nil}
                guard let decodedData = abiMethod?.decodeReturnData(responseData) else {return nil}
                return decodedData
            }
        
            public func estimateGas(options: Web3Options?) -> BigUInt? {
                let mergedOptions = Web3Options.merge(self.options, with: options)
                guard let request = EthereumTransaction.createRequest(method: JSONRPCmethod.estimateGas, transaction: self.transaction, onBlock: nil, options: mergedOptions) else {return nil}
                let response = self.web3.provider.sendSync(request: request)
                if response == nil {
                    return nil
                }
                guard let res = response else {return nil}
                if let error = res["error"] as? String {
                    print(error as String)
                    return nil
                }
                guard let resultString = res["result"] as? String else {return nil}
                let gas = BigUInt(resultString.stripHexPrefix().lowercased(), radix: 16)
                return gas
            }
        }
    
    }
}
