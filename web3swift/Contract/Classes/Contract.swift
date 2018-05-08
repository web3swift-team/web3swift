//
//  Contract.swift
//  web3swift
//
//  Created by Alexander Vlasov on 10.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

public struct Contract:ContractProtocol {
    
    public var allEvents: [String] {
        return events.keys.flatMap({ (s) -> String in
            return s
        })
    }
    public var allMethods: [String] {
        return methods.keys.flatMap({ (s) -> String in
            return s
        })
    }
    
    public var address: EthereumAddress? = nil
    var _abi: [ABIElement]
    public var methods: [String: ABIElement] {
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
    
    public var constructor: ABIElement? {
        var toReturn : ABIElement? = nil
        for m in self._abi {
            if toReturn != nil {
                break
            }
            switch m {
            case .constructor(_):
                toReturn = m
                break
            default:
                continue
            }
        }
        if toReturn == nil {
            let defaultConstructor = ABIElement.constructor(ABIElement.Constructor.init(inputs: [], constant: false, payable: false))
            return defaultConstructor
        }
        return toReturn
    }
    
    public var events: [String: ABIElement] {
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
    
    public var options: Web3Options? = Web3Options.defaultOptions()
    
    public init?(_ abiString: String, at: EthereumAddress? = nil) {
        do {
            let jsonData = abiString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIRecord].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIElement in
                return try record.parse()
            })
            _abi = abiNative
            if at != nil {
                self.address = at
            }
        }
        catch{
            print(error)
            return nil
        }
    }
    
    public init(abi: [ABIElement]) {
        _abi = abi
    }
    
    public init(abi: [ABIElement], at: EthereumAddress) {
        _abi = abi
        address = at
    }
    
    public func deploy(bytecode:Data, parameters: [AnyObject] = [AnyObject](), extraData: Data = Data(), options: Web3Options?) -> EthereumTransaction? {
        let to:EthereumAddress = EthereumAddress.contractDeploymentAddress()
        let mergedOptions = Web3Options.merge(self.options, with: options)
        
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
        guard let constructor = self.constructor else {return nil}
        guard let encodedData = constructor.encodeParameters(parameters) else {return nil}
        var fullData = bytecode
        if encodedData != Data() {
            fullData.append(encodedData)
        } else if extraData != Data() {
            fullData.append(extraData)
        }
        let transaction = EthereumTransaction(gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: fullData)
        return transaction
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
    
    public func decodeReturnData(_ method:String, data: Data) -> [String:Any]? {
        if method == "fallback" {
            return [String:Any]()
        }
        guard let function = methods[method] else {return nil}
        guard case .function(_) = function else {return nil}
        return function.decodeReturnData(data)
    }
    
    public func testBloomForEventPrecence(eventName: String, bloom: EthereumBloomFilter) -> Bool? {
        return false
    }
    
    public func decodeInputData(_ method: String, data: Data) -> [String : Any]? {
        return nil
    }
}
