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
    
    public func sendTransaction(_ transaction: EthereumTransaction, options: Web3Options, password:String = "BANKEXFOUNDATION") -> Result<TransactionSendingResult, Web3Error> {
        do {
            let result = try self.sendTransactionPromise(transaction, options: options, password: password).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
//    func sendTransaction(_ transaction: EthereumTransaction, options: Web3Options, password:String = "BANKEXFOUNDATION") -> Result<[String: String], Web3Error> {
//        var externalResult: Result<[String:String], Web3Error>!
//        let semaphore = DispatchSemaphore(value: 0)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                guard let unwrappedResult = result as? [String: String] else {
//                    externalResult = Result.failure(Web3Error.dataError)
//                    break
//                }
//                externalResult = Result<[String: String], Web3Error>(unwrappedResult)
//            case .failure(let error):
//                externalResult = Result.failure(error)
//                break
//            }
//            semaphore.signal()
//        }
//        sendTransaction(transaction, options: options, password: password, callback: callback, queue: self.web3.queue)
//        _ = semaphore.wait(timeout: .distantFuture)
//        return externalResult
//
////        print(transaction)
////        guard let mergedOptions = Web3Options.merge(self.options, with: options) else {
////            return Result.failure(Web3Error.inputError("Check supplied options"))
////        }
////        guard let from = mergedOptions.from else {
////            return Result.failure(Web3Error.walletError)
////        }
////        if let keystoreManager = self.web3.provider.attachedKeystoreManager {
////            var tx = transaction
////            do {
////                try Web3Signer.signTX(transaction: &tx, keystore: keystoreManager, account: from, password: password)
////            }
////            catch {
////                if error is AbstractKeystoreError {
////                    return Result.failure(Web3Error.keystoreError(error as! AbstractKeystoreError))
////                }
////                return Result.failure(Web3Error.generalError(error))
////            }
////            print(tx)
////            return self.sendRawTransaction(tx)
////        }
////        guard let request = EthereumTransaction.createRequest(method: JSONRPCmethod.sendTransaction, transaction: transaction, onBlock: nil, options: mergedOptions) else
////        {
////            return Result.failure(Web3Error.transactionSerializationError)
////        }
////        let response = self.provider.send(request: request)
////        let result = ResultUnwrapper.getResponse(response)
////        switch result {
////        case .failure(let error):
////            return Result.failure(error)
////        case .success(let payload):
////            guard let resultString = payload as? String else {
////                return Result.failure(Web3Error.dataError)
////            }
////            let hash = resultString.addHexPrefix().lowercased()
////            return Result(["txhash": hash, "txhashCalculated" : transaction.hash!.toHexString().addHexPrefix()] as [String: String])
////        }
//    }
    
    
    func call(_ transaction: EthereumTransaction, options: Web3Options, onBlock:String = "latest") -> Result<Data, Web3Error> {
        do {
            let result = try self.callPromise(transaction, options: options, onBlock: onBlock).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
//    func call(_ transaction: EthereumTransaction, options: Web3Options, onBlock:String = "latest") -> Result<[String: String], Web3Error> {
//        var externalResult: Result<[String:String], Web3Error>!
//        let semaphore = DispatchSemaphore(value: 0)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                guard let unwrappedResult = result as? [String:String] else {
//                    externalResult = Result.failure(Web3Error.dataError)
//                    break
//                }
//                externalResult = Result<[String: String], Web3Error>(unwrappedResult)
//            case .failure(let error):
//                externalResult = Result.failure(error)
//                break
//            }
//            semaphore.signal()
//        }
//        call(transaction, options: options, onBlock: onBlock, callback:callback, queue: self.web3.queue)
//        _ = semaphore.wait(timeout: .distantFuture)
//        return externalResult
//
//
////        print(transaction)
////        let mergedOptions = Web3Options.merge(self.web3.options, with: options)
////        guard let request = EthereumTransaction.createRequest(method: .call, transaction: transaction, onBlock: onBlock, options: mergedOptions) else
////        {
////            return Result.failure(Web3Error.inputError("Transaction or options are malformed"))
////        }
////        let response = self.web3.provider.send(request: request)
////        let result = ResultUnwrapper.getResponse(response)
////        switch result {
////        case .failure(let error):
////            return Result.failure(error)
////        case .success(let res):
////            if let dict = res as? [String:String] {
////                return Result(dict)
////            }
////            return Result.failure(Web3Error.dataError)
////        }
//    }
    
    
    public func sendRawTransaction(_ transaction: Data) -> Result<TransactionSendingResult, Web3Error> {
        do {
            let result = try self.sendRawTransactionPromise(transaction).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func sendRawTransaction(_ transaction: EthereumTransaction) -> Result<TransactionSendingResult, Web3Error> {
        do {
            let result = try self.sendRawTransactionPromise(transaction).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    
//    func sendRawTransaction(_ transaction: EthereumTransaction) -> Result<[String: String], Web3Error> {
//        var externalResult: Result<[String:String], Web3Error>!
//        let semaphore = DispatchSemaphore(value: 0)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                guard let unwrappedResult = result as? [String:String] else {
//                    externalResult = Result.failure(Web3Error.dataError)
//                    break
//                }
//                externalResult = Result<[String: String], Web3Error>(unwrappedResult)
//            case .failure(let error):
//                externalResult = Result.failure(error)
//                break
//            }
//            semaphore.signal()
//        }
//        sendRawTransaction(transaction, callback:callback, queue: self.web3.queue)
//        _ = semaphore.wait(timeout: .distantFuture)
//        return externalResult
//
////        print(transaction)
////        guard let request = EthereumTransaction.createRawTransaction(transaction: transaction) else {return Result.failure(Web3Error.transactionSerializationError)}
////        let response = self.provider.send(request: request)
////        let result = ResultUnwrapper.getResponse(response)
////        switch result {
////        case .failure(let error):
////            return Result.failure(error)
////        case .success(let payload):
////            guard let resultString = payload as? String else {
////                return Result.failure(Web3Error.dataError)
////            }
////            let hash = resultString.addHexPrefix().lowercased()
////            return Result(["txhash": hash, "txhashCalculated" : transaction.hash!.toHexString().addHexPrefix()] as [String: String])
////        }
//    }
    
    
    public func getTransactionCount(address: EthereumAddress, onBlock: String = "latest") -> Result<BigUInt, Web3Error> {
        do {
            let result = try self.getTransactionCountPromise(address: address, onBlock: onBlock).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
//    public func getTransactionCount(address: EthereumAddress, onBlock: String = "latest") -> Result<BigUInt, Web3Error> {
//        var externalResult: Result<BigUInt, Web3Error>!
//        let semaphore = DispatchSemaphore(value: 0)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                guard let unwrappedResult = result as? BigUInt else {
//                    externalResult = Result.failure(Web3Error.dataError)
//                    break
//                }
//                externalResult = Result<BigUInt, Web3Error>(unwrappedResult)
//            case .failure(let error):
//                externalResult = Result.failure(error)
//                break
//            }
//            semaphore.signal()
//        }
//        getTransactionCount(address: address, onBlock: onBlock, callback: callback, queue: self.web3.queue)
//        _ = semaphore.wait(timeout: .distantFuture)
//        return externalResult
//
////        guard address.isValid else {
////            return Result.failure(Web3Error.inputError("Please check the supplied address"))
////        }
////        let request = JSONRPCRequestFabric.prepareRequest(.getTransactionCount, parameters: [address.address.lowercased(), onBlock])
////        let response = self.provider.send(request: request)
////        let result = ResultUnwrapper.getResponse(response)
////        switch result {
////            case .failure(let error):
////                return Result.failure(error)
////            case .success(let payload):
////                guard let resultString = payload as? String else {
////                    return Result.failure(Web3Error.dataError)
////                }
////                guard let biguint = BigUInt(resultString.stripHexPrefix().lowercased(), radix: 16) else {
////                    return Result.failure(Web3Error.dataError)
////                }
////                return Result(biguint)
////        }
//    }
    
    public func getBalance(address: EthereumAddress, onBlock: String = "latest") -> Result<BigUInt, Web3Error> {
        do {
            let result = try self.getBalancePromise(address: address, onBlock: onBlock).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
//    public func getBalance(address: EthereumAddress, onBlock: String = "latest") -> Result<BigUInt, Web3Error> {
//        var externalResult: Result<BigUInt, Web3Error>!
//        let semaphore = DispatchSemaphore(value: 0)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                guard let unwrappedResult = result as? BigUInt else {
//                    externalResult = Result.failure(Web3Error.dataError)
//                    break
//                }
//                externalResult = Result<BigUInt, Web3Error>(unwrappedResult)
//            case .failure(let error):
//                externalResult = Result.failure(error)
//                break
//            }
//            semaphore.signal()
//        }
//        getBalance(address: address, onBlock: onBlock, callback: callback, queue: self.web3.queue)
//        _ = semaphore.wait(timeout: .distantFuture)
//        return externalResult
//
////        guard address.isValid else {
////            return Result.failure(Web3Error.inputError("Please check the supplied address"))
////        }
////        let request = JSONRPCRequestFabric.prepareRequest(.getBalance, parameters: [address.address.lowercased(), onBlock])
////        let response = self.provider.send(request: request)
////        let result = ResultUnwrapper.getResponse(response)
////        switch result {
////        case .failure(let error):
////            return Result.failure(error)
////        case .success(let payload):
////            guard let resultString = payload as? String else {
////                return Result.failure(Web3Error.dataError)
////            }
////            guard let biguint = BigUInt(resultString.stripHexPrefix().lowercased(), radix: 16) else {
////                return Result.failure(Web3Error.dataError)
////            }
////            return Result(biguint)
////        }
//    }
    
    
    public func getBlockNumber() -> Result<BigUInt, Web3Error> {
        do {
            let result = try self.getBlockNumberPromise().wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
//    public func getBlockNumber() -> Result<BigUInt, Web3Error> {
//        var externalResult: Result<BigUInt, Web3Error>!
//        let semaphore = DispatchSemaphore(value: 0)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                guard let unwrappedResult = result as? BigUInt else {
//                    externalResult = Result.failure(Web3Error.dataError)
//                    break
//                }
//                externalResult = Result<BigUInt, Web3Error>(unwrappedResult)
//            case .failure(let error):
//                externalResult = Result.failure(error)
//                break
//            }
//            semaphore.signal()
//        }
//        getBlockNumber(callback: callback, queue: self.web3.queue)
//        _ = semaphore.wait(timeout: .distantFuture)
//        return externalResult
//
////        let request = JSONRPCRequestFabric.prepareRequest(.blockNumber, parameters: [])
////        let response = self.provider.send(request: request)
////        let result = ResultUnwrapper.getResponse(response)
////        switch result {
////        case .failure(let error):
////            return Result.failure(error)
////        case .success(let payload):
////            guard let resultString = payload as? String else {
////                return Result.failure(Web3Error.dataError)
////            }
////            guard let biguint = BigUInt(resultString.stripHexPrefix().lowercased(), radix: 16) else {
////                return Result.failure(Web3Error.dataError)
////            }
////            return Result(biguint)
////        }
//    }
    

    public func getGasPrice() -> Result<BigUInt, Web3Error> {
        do {
            let result = try self.getGasPricePromise().wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
//    public func getGasPrice() -> Result<BigUInt, Web3Error> {
////        guard let queue = OperationQueue.current else {return Result.failure(Web3Error.dataError)}
//        var externalResult: Result<BigUInt, Web3Error>!
//        let semaphore = DispatchSemaphore(value: 0)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                guard let unwrappedResult = result as? BigUInt else {
//                    externalResult = Result.failure(Web3Error.dataError)
//                    break
//                }
//                externalResult = Result<BigUInt, Web3Error>(unwrappedResult)
//            case .failure(let error):
//                externalResult = Result.failure(error)
//                break
//            }
//            semaphore.signal()
//        }
//        getGasPrice(callback: callback, queue: self.web3.queue)
//        _ = semaphore.wait(timeout: .distantFuture)
//        return externalResult
//
////        let request = JSONRPCRequestFabric.prepareRequest(.gasPrice, parameters: [])
////        let response = self.provider.send(request: request)
////        let result = ResultUnwrapper.getResponse(response)
////        switch result {
////        case .failure(let error):
////            return Result.failure(error)
////        case .success(let payload):
////            guard let resultString = payload as? String else {
////                return Result.failure(Web3Error.dataError)
////            }
////            guard let biguint = BigUInt(resultString.stripHexPrefix().lowercased(), radix: 16) else {
////                return Result.failure(Web3Error.dataError)
////            }
////            return Result(biguint)
////        }
//    }
//
    
    public func getTransactionDetails(_ txhash: Data) -> Result<TransactionDetails, Web3Error> {
        do {
            let result = try self.getTransactionDetailsPromise(txhash).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getTransactionDetails(_ txhash: String) -> Result<TransactionDetails, Web3Error> {
        do {
            let result = try self.getTransactionDetailsPromise(txhash).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
//    public func getTransactionDetails(_ txhash: Data) -> Result<TransactionDetails, Web3Error> {
//        let hashString = txhash.toHexString().addHexPrefix()
//        return self.getTransactionDetails(hashString)
//    }
//
//    public func getTransactionDetails(_ txhash: String) -> Result<TransactionDetails, Web3Error> {
//        var externalResult: Result<TransactionDetails, Web3Error>!
//        let semaphore = DispatchSemaphore(value: 0)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                guard let unwrappedResult = result as? TransactionDetails else {
//                    externalResult = Result.failure(Web3Error.dataError)
//                    break
//                }
//                externalResult = Result<TransactionDetails, Web3Error>(unwrappedResult)
//            case .failure(let error):
//                externalResult = Result.failure(error)
//                break
//            }
//            semaphore.signal()
//        }
//        getTransactionDetails(txhash, callback: callback, queue: self.web3.queue)
//        _ = semaphore.wait(timeout: .distantFuture)
//        return externalResult
//
//
////        let request = JSONRPCRequestFabric.prepareRequest(.getTransactionByHash, parameters: [txhash])
////        let response = self.provider.send(request: request)
////        let result = ResultUnwrapper.getResponse(response)
////        switch result {
////        case .failure(let error):
////            return Result.failure(error)
////        case .success(let payload):
////            guard let resultJSON = payload as? [String: AnyObject] else {
////                return Result.failure(Web3Error.dataError)
////            }
////            guard let details = TransactionDetails(resultJSON) else {
////                return Result.failure(Web3Error.dataError)
////            }
////            return Result(details)
////        }
//    }
    
    
    public func getTransactionReceipt(_ txhash: Data) -> Result<TransactionReceipt, Web3Error> {
        do {
            let result = try self.getTransactionReceiptPromise(txhash).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getTransactionReceipt(_ txhash: String) -> Result<TransactionReceipt, Web3Error> {
        do {
            let result = try self.getTransactionReceiptPromise(txhash).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
//    public func getTransactionReceipt(_ txhash: Data) -> Result<TransactionReceipt, Web3Error> {
//        let hashString = txhash.toHexString().addHexPrefix()
//        return self.getTransactionReceipt(hashString)
//    }
//
//    public func getTransactionReceipt(_ txhash: String) -> Result<TransactionReceipt, Web3Error> {
//        var externalResult: Result<TransactionReceipt, Web3Error>!
//        let semaphore = DispatchSemaphore(value: 0)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                guard let unwrappedResult = result as? TransactionReceipt else {
//                    externalResult = Result.failure(Web3Error.dataError)
//                    break
//                }
//                externalResult = Result<TransactionReceipt, Web3Error>(unwrappedResult)
//            case .failure(let error):
//                externalResult = Result.failure(error)
//                break
//            }
//            semaphore.signal()
//        }
//        getTransactionReceipt(txhash, callback: callback, queue: self.web3.queue)
//        _ = semaphore.wait(timeout: .distantFuture)
//        return externalResult
//
////        let request = JSONRPCRequestFabric.prepareRequest(.getTransactionReceipt, parameters: [txhash])
////        let response = self.provider.send(request: request)
////        let result = ResultUnwrapper.getResponse(response)
////        switch result {
////        case .failure(let error):
////            return Result.failure(error)
////        case .success(let payload):
////            if payload is NSNull {
////                    return Result(TransactionReceipt.notProcessed(transactionHash: Data()))
////            }
////            guard let resultJSON = payload as? [String: AnyObject] else {
////                return Result.failure(Web3Error.dataError)
////            }
////            guard let details = TransactionReceipt(resultJSON) else {
////                return Result.failure(Web3Error.dataError)
////            }
////            return Result(details)
////        }
//    }
    
    
    public func estimateGas(_ transaction: EthereumTransaction, options: Web3Options?, onBlock: String = "latest") -> Result<BigUInt, Web3Error> {
        do {
            let result = try self.estimateGasPromise(transaction, options: options, onBlock: onBlock).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
//    public func estimateGas(_ transaction: EthereumTransaction, options: Web3Options?, onBlock: String = "latest") -> Result<BigUInt, Web3Error> {
////        var mergedOptions = Web3Options.merge(self.options, with: options)
//        var externalResult: Result<BigUInt, Web3Error>!
//        let semaphore = DispatchSemaphore(value: 0)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                guard let unwrappedResult = result as? BigUInt else {
//                    externalResult = Result.failure(Web3Error.dataError)
//                    break
//                }
//                externalResult = Result<BigUInt, Web3Error>(unwrappedResult)
//            case .failure(let error):
//                externalResult = Result.failure(error)
//                break
//            }
//            semaphore.signal()
//        }
//        estimateGas(transaction, options: options, onBlock: onBlock, callback: callback, queue: self.web3.queue)
//        _ = semaphore.wait(timeout: .distantFuture)
//        return externalResult
//
////        mergedOptions?.gasLimit = nil // use gas limit of the previous block
////        guard let request = EthereumTransaction.createRequest(method: JSONRPCmethod.estimateGas, transaction: transaction, onBlock: onBlock, options: mergedOptions) else {
////            return Result.failure(Web3Error.inputError("Transaction serialization failed"))
////        }
////        let response = self.provider.send(request: request)
////        let result = ResultUnwrapper.getResponse(response)
////        switch result {
////        case .failure(let error):
////            return Result.failure(error)
////        case .success(let payload):
////            guard let resultString = payload as? String else {
////                return Result.failure(Web3Error.dataError)
////            }
////            guard let biguint = BigUInt(resultString.stripHexPrefix().lowercased(), radix: 16) else {
////                return Result.failure(Web3Error.dataError)
////            }
////            return Result(biguint)
////        }
//    }
    
    
    public func getAccounts() -> Result<[EthereumAddress],Web3Error> {
        do {
            let result = try self.getAccountsPromise().wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
//    public func getAccounts() -> Result<[EthereumAddress],Web3Error> {
//        if (self.provider.attachedKeystoreManager != nil) {
//            return self.web3.wallet.getAccounts()
//        }
//
//        var externalResult: Result<[EthereumAddress], Web3Error>!
//        let semaphore = DispatchSemaphore(value: 0)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                guard let unwrappedResult = result as? [EthereumAddress] else {
//                    externalResult = Result.failure(Web3Error.dataError)
//                    break
//                }
//                externalResult = Result<[EthereumAddress], Web3Error>(unwrappedResult)
//            case .failure(let error):
//                externalResult = Result.failure(error)
//                break
//            }
//            semaphore.signal()
//        }
//        getAccounts(callback: callback, queue: self.web3.queue)
//        _ = semaphore.wait(timeout: .distantFuture)
//        return externalResult
//
////        let request = JSONRPCRequestFabric.prepareRequest(.getAccounts, parameters: [])
////        let response = self.provider.send(request: request)
////        let result = ResultUnwrapper.getResponse(response)
////        switch result {
////        case .failure(let error):
////            return Result.failure(error)
////        case .success(let payload):
////            guard let resultArray = payload as? [String] else {
////                return Result.failure(Web3Error.dataError)
////                }
////            var toReturn = [EthereumAddress]()
////            for addrString in resultArray {
////                guard let addr = EthereumAddress(addrString) else {
////                    return Result.failure(Web3Error.dataError)
////                }
////                toReturn.append(addr)
////            }
////            return Result(toReturn)
////        }
//    }
    
    public func getBlockByHash(_ hash: String, fullTransactions: Bool = false) -> Result<Block,Web3Error> {
        do {
            let result = try self.getBlockByHashPromise(hash, fullTransactions: fullTransactions).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getBlockByHash(_ hash: Data, fullTransactions: Bool = false) -> Result<Block,Web3Error> {
        do {
            let result = try self.getBlockByHashPromise(hash, fullTransactions: fullTransactions).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
//    public func getBlockByHash(_ hash: String, fullTransactions: Bool = false) -> Result<Block,Web3Error> {
//        guard let h = Data.fromHex(hash) else {return Result.failure(Web3Error.inputError("Hash should be a hex string"))}
//        return getBlockByHash(h, fullTransactions: fullTransactions)
//    }
//
//    public func getBlockByHash(_ hash: Data, fullTransactions: Bool = false) -> Result<Block,Web3Error> {
//        var externalResult: Result<Block, Web3Error>!
//        let semaphore = DispatchSemaphore(value: 0)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                guard let unwrappedResult = result as? Block else {
//                    externalResult = Result.failure(Web3Error.dataError)
//                    break
//                }
//                externalResult = Result<Block, Web3Error>(unwrappedResult)
//            case .failure(let error):
//                externalResult = Result.failure(error)
//                break
//            }
//            semaphore.signal()
//        }
//        getBlockByHash(hash, fullTransactions: fullTransactions, callback: callback, queue: self.web3.queue)
//        _ = semaphore.wait(timeout: .distantFuture)
//        return externalResult
//
//
////        let request = JSONRPCRequestFabric.prepareRequest(.getBlockByHash, parameters: [hash.toHexString().addHexPrefix(), fullTransactions])
////        let response = self.provider.send(request: request)
////        let result = ResultUnwrapper.getResponse(response)
////        switch result {
////        case .failure(let error):
////            return Result.failure(error)
////        case .success(let payload):
////            guard let resultJSON = payload as? [String:AnyObject] else {
////                return Result.failure(Web3Error.dataError)
////            }
////            guard let resultData = try? JSONSerialization.data(withJSONObject: resultJSON) else {
////                return Result.failure(Web3Error.dataError)
////            }
////            guard let block = try? JSONDecoder().decode(Block.self, from: resultData) else {
////                return Result.failure(Web3Error.dataError)
////            }
////            return Result(block)
////        }
//    }
    
    
    public func getBlockByNumber(_ number: UInt64, fullTransactions: Bool = false) -> Result<Block,Web3Error> {
        do {
            let result = try self.getBlockByNumberPromise(number, fullTransactions: fullTransactions).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getBlockByNumber(_ number: BigUInt, fullTransactions: Bool = false) -> Result<Block,Web3Error> {
        do {
            let result = try self.getBlockByNumberPromise(number, fullTransactions: fullTransactions).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getBlockByNumber(_ block:String, fullTransactions: Bool = false) -> Result<Block,Web3Error> {
        do {
            let result = try self.getBlockByNumberPromise(block, fullTransactions: fullTransactions).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
//    public func getBlockByNumber(_ number: UInt64, fullTransactions: Bool = false) -> Result<Block,Web3Error> {
//        let block = String(number, radix: 16).addHexPrefix()
//        return getBlockByNumber(block, fullTransactions: fullTransactions)
//    }
//
//    public func getBlockByNumber(_ number: BigUInt, fullTransactions: Bool = false) -> Result<Block,Web3Error> {
//        let block = String(number, radix: 16).addHexPrefix()
//        return getBlockByNumber(block, fullTransactions: fullTransactions)
//    }
//
//    public func getBlockByNumber(_ block:String, fullTransactions: Bool = false) -> Result<Block,Web3Error> {
//        var externalResult: Result<Block, Web3Error>!
//        let semaphore = DispatchSemaphore(value: 0)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                guard let unwrappedResult = result as? Block else {
//                    externalResult = Result.failure(Web3Error.dataError)
//                    break
//                }
//                externalResult = Result<Block, Web3Error>(unwrappedResult)
//            case .failure(let error):
//                externalResult = Result.failure(error)
//                break
//            }
//            semaphore.signal()
//        }
//        getBlockByNumber(block, fullTransactions: fullTransactions, callback: callback, queue: self.web3.queue)
//        _ = semaphore.wait(timeout: .distantFuture)
//        return externalResult
//
////        let request = JSONRPCRequestFabric.prepareRequest(.getBlockByNumber, parameters: [block, fullTransactions])
////        let response = self.provider.send(request: request)
////        let result = ResultUnwrapper.getResponse(response)
////        switch result {
////        case .failure(let error):
////            return Result.failure(error)
////        case .success(let payload):
////            guard let resultJSON = payload as? [String:AnyObject] else {
////                return Result.failure(Web3Error.dataError)
////            }
////            guard let resultData = try? JSONSerialization.data(withJSONObject: resultJSON) else {
////                return Result.failure(Web3Error.dataError)
////            }
////            guard let block = try? JSONDecoder().decode(Block.self, from: resultData) else {
////                return Result.failure(Web3Error.dataError)
////            }
////            return Result(block)
////        }
//    }
    
    public func sendETH(to: EthereumAddress, amount: BigUInt, extraData: Data = Data(), options: Web3Options? = nil) -> TransactionIntermediate? {
        let contract = self.web3.contract(Web3.Utils.coldWalletABI, at: to, abiVersion: 2)
        guard var mergedOptions = Web3Options.merge(self.options, with: options) else {return nil}
        mergedOptions.value = amount
        let intermediate = contract?.method("fallback", extraData: extraData, options: mergedOptions)
        return intermediate
    }
    
    public func sendETH(to: EthereumAddress, amount: String, units: Web3.Utils.Units = .eth, extraData: Data = Data(), options: Web3Options? = nil) -> TransactionIntermediate? {
        guard let value = Web3.Utils.parseToBigUInt(amount, units: .eth) else {return nil}
        return sendETH(to: to, amount: value, extraData: extraData, options: options)
    }
    
    public func sendETH(from: EthereumAddress, to: EthereumAddress, amount: String, units: Web3.Utils.Units = .eth, extraData: Data = Data(), options: Web3Options? = nil) -> TransactionIntermediate? {
        guard let value = Web3.Utils.parseToBigUInt(amount, units: .eth) else {return nil}
        guard var mergedOptions = Web3Options.merge(self.options, with: options) else {return nil}
        mergedOptions.from = from
        return sendETH(to: to, amount: value, extraData: extraData, options: mergedOptions)
    }
    
    public func sendERC20tokensWithKnownDecimals(tokenAddress: EthereumAddress, from: EthereumAddress, to: EthereumAddress, amount: BigUInt, options: Web3Options? = nil) -> TransactionIntermediate? {
        let contract = self.web3.contract(Web3.Utils.erc20ABI, at: tokenAddress, abiVersion: 2)
        guard var mergedOptions = Web3Options.merge(self.options, with: options) else {return nil}
        mergedOptions.from = from
        guard let intermediate = contract?.method("transfer", parameters: [to, amount] as [AnyObject], options: mergedOptions) else {return nil}
        return intermediate
    }
    
    public func sendERC20tokensWithNaturalUnits(tokenAddress: EthereumAddress, from: EthereumAddress, to: EthereumAddress, amount: String, options: Web3Options? = nil) -> TransactionIntermediate? {
        let contract = self.web3.contract(Web3.Utils.erc20ABI, at: tokenAddress, abiVersion: 2)
        guard var mergedOptions = Web3Options.merge(self.options, with: options) else {return nil}
        mergedOptions.from = from
        guard let intermediate = contract?.method("decimals", options: mergedOptions) else {return nil}
        let callResult = intermediate.call(options: mergedOptions, onBlock: "latest")
        var decimals = BigUInt(0)
        switch callResult {
        case .success(let response):
            guard let dec = response["0"], let decTyped = dec as? BigUInt else {return nil}
            decimals = decTyped
            break
        case .failure(_):
            break
        }
        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {return nil}
        return sendERC20tokensWithKnownDecimals(tokenAddress: tokenAddress, from: from, to: to, amount: value, options: options)
    }
    
}
