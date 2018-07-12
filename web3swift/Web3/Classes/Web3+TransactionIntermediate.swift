//
//  Web3+TransactionIntermediate.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import enum Result.Result
import BigInt
import PromiseKit
fileprivate typealias PromiseResult = PromiseKit.Result

extension web3.web3contract {

    public class TransactionIntermediate{
        public var transaction:EthereumTransaction
        public var contract: ContractProtocol
        public var method: String
        public var options: Web3Options? = Web3Options.defaultOptions()
        var web3: web3
        public init (transaction: EthereumTransaction, web3 web3Instance: web3, contract: ContractProtocol, method: String, options: Web3Options?) {
            self.transaction = transaction
            self.web3 = web3Instance
            self.contract = contract
            self.contract.options = options
            self.method = method
            self.options = Web3Options.merge(web3.options, with: options)
            if self.web3.provider.network != nil {
                self.transaction.chainID = self.web3.provider.network?.chainID
            }
        }
        
        @available(*, deprecated)
        public func setNonce(_ nonce: BigUInt) throws {
            self.transaction.nonce = nonce
            if (self.web3.provider.network != nil) {
                self.transaction.chainID = self.web3.provider.network?.chainID
            }
        }
        
        
        public func send(password: String = "BANKEXFOUNDATION", options: Web3Options? = nil, onBlock: String = "pending") -> Result<TransactionSendingResult, Web3Error> {
            do {
                let result = try self.sendPromise(password: password, options: options, onBlock: onBlock).wait()
                return Result(result)
            } catch {
                if let err = error as? Web3Error {
                    return Result.failure(err)
                }
                return Result.failure(Web3Error.generalError(error))
            }
        }
        
        public func call(options: Web3Options?, onBlock: String = "latest") -> Result<[String:Any], Web3Error> {
            do {
                let result = try self.callPromise(options: options, onBlock: onBlock).wait()
                return Result(result)
            } catch {
                if let err = error as? Web3Error {
                    return Result.failure(err)
                }
                return Result.failure(Web3Error.generalError(error))
            }
        }
        
        public func estimateGas(options: Web3Options?, onBlock: String = "latest") -> Result<BigUInt, Web3Error> {
            do {
                let result = try self.estimateGasPromise(options: options, onBlock: onBlock).wait()
                return Result(result)
            } catch {
                if let err = error as? Web3Error {
                    return Result.failure(err)
                }
                return Result.failure(Web3Error.generalError(error))
            }
        }

        func assemble(options: Web3Options? = nil, onBlock: String = "pending") -> Result<EthereumTransaction, Web3Error> {
            do {
                let result = try self.assemblePromise(options: options, onBlock: onBlock).wait()
                return Result(result)
            } catch {
                if let err = error as? Web3Error {
                    return Result.failure(err)
                }
                return Result.failure(Web3Error.generalError(error))
            }
        }
   
    }
}

extension web3.web3contract.TransactionIntermediate {
    
    func assemblePromise(options: Web3Options? = nil, onBlock: String = "pending") -> Promise<EthereumTransaction> {
        var assembledTransaction : EthereumTransaction = self.transaction
        let queue = self.web3.requestDispatcher.queue
        let returnPromise = Promise<EthereumTransaction> { seal in
            guard let mergedOptions = Web3Options.merge(self.options, with: options) else {
                seal.reject(Web3Error.inputError("Provided options are invalid"))
                return
            }
            guard let from = mergedOptions.from else {
                seal.reject(Web3Error.inputError("No 'from' field provided"))
                return
            }
            var optionsForGasEstimation = Web3Options()
            optionsForGasEstimation.from = mergedOptions.from
            optionsForGasEstimation.to = mergedOptions.to
            optionsForGasEstimation.value = mergedOptions.value
            let getNoncePromise : Promise<BigUInt> = self.web3.eth.getTransactionCountPromise(address: from, onBlock: onBlock)
            let gasEstimatePromise : Promise<BigUInt> = self.web3.eth.estimateGasPromise(assembledTransaction, options: optionsForGasEstimation, onBlock: onBlock)
            let gasPricePromise : Promise<BigUInt> = self.web3.eth.getGasPricePromise()
            var promisesToFulfill: [Promise<BigUInt>] = [getNoncePromise, gasPricePromise, gasPricePromise]
            when(resolved: getNoncePromise, gasEstimatePromise, gasPricePromise).map(on: queue, { (results:[PromiseResult<BigUInt>]) throws -> EthereumTransaction in
                
                promisesToFulfill.removeAll()
                guard case .fulfilled(let nonce) = results[0] else {
                    throw Web3Error.processingError("Failed to fetch nonce")
                }
                guard case .fulfilled(let gasEstimate) = results[1] else {
                    throw Web3Error.processingError("Failed to fetch gas estimate")
                }
                guard case .fulfilled(let gasPrice) = results[2] else {
                    throw Web3Error.processingError("Failed to fetch gas price")
                }
                guard let estimate = Web3Options.smartMergeGasLimit(originalOptions: options, extraOptions: mergedOptions, gasEstimate: gasEstimate) else {
                    throw Web3Error.processingError("Failed to calculate gas estimate that satisfied options")
                }
                assembledTransaction.nonce = nonce
                assembledTransaction.gasLimit = estimate
                if assembledTransaction.gasPrice == 0 {
                    if mergedOptions.gasPrice != nil {
                        assembledTransaction.gasPrice = mergedOptions.gasPrice!
                    } else {
                        assembledTransaction.gasPrice = gasPrice
                    }
                }
                return assembledTransaction
            }).done(on: queue) {tx in
                    seal.fulfill(tx)
                }.catch(on: queue) {err in
                    seal.reject(err)
            }
        }
        return returnPromise
    }
    
