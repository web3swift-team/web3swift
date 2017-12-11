//
//  Contract.swift
//  web3swift
//
//  Created by Alexander Vlasov on 10.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

struct Contract {
    var chainID: BigUInt = BigUInt(1)
    var address: EthereumAddress?
    var abi: [ABIElement]
    var methods: [String: ABIElement]
    var options: Web3Options = Web3Options()
    
    func send(method:String = "fallback", parameters: [AnyObject], nonce: BigUInt, extraData:Data = Data(), options: Web3Options?) -> EthereumTransaction? {
        var to:EthereumAddress
        if let toInOptions = options?.to, toInOptions.isValid {
            to = toInOptions
        } else if let toInDefaults = self.options.to, toInDefaults.isValid {
            to = toInDefaults
        } else {
            return nil
        }
        
        var gas:BigUInt
        if let gasInOptions = options?.gas, gasInOptions > BigUInt(0) {
            gas = gasInOptions
        } else if self.options.gas > BigUInt(0) {
            gas = self.options.gas
        } else {
            return nil
        }
        
        var gasPrice:BigUInt
        if let gasPriceInOptions = options?.gasPrice, gasPriceInOptions > BigUInt(0) {
            gasPrice = gasPriceInOptions
        } else if self.options.gas > BigUInt(0) {
            gasPrice = self.options.gasPrice
        } else {
            return nil
        }
        
        var value:BigUInt
        if let valueInOptions = options?.gasPrice {
            value = valueInOptions
        } else {
            value = self.options.value
        }
        
        if (method == "fallback") {
            let transaction = EthereumTransaction(nonce: nonce, gasprice: gasPrice, startgas: gas, to: to, value: value, data: extraData, v: chainID, r: BigUInt(0), s: BigUInt(0))
            return transaction
        }
        let foundMethod = self.methods.filter { (key, value) -> Bool in
            return key == method
        }
        guard foundMethod.count == 1 else {return nil}
        let abiMethod = foundMethod[method]
        guard let encodedData = abiMethod?.encodeParameters(parameters) else {return nil}
        let transaction = EthereumTransaction(nonce: nonce, gasprice: gasPrice, startgas: gas, to: to, value: value, data: encodedData, v: chainID, r: BigUInt(0), s: BigUInt(0))
        return transaction
    }
}
