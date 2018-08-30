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

    /// TransactionIntermediate is an almost-ready transaction or a smart-contract function call. It bears all the required information
    /// to call the smart-contract and decode the returned information, or estimate gas required for transaction, or send a transaciton
    /// to the blockchain.
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
        
        /**
         *Send a prepared transaction to the blockchain. Internally checks the nonce for a sending account, assigns it, get a gas estimate and signs a transaction either locally or on the remote node.*
         
         - parameters:
            - password: Password for a private key if transaction is signed locally
            - options: Web3Options to override the previously assigned gas price, gas limit and value.
            - onBlock: String field determines if nonce value and the gas estimate are based on the state of a blockchain on the latest mined block ("latest") or the expected state after all the transactions in memory pool are applied ("pending"). Using "pending" allows to send transactions one after another without waiting for inclusion of the previous one in some block.
         
         - returns:
            - Result object
         
         - important: This call is synchronous
         
         */
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
        
        /**
         *Calls a function of the smart-contract and parses the returned data to native objects.*
         
         - parameters:
            - options: Web3Options to override the previously assigned gas price, gas limit and value.
            - onBlock: String field determines if nonce value and the gas estimate are based on the state of a blockchain on the latest mined block ("latest") or the expected state after all the transactions in memory pool are applied ("pending"). Using "pending" allows to send transactions one after another without waiting for inclusion of the previous one in some block.
         
         - returns:
            - Result object
         
         - important: This call is synchronous
         
         */
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
        
        /**
         *Estimates gas required to execute the transaction. Setting a gas limit lower than the estimate will most likely result in a failed transaction. If this call returns an error it can also indicate that transaction is invalid as itself.*
         
         - parameters:
            - options: Web3Options to override the previously assigned gas price, gas limit and value.
            - onBlock: String field determines if nonce value and the gas estimate are based on the state of a blockchain on the latest mined block ("latest") or the expected state after all the transactions in memory pool are applied ("pending"). Using "pending" allows to send transactions one after another without waiting for inclusion of the previous one in some block.
         
         - returns:
            - Result object
         
         - important: This call is synchronous
         
         */
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
        
        /**
         *Assembles (but does not sign!) a transaction by fetching the nonce value and applying provided options.*
         
         - parameters:
            - options: Web3Options to override the previously assigned gas price, gas limit and value.
            - onBlock: String field determines if nonce value and the gas estimate are based on the state of a blockchain on the latest mined block ("latest") or the expected state after all the transactions in memory pool are applied ("pending"). Using "pending" allows to send transactions one after another without waiting for inclusion of the previous one in some block.
         
         - returns:
            - Result object
         
         - important: This call is synchronous
         
         */
        public func assemble(options: Web3Options? = nil, onBlock: String = "pending") -> Result<EthereumTransaction, Web3Error> {
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
    
    public func assemblePromise(options: Web3Options? = nil, onBlock: String = "pending") -> Promise<EthereumTransaction> {
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
                guard let finalGasPrice = Web3Options.smartMergeGasPrice(originalOptions: options, extraOptions: mergedOptions, priceEstimate: gasPrice) else {
                    throw Web3Error.processingError("Missing parameter of gas price for transaction")
                }
                assembledTransaction.gasPrice = finalGasPrice
//                if assembledTransaction.gasPrice == 0 {
//                    if mergedOptions.gasPrice != nil {
//                        assembledTransaction.gasPrice = mergedOptions.gasPrice!
//                    } else {
//                        assembledTransaction.gasPrice = gasPrice
//                    }
//                }
                return assembledTransaction
            }).done(on: queue) {tx in
                    seal.fulfill(tx)
                }.catch(on: queue) {err in
                    seal.reject(err)
            }
        }
        return returnPromise
    }
    
    public func sendPromise(password:String = "BANKEXFOUNDATION", options: Web3Options? = nil, onBlock: String = "pending") -> Promise<TransactionSendingResult>{
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
    
    public func callPromise(options: Web3Options? = nil, onBlock: String = "latest") -> Promise<[String: Any]>{
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
    
    public func estimateGasPromise(options: Web3Options? = nil, onBlock: String = "latest") -> Promise<BigUInt>{
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