    func sendPromise(password:String = "BANKEXFOUNDATION", options: Web3Options? = nil, onBlock: String = "pending") -> Promise<TransactionSendingResult>{
        let queue = self.web3.requestDispatcher.queue
        return self.assemblePromise(options: options, onBlock: onBlock).then(on: queue) { transaction throws -> Promise<TransactionSendingResult> in
            guard let mergedOptions = Web3Options.merge(self.options, with: options) else {
                throw Web3Error.inputError("Provided options are invalid")
            }
            var cleanedOptions = Web3Options()
            cleanedOptions.from = mergedOptions.from
            cleanedOptions.to = mergedOptions.to
            return self.web3.eth.sendTransactionPromise(transaction, options: cleanedOptions, password: password)
        }
    }
    
    func callPromise(options: Web3Options? = nil, onBlock: String = "latest") -> Promise<[String: Any]>{
        let assembledTransaction : EthereumTransaction = self.transaction
        let queue = self.web3.requestDispatcher.queue
        let returnPromise = Promise<[String:Any]> { seal in
            guard let mergedOptions = Web3Options.merge(self.options, with: options) else {
                seal.reject(Web3Error.inputError("Provided options are invalid"))
                return
            }
            var optionsForCall = Web3Options()
            optionsForCall.from = mergedOptions.from
            optionsForCall.to = mergedOptions.to
            optionsForCall.value = mergedOptions.value
            let callPromise : Promise<Data> = self.web3.eth.callPromise(assembledTransaction, options: optionsForCall, onBlock: onBlock)
            callPromise.done(on: queue) {(data:Data) throws in
                    do {
                        if (self.method == "fallback") {
                            let resultHex = data.toHexString().addHexPrefix()
                            seal.fulfill(["result": resultHex as Any])
                            return
                        }
                        guard let decodedData = self.contract.decodeReturnData(self.method, data: data) else
                        {
                            throw Web3Error.processingError("Can not decode returned parameters")
                        }
                        seal.fulfill(decodedData)
                    } catch{
                        seal.reject(error)
                    }
                }.catch(on: queue) {err in
                    seal.reject(err)
            }
        }
        return returnPromise
    }
    
    func estimateGasPromise(options: Web3Options? = nil, onBlock: String = "latest") -> Promise<BigUInt>{
        let assembledTransaction : EthereumTransaction = self.transaction
        let queue = self.web3.requestDispatcher.queue
        let returnPromise = Promise<BigUInt> { seal in
            guard let mergedOptions = Web3Options.merge(self.options, with: options) else {
                seal.reject(Web3Error.inputError("Provided options are invalid"))
                return
            }
            var optionsForGasEstimation = Web3Options()
            optionsForGasEstimation.from = mergedOptions.from
            optionsForGasEstimation.to = mergedOptions.to
            optionsForGasEstimation.value = mergedOptions.value
            let promise = self.web3.eth.estimateGasPromise(assembledTransaction, options: optionsForGasEstimation, onBlock: onBlock)
            promise.done(on: queue) {(estimate: BigUInt) in
                    seal.fulfill(estimate)
                }.catch(on: queue) {err in
                    seal.reject(err)
            }
        }
        return returnPromise
    }
}
