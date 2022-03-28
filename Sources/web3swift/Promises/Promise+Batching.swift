//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import PromiseKit

public class JSONRPCrequestDispatcher {
    public var MAX_WAIT_TIME: TimeInterval = 0.1
    public var policy: DispatchPolicy
    public var queue: DispatchQueue

    private var provider: Web3Provider
    private var lockQueue: DispatchQueue
    private var batches: [Batch] = [Batch]()

    public init(provider: Web3Provider, queue: DispatchQueue, policy: DispatchPolicy) {
        self.provider = provider
        self.queue = queue
        self.policy = policy
        self.lockQueue = DispatchQueue.init(label: "batchingQueue") // serial simplest queue
        self.batches.append(Batch(provider: self.provider, capacity: 32, queue: self.queue, lockQueue: self.lockQueue))
    }

    internal final class Batch {
        var capacity: Int
        var promisesDict: [UInt64: (promise: Promise<JSONRPCresponse>, resolver: Resolver<JSONRPCresponse>)] = [UInt64: (promise: Promise<JSONRPCresponse>, resolver: Resolver<JSONRPCresponse>)]()
        var requests: [JSONRPCrequest] = [JSONRPCrequest]()
        var pendingTrigger: Guarantee<Void>?
        var provider: Web3Provider
        var queue: DispatchQueue
        var lockQueue: DispatchQueue
        var triggered: Bool = false
        func add(_ request: JSONRPCrequest, maxWaitTime: TimeInterval) throws -> Promise<JSONRPCresponse> {
            if self.triggered {
                throw Web3Error.nodeError(desc: "Batch is already in flight")
            }
            let requestID = request.id
            let promiseToReturn = Promise<JSONRPCresponse>.pending()
            self.lockQueue.async {
                if self.promisesDict[requestID] != nil {
                    promiseToReturn.resolver.reject(Web3Error.processingError(desc: "Request ID collision"))
                }
                self.promisesDict[requestID] = promiseToReturn
                self.requests.append(request)
                if self.pendingTrigger == nil {
                    self.pendingTrigger = after(seconds: maxWaitTime).done(on: self.queue) {
                        self.trigger()
                    }
                }
                if self.requests.count == self.capacity {
                    self.trigger()
                }
            }
            return promiseToReturn.promise
        }

        func trigger() {
            self.lockQueue.async {
                if self.triggered {
                    return
                }
                self.triggered = true
                let requestsBatch = JSONRPCrequestBatch(requests: self.requests)
                _ = self.provider.sendAsync(requestsBatch, queue: self.queue).done(on: self.queue) { batch in
                    for response in batch.responses {
                        if self.promisesDict[UInt64(response.id)] == nil {
                            for k in self.promisesDict.keys {
                                self.promisesDict[k]?.resolver.reject(Web3Error.nodeError(desc: "Unknown request id"))
                            }
                            return
                        }
                    }
                    for response in batch.responses {
                        let promise = self.promisesDict[UInt64(response.id)]!
                        promise.resolver.fulfill(response)
                    }
                }.catch(on: self.queue) {err in
                    for k in self.promisesDict.keys {
                        self.promisesDict[k]?.resolver.reject(err)
                    }
                }
            }
        }

        init (provider: Web3Provider, capacity: Int, queue: DispatchQueue, lockQueue: DispatchQueue) {
            self.provider = provider
            self.capacity = capacity
            self.queue = queue
            self.lockQueue = lockQueue
        }
    }

    func getBatch() throws -> Batch {
        guard case .Batch(let batchLength) = self.policy else {
            throw Web3Error.inputError(desc: "Trying to batch a request when policy is not to batch")
        }
        let currentBatch = self.batches.last!
        if currentBatch.requests.count.isMultiple(of: batchLength) || currentBatch.triggered {
            let newBatch = Batch(provider: self.provider, capacity: Int(batchLength), queue: self.queue, lockQueue: self.lockQueue)
            self.batches.append(newBatch)
            return newBatch
        }
        return currentBatch
    }

    public enum DispatchPolicy {
        case Batch(Int)
        case NoBatching
    }

    func addToQueue(request: JSONRPCrequest) -> Promise<JSONRPCresponse> {
        switch self.policy {
        case .NoBatching:
            return self.provider.sendAsync(request, queue: self.queue)
        case .Batch(_):
            let promise = Promise<JSONRPCresponse> {
                seal in
                self.lockQueue.async {
                    do {
                        let batch = try self.getBatch()
                        let internalPromise = try batch.add(request, maxWaitTime: self.MAX_WAIT_TIME)
                        internalPromise.done(on: self.queue) {resp in
                            seal.fulfill(resp)
                        }.catch(on: self.queue){ err in
                            seal.reject(err)
                        }
                    } catch {
                        seal.reject(error)
                    }
                }
            }
            return promise
        }
    }
}
