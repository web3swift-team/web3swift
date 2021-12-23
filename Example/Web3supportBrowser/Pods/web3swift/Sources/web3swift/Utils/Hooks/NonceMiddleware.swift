//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
//import EthereumAddress
import BigInt
import PromiseKit

extension Web3.Utils {
    
    fileprivate typealias AssemblyHook = web3.AssemblyHook
    fileprivate typealias SubmissionResultHook = web3.SubmissionResultHook
    
    public class NonceMiddleware: EventLoopRunnableProtocol {
        var web3: web3?
        var nonceLookups: [EthereumAddress: BigUInt] = [EthereumAddress: BigUInt]()
        public var name: String = "Nonce lookup middleware"
        public let queue: DispatchQueue = DispatchQueue(label: "Nonce middleware queue")
        public var synchronizationPeriod: TimeInterval = 300.0 // 5 minutes
        var lastSyncTime: Date = Date()
        
        public func functionToRun() {
            guard let w3 = self.web3 else {return}
            var allPromises = [Promise<BigUInt>]()
            allPromises.reserveCapacity(self.nonceLookups.keys.count)
            let knownKeys = Array(self.nonceLookups.keys)
            for k in knownKeys {
                let promise = w3.eth.getTransactionCountPromise(address: k, onBlock: "latest")
                allPromises.append(promise)
            }
            when(resolved: allPromises).done(on: w3.requestDispatcher.queue) {results in
                self.queue.async {
                    var i = 0
                    for res in results {
                        switch res {
                        case .fulfilled(let newNonce):
                            let key = knownKeys[i]
                            self.nonceLookups[key] = newNonce
                            i = i + 1
                        default:
                            i = i + 1
                        }
                    }
                }
                
            }
        }
        
        public init() {
            
        }
        
        func preAssemblyFunction(tx: EthereumTransaction, contract: EthereumContract, transactionOptions: TransactionOptions) -> (EthereumTransaction, EthereumContract, TransactionOptions, Bool) {
            guard let from = transactionOptions.from else {
                // do nothing
                return (tx, contract, transactionOptions, true)
            }
            guard let knownNonce = self.nonceLookups[from] else {
                return (tx, contract, transactionOptions, true)
            }

            let newNonce = knownNonce + 1

            self.queue.async {
                self.nonceLookups[from] = newNonce
            }
            //            var modifiedTX = tx
            //            modifiedTX.nonce = newNonce
            var newOptions = transactionOptions
            newOptions.nonce = .manual(newNonce)
            return (tx, contract, newOptions, true)
        }
        
        func postSubmissionFunction(result: TransactionSendingResult) {
            guard let from = result.transaction.sender else {
                // do nothing
                return
            }
            
            let newNonce = result.transaction.nonce
            
            if let knownNonce = self.nonceLookups[from] {
                if knownNonce != newNonce {
                    self.queue.async {
                        self.nonceLookups[from] = newNonce
                    }
                }
                return
            }
            self.queue.async {
                self.nonceLookups[from] = newNonce
            }
            return
        }
        
        public func attach(_ web3: web3) {
            self.web3 = web3
            web3.eventLoop.monitoredUserFunctions.append(self)
            let preHook = AssemblyHook(queue: web3.requestDispatcher.queue, function: self.preAssemblyFunction)
            web3.preAssemblyHooks.append(preHook)
            let postHook = SubmissionResultHook(queue: web3.requestDispatcher.queue, function: self.postSubmissionFunction)
            web3.postSubmissionHooks.append(postHook)
        }
        
    }
    
    
}
