//
//  Web3+Eth.swift
//  web3swift
//
//  Created by Alexander Vlasov on 22.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import Result

extension web3.Eth {
    
    func sendTransaction(_ transaction: EthereumTransaction, options: Web3Options, password:String = "BANKEXFOUNDATION") -> Result<[String: String], Web3Error> {
        print(transaction)
        guard let mergedOptions = Web3Options.merge(self.options, with: options) else {
            return Result.failure(Web3Error.inputError("Check supplied options"))
        }
        guard let from = mergedOptions.from else {
            return Result.failure(Web3Error.walletError)
        }
        if let keystoreManager = self.web3.provider.attachedKeystoreManager {
            var tx = transaction
            do {
                try Web3Signer.signTX(transaction: &tx, keystore: keystoreManager, account: from, password: password)
            }
            catch {
                if error is AbstractKeystoreError {
                    return Result.failure(Web3Error.keystoreError(error as! AbstractKeystoreError))
                }
                return Result.failure(Web3Error.generalError(error))
            }
            print(tx)
            return self.sendRawTransaction(tx)
        }
        guard let request = EthereumTransaction.createRawTransaction(transaction: transaction) else {return Result.failure(Web3Error.transactionSerializationError)}
        let response = self.provider.send(request: request)
        let result = ResultUnwrapper.getResponse(response)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let payload):
            guard let resultString = payload as? String else {
                return Result.failure(Web3Error.dataError)
            }
            let hash = resultString.addHexPrefix().lowercased()
            return Result(["txhash": hash, "txhashCalculated" : transaction.hash!.toHexString()] as [String: String])
        }
    }
    
    func call(_ transaction: EthereumTransaction, options: Web3Options, onBlock:String = "latest") -> Result<[String: String], Web3Error> {
        print(transaction)
        let mergedOptions = Web3Options.merge(self.web3.options, with: options)
        guard let request = EthereumTransaction.createRequest(method: JSONRPCmethod.call, transaction: transaction, onBlock: onBlock, options: mergedOptions) else
        {
            return Result.failure(Web3Error.inputError("Transaction or options are malformed"))
        }
        let response = self.web3.provider.send(request: request)
        let result = ResultUnwrapper.getResponse(response)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let res):
            if let dict = res as? [String:String] {
                return Result(dict)
            }
            return Result.failure(Web3Error.dataError)
        }
    }
    
    
    func sendRawTransaction(_ transaction: EthereumTransaction) -> Result<[String: String], Web3Error> {
        print(transaction)
        guard let request = EthereumTransaction.createRawTransaction(transaction: transaction) else {return Result.failure(Web3Error.transactionSerializationError)}
        let response = self.provider.send(request: request)
        let result = ResultUnwrapper.getResponse(response)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let payload):
            guard let resultString = payload as? String else {
                return Result.failure(Web3Error.dataError)
            }
            let hash = resultString.addHexPrefix().lowercased()
            return Result(["txhash": hash, "txhashCalculated" : transaction.hash!.toHexString()] as [String: String])
        }
    }
    
    public func getTransactionCount(address: EthereumAddress, onBlock: String = "latest") -> Result<BigUInt, Web3Error> {
        guard address.isValid else {
            return Result.failure(Web3Error.inputError("Please check the supplied address"))
        }
        var request = JSONRPCrequest()
        request.method = JSONRPCmethod.getTransactionCount
        let params = [address.address.lowercased(), onBlock] as Array<Encodable>
        let pars = JSONRPCparams(params: params)
        request.params = pars
        let response = self.provider.send(request: request)
        let result = ResultUnwrapper.getResponse(response)
        switch result {
            case .failure(let error):
                return Result.failure(error)
            case .success(let payload):
                guard let resultString = payload as? String else {
                    return Result.failure(Web3Error.dataError)
                }
                guard let biguint = BigUInt(resultString.stripHexPrefix().lowercased(), radix: 16) else {
                    return Result.failure(Web3Error.dataError)
                }
                return Result(biguint)
        }
    }
    
    public func getBalance(address: EthereumAddress, onBlock: String = "latest") -> Result<BigUInt, Web3Error> {
        guard address.isValid else {
            return Result.failure(Web3Error.inputError("Please check the supplied address"))
        }
        var request = JSONRPCrequest()
        request.method = JSONRPCmethod.getBalance
        let params = [address.address.lowercased(), onBlock] as Array<Encodable>
        let pars = JSONRPCparams(params: params)
        request.params = pars
        let response = self.provider.send(request: request)
        let result = ResultUnwrapper.getResponse(response)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let payload):
            guard let resultString = payload as? String else {
                return Result.failure(Web3Error.dataError)
            }
            guard let biguint = BigUInt(resultString.stripHexPrefix().lowercased(), radix: 16) else {
                return Result.failure(Web3Error.dataError)
            }
            return Result(biguint)
        }
    }
    
    public func getBlockNumber() -> Result<BigUInt, Web3Error> {
        var request = JSONRPCrequest()
        request.method = JSONRPCmethod.blockNumber
        let params = [] as Array<Encodable>
        let pars = JSONRPCparams(params: params)
        request.params = pars
        let response = self.provider.send(request: request)
        let result = ResultUnwrapper.getResponse(response)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let payload):
            guard let resultString = payload as? String else {
                return Result.failure(Web3Error.dataError)
            }
            guard let biguint = BigUInt(resultString.stripHexPrefix().lowercased(), radix: 16) else {
                return Result.failure(Web3Error.dataError)
            }
            return Result(biguint)
        }
    }
    
    public func getGasPrice() -> Result<BigUInt, Web3Error> {
        var request = JSONRPCrequest()
        request.method = JSONRPCmethod.gasPrice
        let params = [] as Array<Encodable>
        let pars = JSONRPCparams(params: params)
        request.params = pars
        let response = self.provider.send(request: request)
        let result = ResultUnwrapper.getResponse(response)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let payload):
            guard let resultString = payload as? String else {
                return Result.failure(Web3Error.dataError)
            }
            guard let biguint = BigUInt(resultString.stripHexPrefix().lowercased(), radix: 16) else {
                return Result.failure(Web3Error.dataError)
            }
            return Result(biguint)
        }
    }
    
    public func getTransactionDetails(_ txhash: String) -> Result<TransactionDetails, Web3Error> {
        var request = JSONRPCrequest()
        request.method = JSONRPCmethod.getTransactionByHash
        let params = [txhash] as Array<Encodable>
        let pars = JSONRPCparams(params: params)
        request.params = pars
        let response = self.provider.send(request: request)
        let result = ResultUnwrapper.getResponse(response)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let payload):
            guard let resultJSON = payload as? [String: Any] else {
                return Result.failure(Web3Error.dataError)
            }
            guard let details = TransactionDetails(resultJSON) else {
                return Result.failure(Web3Error.dataError)
            }
            return Result(details)
        }
    }
    
    public func getTransactionReceipt(_ txhash: String) -> Result<TransactionReceipt, Web3Error> {
        var request = JSONRPCrequest()
        request.method = JSONRPCmethod.getTransactionReceipt
        let params = [txhash] as Array<Encodable>
        let pars = JSONRPCparams(params: params)
        request.params = pars
        let response = self.provider.send(request: request)
        let result = ResultUnwrapper.getResponse(response)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let payload):
            guard let resultJSON = payload as? [String: Any] else {
                return Result.failure(Web3Error.dataError)
            }
            guard let details = TransactionReceipt(resultJSON) else {
                return Result.failure(Web3Error.dataError)
            }
            return Result(details)
        }
    }
    
    public func estimateGas(_ transaction: EthereumTransaction, options: Web3Options?) -> Result<BigUInt, Web3Error> {
        let mergedOptions = Web3Options.merge(Web3Options.defaultOptions(), with: options)
        guard let request = EthereumTransaction.createRequest(method: JSONRPCmethod.estimateGas, transaction: transaction, onBlock: nil, options: mergedOptions) else {
            return Result.failure(Web3Error.inputError("Transaction serialization failed"))
        }
        let response = self.provider.send(request: request)
        let result = ResultUnwrapper.getResponse(response)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let payload):
            guard let resultString = payload as? String else {
                return Result.failure(Web3Error.dataError)
            }
            guard let biguint = BigUInt(resultString.stripHexPrefix().lowercased(), radix: 16) else {
                return Result.failure(Web3Error.dataError)
            }
            return Result(biguint)
        }
    }
    
    public func getAccounts() -> Result<[EthereumAddress],Web3Error> {
        if (self.provider.attachedKeystoreManager != nil) {
            return self.web3.wallet.getAccounts()
        }
        var request = JSONRPCrequest()
        request.method = JSONRPCmethod.getAccounts
        let params = [] as Array<Encodable>
        let pars = JSONRPCparams(params: params)
        request.params = pars
        let response = self.provider.send(request: request)
        let result = ResultUnwrapper.getResponse(response)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let payload):
            guard let resultArray = payload as? [String] else {
                return Result.failure(Web3Error.dataError)
                }
            var toReturn = [EthereumAddress]()
            for addrString in resultArray {
                let addr = EthereumAddress(addrString)
                if (addr.isValid) {
                    toReturn.append(addr)
                }
            }
            return Result(toReturn)
        }
    }
    
    public func getBlockByHash(_ hashString: String, fullTransactions: Bool = false) -> Result<AnyObject,Web3Error> {
        guard let hash = Data.fromHex(hashString) else {return Result.failure(Web3Error.inputError("Hash should be a hex string"))}
        return getBlockByHash(hash, fullTransactions: fullTransactions)
    }
    
    public func getBlockByHash(_ hash: Data, fullTransactions: Bool = false) -> Result<AnyObject,Web3Error> {
        var request = JSONRPCrequest()
        request.method = JSONRPCmethod.getBlockByHash
        let params = [hash.toHexString().addHexPrefix(), fullTransactions] as Array<Encodable>
        let pars = JSONRPCparams(params: params)
        request.params = pars
        let response = self.provider.send(request: request)
        let result = ResultUnwrapper.getResponse(response)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let payload):
            guard let resultArray = payload as? [String:AnyObject] else {
                return Result.failure(Web3Error.dataError)
            }
            return Result(1 as AnyObject)
        }
    }
    
    public func getBlockByNumber(_ number: Int, fullTransactions: Bool = false) -> Result<AnyObject,Web3Error> {
        let block = String(number, radix: 16).addHexPrefix()
        return getBlockByNumber(block, fullTransactions: fullTransactions)
    }
    
    public func getBlockByNumber(_ number: BigUInt, fullTransactions: Bool = false) -> Result<AnyObject,Web3Error> {
        let block = String(number, radix: 16).addHexPrefix()
        return getBlockByNumber(block, fullTransactions: fullTransactions)
    }
    
    public func getBlockByNumber(_ block:String, fullTransactions: Bool = false) -> Result<AnyObject,Web3Error> {
        var request = JSONRPCrequest()
        request.method = JSONRPCmethod.getBlockByNumber
        let params = [block, fullTransactions] as Array<Encodable>
        let pars = JSONRPCparams(params: params)
        request.params = pars
        let response = self.provider.send(request: request)
        let result = ResultUnwrapper.getResponse(response)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let payload):
            guard let resultArray = payload as? [String:AnyObject] else {
                return Result.failure(Web3Error.dataError)
            }
            return Result(1 as AnyObject)
        }
    }
    
}
