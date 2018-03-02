//
//  Contract.swift
//  web3swift
//
//  Created by Alexander Vlasov on 10.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

public struct Contract {
    var address: EthereumAddress? = nil
    var _abi: [ABIElement]
    var methods: [String: ABIElement] {
        var toReturn = [String: ABIElement]()
        for m in self._abi {
            switch m {
            case .function(let function):
                guard let name = function.name else {continue}
                toReturn[name] = m
            default:
                continue
            }
        }
        return toReturn
    }
    var events: [String: ABIElement] {
        var toReturn = [String: ABIElement]()
        for m in self._abi {
            switch m {
            case .event(let event):
                let name = event.name
                toReturn[name] = m
            default:
                continue
            }
        }
        return toReturn
    }
    
    var options: Web3Options? = Web3Options.defaultOptions()
    
    public init(abi: [ABIElement]) {
        _abi = abi
    }
    
    public init(abi: [ABIElement], at: EthereumAddress) {
        _abi = abi
        address = at
    }
    
    
    public func method(_ method:String = "fallback", parameters: [AnyObject] = [AnyObject](), extraData: Data = Data(), options: Web3Options?) -> EthereumTransaction? {
        var to:EthereumAddress
        let mergedOptions = Web3Options.merge(self.options, with: options)
        if (self.address != nil) {
            to = self.address!
        } else if let toFound = mergedOptions?.to, toFound.isValid {
            to = toFound
        } else  {
            return nil
        }
        
        var gasLimit:BigUInt
        if let gasInOptions = mergedOptions?.gasLimit {
            gasLimit = gasInOptions
        } else {
            return nil
        }
        
        var gasPrice:BigUInt
        if let gasPriceInOptions = mergedOptions?.gasPrice {
            gasPrice = gasPriceInOptions
        } else {
            return nil
        }
        
        var value:BigUInt
        if let valueInOptions = mergedOptions?.value {
            value = valueInOptions
        } else {
            value = BigUInt(0)
        }
        
        if (method == "fallback") {
            let transaction = EthereumTransaction(gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: extraData)
            return transaction
        }
        let foundMethod = self.methods.filter { (key, value) -> Bool in
            return key == method
        }
        guard foundMethod.count == 1 else {return nil}
        let abiMethod = foundMethod[method]
        guard let encodedData = abiMethod?.encodeParameters(parameters) else {return nil}
        let transaction = EthereumTransaction(gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: encodedData)
//        let transaction = EthereumTransaction(nonce: nonce, gasPrice: gasPrice, gasLimit: gas, to: to, value: value, data: encodedData, v: chainID, r: BigUInt(0), s: BigUInt(0))
        return transaction
    }
    
    public func parseEvent(_ eventLog: EventLog) -> (eventName:String?, eventData:[String:Any]?) {
        for (eName, ev) in self.events {
            let parsed = ev.decodeReturnedLogs(eventLog)
            if parsed != nil {
                return (eName, parsed!)
            }
        }
        return (nil, nil)
    }
}
