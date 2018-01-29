//
//  Web3+Eth.swift
//  web3swift
//
//  Created by Alexander Vlasov on 22.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

extension web3.Eth {
    func sendRawTransaction(_ transaction: EthereumTransaction) -> [String:Any]? {
        print(transaction)
        guard let request = EthereumTransaction.createRawTransaction(transaction: transaction) else {return nil}
        let response = self.provider.sendSync(request: request)
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
        return ["txhash": hash as Any, "txhashCalculated" : transaction.txhash as Any]
    }
    
    public func getTransactionCount(address: EthereumAddress, onBlock: String = "latest") -> BigUInt? {
            guard address.isValid else {return nil}
            var request = JSONRPCrequest()
            request.method = JSONRPCmethod.getTransactionCount
            let params = [address.address.lowercased(), onBlock] as Array<Encodable>
            let pars = JSONRPCparams(params: params)
            request.params = pars
            let response = self.provider.sendSync(request: request)
            if response == nil {
                return nil
            }
            guard let res = response else {return nil}
            if let error = res["error"] as? String {
                print(error as String)
                return nil
            }
            guard let resultString = res["result"] as? String else {return nil}
            let biguint = BigUInt(resultString.stripHexPrefix().lowercased(), radix: 16)
            return biguint
    }
    
    public func getBalance(address: EthereumAddress, onBlock: String = "latest") -> BigUInt? {
            guard address.isValid else {return nil}
            var request = JSONRPCrequest()
            request.method = JSONRPCmethod.getBalance
            let params = [address.address.lowercased(), onBlock] as Array<Encodable>
            let pars = JSONRPCparams(params: params)
            request.params = pars
            let response = self.provider.sendSync(request: request)
            if response == nil {
                return nil
            }
            guard let res = response else {return nil}
            if let error = res["error"] as? String {
                print(error as String)
                return nil
            }
            guard let resultString = res["result"] as? String else {return nil}
            let biguint = BigUInt(resultString.stripHexPrefix().lowercased(), radix: 16)
            return biguint
    }
    
    public func getBlockNumber() -> BigUInt? {
            var request = JSONRPCrequest()
            request.method = JSONRPCmethod.blockNumber
            let params = [] as Array<Encodable>
            let pars = JSONRPCparams(params: params)
            request.params = pars
            let response = self.provider.sendSync(request: request)
            if response == nil {
                return nil
            }
            guard let res = response else {return nil}
            if let error = res["error"] as? String {
                print(error as String)
                return nil
            }
            guard let resultString = res["result"] as? String else {return nil}
            let biguint = BigUInt(resultString.stripHexPrefix().lowercased(), radix: 16)
            return biguint
    }
    
    public func getGasPrice() -> BigUInt? {
            var request = JSONRPCrequest()
            request.method = JSONRPCmethod.gasPrice
            let params = [] as Array<Encodable>
            let pars = JSONRPCparams(params: params)
            request.params = pars
            let response = self.provider.sendSync(request: request)
            if response == nil {
                return nil
            }
            guard let res = response else {return nil}
            if let error = res["error"] as? String {
                print(error as String)
                return nil
            }
            guard let resultString = res["result"] as? String else {return nil}
            let biguint = BigUInt(resultString.stripHexPrefix().lowercased(), radix: 16)
            return biguint
    }
    
    public func getTransactionDetails(_ txhash: String) -> TransactionDetails? {
            var request = JSONRPCrequest()
            request.method = JSONRPCmethod.getTransactionByHash
            let params = [txhash] as Array<Encodable>
            let pars = JSONRPCparams(params: params)
            request.params = pars
            let response = self.provider.sendSync(request: request)
            if response == nil {
                return nil
            }
            guard let res = response else {return nil}
            if let error = res["error"] as? String {
                print(error as String)
                return nil
            }
            guard let resultJSON = res["result"] as? [String: Any] else {return nil}
            let details = TransactionDetails(resultJSON)
            return details
    }
    
    public func getTransactionReceipt(_ txhash: String) -> TransactionReceipt? {
            var request = JSONRPCrequest()
            request.method = JSONRPCmethod.getTransactionReceipt
            let params = [txhash] as Array<Encodable>
            let pars = JSONRPCparams(params: params)
            request.params = pars
            let response = self.provider.sendSync(request: request)
            if response == nil {
                return nil
            }
            guard let res = response else {return nil}
            if let error = res["error"] as? String {
                print(error as String)
                return nil
            }
            guard let resultJSON = res["result"] as? [String: Any] else {return nil}
            let details = TransactionReceipt(resultJSON)
            return details
    }
    
    public func estimateGas(_ transaction: EthereumTransaction, options: Web3Options?) -> BigUInt? {
        let mergedOptions = Web3Options.merge(Web3Options.defaultOptions(), with: options)
        guard let request = EthereumTransaction.createRequest(method: JSONRPCmethod.estimateGas, transaction: transaction, onBlock: nil, options: mergedOptions) else {return nil}
        let response = self.provider.sendSync(request: request)
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
    
    public func getAccounts() -> [EthereumAddress]? {
        if (self.provider.attachedKeystoreManager != nil) {
            return self.provider.attachedKeystoreManager?.addresses
        }
        var request = JSONRPCrequest()
        request.method = JSONRPCmethod.getAccounts
        let params = [] as Array<Encodable>
        let pars = JSONRPCparams(params: params)
        request.params = pars
        let response = self.provider.sendSync(request: request)
        if response == nil {
            return nil
        }
        guard let res = response else {return nil}
        if let error = res["error"] as? String {
            print(error as String)
            return nil
        }
        guard let resultArray = res["result"] as? [String] else {return nil}
        var toReturn = [EthereumAddress]()
        for addrString in resultArray {
            let addr = EthereumAddress(addrString)
            if (addr.isValid) {
                toReturn.append(addr)
            }
        }
        return toReturn
    }
    
}
