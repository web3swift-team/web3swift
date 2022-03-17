//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

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


        func getTransactionCountPromises(names: [EthereumAddress]) async -> [BigUInt?]? {
            guard let w3 = self.web3 else {return nil}
            return await withTaskGroup(of: BigUInt?.self, returning: [BigUInt?].self) { group in
                for name in names {
                    group.addTask { try? await w3.eth.getTransactionCountPromise(address: name, onBlock: "latest")}
                }

                var promises = [BigUInt?]()

                for await result in group {
                    promises.append(result)
                }

                return promises
            }
        }

        public func functionToRun() async {
            let knownKeys = Array(self.nonceLookups.keys)
            guard let results = await getTransactionCountPromises(names: knownKeys) else {
                return
            }

            Task {
                var i = 0
                for res in results {
                    let key = knownKeys[i]
                    self.nonceLookups[key] = res
                    i = i + 1
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
            var newOptions = transactionOptions
            newOptions.nonce = .manual(newNonce)
            return (tx, contract, newOptions, true)
        }

        func postSubmissionFunction(result: TransactionSendingResult) {
            guard let from = result.transaction.sender else {
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
