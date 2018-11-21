//
//  Web3Legacy+Contract.swift
//  web3swift
//
//  Created by Anton Grigorev on 21.11.2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import EthereumAddress

extension web3.web3contract {
    
    /// Deploys a constact instance using the previously provided (at initialization) ABI, some bytecode, constructor parameters and options.
    /// If extraData is supplied it is appended to encoded bytecode and constructor parameters.
    ///
    /// Returns a "Transaction intermediate" object.
    @available(*, deprecated, message: "Use deploy with transactionOptions instead")
    public func deploy(bytecode: Data, parameters: [AnyObject] = [AnyObject](), extraData: Data = Data(), options: Web3Options?) -> TransactionIntermediate? {
        
        let mergedOptions = Web3Options.merge(self.options, with: options)
        guard var tx = self.contract.deploy(bytecode: bytecode, parameters: parameters, extraData: extraData) else {return nil}
        tx.chainID = self.web3.provider.network?.chainID
        let intermediate = TransactionIntermediate(transaction: tx, web3: self.web3, contract: self.contract, method: "fallback", options: mergedOptions)
        return intermediate
    }
    
    /// Creates and object responsible for calling a particular function of the contract. If method name is not found in ABI - returns nil.
    /// If extraData is supplied it is appended to encoded function parameters. Can be usefull if one wants to call
    /// the function not listed in ABI. "Parameters" should be an array corresponding to the list of parameters of the function.
    /// Elements of "parameters" can be other arrays or instances of String, Data, BigInt, BigUInt, Int or EthereumAddress.
    ///
    /// Returns a "Transaction intermediate" object.
    @available(*, deprecated, message: "Use method with transactionOptions instead")
    public func method(_ method:String = "fallback", parameters: [AnyObject] = [AnyObject](), extraData: Data = Data(), options: Web3Options?) -> TransactionIntermediate? {
        let mergedOptions = Web3Options.merge(self.options, with: options)
        guard var tx = self.contract.method(method, parameters: parameters, extraData: extraData) else {return nil}
        tx.chainID = self.web3.provider.network?.chainID
        let intermediate = TransactionIntermediate(transaction: tx, web3: self.web3, contract: self.contract, method: method, options: mergedOptions)
        return intermediate
    }
}
