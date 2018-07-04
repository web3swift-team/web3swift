
//  Web3+Contract.swift
//  web3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

extension web3 {
    
    public func contract(_ abiString: String, at: EthereumAddress? = nil, abiVersion: Int = 2) -> web3contract? {
        return web3contract(web3: self, abiString: abiString, at: at, options: self.options, abiVersion: abiVersion)
    }
    
    public class web3contract {
        var contract: ContractProtocol
        var web3 : web3
        public var options: Web3Options? = nil
        
        public init?(web3 web3Instance:web3, abiString: String, at: EthereumAddress? = nil, options: Web3Options? = nil, abiVersion: Int = 2) {
            self.web3 = web3Instance
            self.options = web3.options
            switch abiVersion {
            case 1:
                print("ABIv1 bound contract is now deprecated")
                return nil
            case 2:
                guard let c = ContractV2(abiString, at: at) else {return nil}
                contract = c
            default:
                return nil
            }
            var mergedOptions = Web3Options.merge(self.options, with: options)
            if at != nil {
                contract.address = at
                mergedOptions?.to = at
            } else if let addr = mergedOptions?.to {
                contract.address = addr
            }
            self.options = mergedOptions
        }
        
        public func deploy(bytecode: Data, parameters: [AnyObject] = [AnyObject](), extraData: Data = Data(), options: Web3Options?) -> TransactionIntermediate? {
            
            let mergedOptions = Web3Options.merge(self.options, with: options)
            guard var tx = self.contract.deploy(bytecode: bytecode, parameters: parameters, extraData: extraData, options: mergedOptions) else {return nil}
            tx.chainID = self.web3.provider.network?.chainID
            let intermediate = TransactionIntermediate(transaction: tx, web3: self.web3, contract: self.contract, method: "fallback", options: mergedOptions)
            return intermediate
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
        
        public func createEventParser(_ eventName:String, filter:EventFilter?) -> EventParserProtocol? {
            let parser = EventParser(web3: self.web3, eventName: eventName, contract: self.contract, filter: filter)
            return parser
        }
    }
}
