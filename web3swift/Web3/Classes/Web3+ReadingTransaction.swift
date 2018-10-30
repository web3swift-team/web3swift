//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit
fileprivate typealias PromiseResult = PromiseKit.Result
import EthereumAddress

public class ReadTransaction {
    public var transaction:EthereumTransaction
    public var contract: EthereumContract
    public var method: String
    public var transactionOptions: TransactionOptions = TransactionOptions.defaultOptions
    
    var web3: web3
    
    public init (transaction: EthereumTransaction, web3 web3Instance: web3, contract: EthereumContract, method: String, transactionOptions: TransactionOptions?) {
        self.transaction = transaction
        self.web3 = web3Instance
        self.contract = contract
        self.method = method
        self.transactionOptions = self.transactionOptions.merge(transactionOptions)
        if self.web3.provider.network != nil {
            self.transaction.chainID = self.web3.provider.network?.chainID
        }
    }
    
    public func callPromise(transactionOptions: TransactionOptions? = nil) -> Promise<[String: Any]> {
        let assembledTransaction : EthereumTransaction = self.transaction
        let queue = self.web3.requestDispatcher.queue
        let returnPromise = Promise<[String:Any]> { seal in
            let mergedOptions = self.transactionOptions.merge(transactionOptions)
            var optionsForCall = TransactionOptions()
            optionsForCall.from = mergedOptions.from
            optionsForCall.to = mergedOptions.to
            optionsForCall.value = mergedOptions.value
            optionsForCall.callOnBlock = mergedOptions.callOnBlock
            let callPromise : Promise<Data> = self.web3.eth.callPromise(assembledTransaction, transactionOptions: optionsForCall)
            callPromise.done(on: queue) {(data:Data) throws in
                do {
                    if (self.method == "fallback") {
                        let resultHex = data.toHexString().addHexPrefix()
                        seal.fulfill(["result": resultHex as Any])
                        return
                    }
                    guard let decodedData = self.contract.decodeReturnData(self.method, data: data) else
                    {
                        throw Web3Error.processingError(desc: "Can not decode returned parameters")
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
    
    public func estimateGasPromise(transactionOptions: TransactionOptions? = nil) -> Promise<BigUInt>{
        let assembledTransaction : EthereumTransaction = self.transaction
        let queue = self.web3.requestDispatcher.queue
        let returnPromise = Promise<BigUInt> { seal in
            let mergedOptions = self.transactionOptions.merge(transactionOptions)
            var optionsForGasEstimation = TransactionOptions()
            optionsForGasEstimation.from = mergedOptions.from
            optionsForGasEstimation.to = mergedOptions.to
            optionsForGasEstimation.value = mergedOptions.value
            optionsForGasEstimation.callOnBlock = mergedOptions.callOnBlock
            let promise = self.web3.eth.estimateGasPromise(assembledTransaction, transactionOptions: optionsForGasEstimation)
            promise.done(on: queue) {(estimate: BigUInt) in
                seal.fulfill(estimate)
                }.catch(on: queue) {err in
                    seal.reject(err)
            }
        }
        return returnPromise
    }
    
    public func estimateGas(transactionOptions: TransactionOptions? = nil) throws -> BigUInt {
        return try self.estimateGasPromise(transactionOptions: transactionOptions).wait()
    }
    
    public func call(transactionOptions: TransactionOptions? = nil) throws -> [String: Any] {
        return try self.callPromise(transactionOptions: transactionOptions).wait()
    }
}
