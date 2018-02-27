
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
        
        public func method(_ method:String = "fallback", parameters: [AnyObject] = [AnyObject](), extraData: Data = Data(), options: Web3Options?) -> TransactionIntermediate? {
            
            let mergedOptions = Web3Options.merge(self.options, with: options)
            guard var tx = self.contract.method(method, parameters: parameters, extraData: extraData, options: mergedOptions) else {return nil}
            tx.chainID = self.web3.provider.network?.chainID
            let intermediate = TransactionIntermediate(transaction: tx, web3: self.web3, contract: self.contract, method: method, options: mergedOptions)
            return intermediate
        }
        
        public func parseEvent(_ eventLog: EventLog) -> (eventName:String?, eventData:[String:Any]?) {
            return self.contract.parseEvent(eventLog)
        }
        
        
    
    }
}
