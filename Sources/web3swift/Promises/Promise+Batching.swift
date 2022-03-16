//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

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
        self.batches.append(Batch(provider: provider, capacity: 32, queue: queue, lockQueue: lockQueue))
    }
    
    internal final class Batch {
        var capacity: Int
        var promisesDict = [UInt64]()
        var jsonRPCresponseHandlers: [(UInt64, ([JSONRPCresponse])-> Void)] = []
        var requests: [JSONRPCrequest] = [JSONRPCrequest]()
        var pendingTrigger: Bool = true
        var provider: Web3Provider
        var queue: DispatchQueue
        var lockQueue : DispatchQueue
        var triggered : Bool = false
        func add(_ request: JSONRPCrequest, jsonRPCresponseHandler: @escaping ([JSONRPCresponse])-> Void, maxWaitTime: TimeInterval) async throws {
            if triggered {
                throw Web3Error.nodeError(desc: "Batch is already in flight")
            }
            let requestID = request.id

            if promisesDict.contains(requestID) {
                throw Web3Error.processingError(desc: "Request ID collision")
            } else {
                promisesDict.append(requestID)
                jsonRPCresponseHandlers.append((requestID, jsonRPCresponseHandler))
            }
            requests.append(request)
            if pendingTrigger {
                pendingTrigger.toggle()
                try? await Task.sleep(nanoseconds: UInt64(maxWaitTime) * 1_000_000_000)
                try await trigger()
            }
            if requests.count == capacity {
                try await trigger()
            }
        }

        func trigger() async throws {
            Task {
                if triggered {
                    return
                }
                triggered = true
                let requestsBatch = JSONRPCrequestBatch(requests: requests)
                let batch = try await provider.sendAsync(requestsBatch)
                jsonRPCresponseHandlers.forEach { (requestID, function) in
                    function(batch.responses.filter { response in response.id == requestID })

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
        guard case .Batch(let batchLength) = policy, let currentBatch = batches.last else {
            throw Web3Error.inputError(desc: "Trying to batch a request when policy is not to batch")
        }
        if currentBatch.requests.count.isMultiple(of: batchLength) || currentBatch.triggered {
            let newBatch = Batch(provider: provider, capacity: Int(batchLength), queue: queue, lockQueue: lockQueue)
            batches.append(newBatch)
            return newBatch
        }
        return currentBatch
    }
    
    public enum DispatchPolicy {
        case Batch(Int)
        case NoBatching
    }
    //TODO: we should spilt these out so not confusing which way value is being retruned
    func addToQueue(request: JSONRPCrequest, jsonRPCresponseHandler: @escaping([JSONRPCresponse])-> Void) async throws -> JSONRPCresponse? {
        switch policy {
        case .NoBatching:
            return try await provider.sendAsync(request)
        case .Batch(_):
            let batch = try getBatch()
            try await batch.add(request, jsonRPCresponseHandler: jsonRPCresponseHandler, maxWaitTime: MAX_WAIT_TIME)
        }
        return nil
    }
}
