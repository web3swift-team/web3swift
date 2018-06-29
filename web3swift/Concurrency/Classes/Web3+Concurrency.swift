//
//  Web3+Concurrency.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import Result

public typealias Callback = ((Result<AnyObject, Web3Error>) -> ())

@available(*, deprecated)
public class OperationDispatcher {
    public var MAX_WAIT_TIME: TimeInterval = 0.2
    private var provider: Web3Provider
    private var queue: OperationQueue
    public var policy: DispatchPolicy
    private var pendingRequests = [Request]()
    private var schedulingOperation: Operation? = nil
    private var lockQueue: DispatchQueue

    init(provider: Web3Provider, queue: OperationQueue, policy: DispatchPolicy) {
        self.provider = provider
        self.queue = queue
        self.policy = policy
        self.lockQueue = DispatchQueue(label: "batchingQueue", qos: .userInitiated)
    }
    
    struct Request {
        var request: JSONRPCrequest
        var next: OperationChainingType
    }
    
    public enum DispatchPolicy {
        case Batch(UInt64)
        case NoBatching
    }
    
    final class ScheduleOperation: Operation {
        private var target: OperationDispatcher
        init(target: OperationDispatcher) {
            self.target = target
        }
        
        override func main() {
            Thread.sleep(forTimeInterval: target.MAX_WAIT_TIME)
            if self.isCancelled {
                return
            }
            target.lockQueue.async {
                self.target.triggerExecution()
            }
        }
    }
    
    func addToQueue(request: JSONRPCrequest, next: OperationChainingType) {
        switch self.policy {
        case .NoBatching:
            guard let result = self.provider.send(request: request) else {return processError(Web3Error.connectionError, next: next)}
            processSuccess(result as AnyObject, next: next)
        case .Batch(let maxLength):
            lockQueue.async {
                if self.pendingRequests.count == 0 {
                    let req = Request(request: request, next: next)
                    self.pendingRequests.append(req)
                    if (self.schedulingOperation == nil) {
                        let op = ScheduleOperation(target: self)
                        self.schedulingOperation = op
                        self.queue.addOperation(op)
                    }
                } else {
                    let req = Request(request: request, next: next)
                    self.pendingRequests.append(req)
                    if self.pendingRequests.count == maxLength {
                        if self.schedulingOperation != nil {
                            self.schedulingOperation?.cancel()
                            self.schedulingOperation = nil
                        }
                        self.triggerExecution()
                    }
                    return
                }
            }
        }
    }
    
    func triggerExecution() {
        lockQueue.async {
            if self.schedulingOperation != nil {
                self.schedulingOperation = nil
            }
            let allRequests = self.pendingRequests.compactMap { (r) -> Request in
                return r
            }
            self.pendingRequests.removeAll()
            let requestIDs = allRequests.map { (req) -> UInt64 in
                return req.request.id
            }
            let requests = allRequests.map{ (req) -> JSONRPCrequest in
                return req.request
            }
            let nexts = allRequests.map{ (req) -> OperationChainingType in
                return req.next
            }
            var mapping = [UInt64: OperationChainingType]()
            for i in 0 ..< requestIDs.count {
                if mapping[requestIDs[i]] == nil {
                    mapping[requestIDs[i]] = nexts[i]
                } else {
                    for next in nexts {
                        self.processError(Web3Error.nodeError("Concurrency error"), next: next)
                    }
                    return
                }
            }
            guard let responses = self.provider.send(requests: requests) else {
                for next in nexts {
                    self.processError(Web3Error.dataError, next: next)
                }
                return
            }
            for response in responses {
                if response != nil {
                    guard let id = response!["id"], let idUint = id as? UInt64 else {
                        for (_, v) in mapping {
                            self.processError(Web3Error.dataError, next: v)
                        }
                        return
                    }
                    guard let next = mapping[idUint] else {continue}
                    mapping.remove(at: mapping.index(forKey: idUint)!)
                    self.processSuccess(response as AnyObject, next: next)
                }
            }
            for (_, v) in mapping {
                self.processError(Web3Error.dataError, next: v)
            }
        }
    }
    
    func processError(_ error: Web3Error, next: OperationChainingType) {
        switch next {
        case .callback(let callback, let callbackQueue):
            callbackQueue.addOperation {
                let res = Result<AnyObject, Web3Error>.failure(error)
                callback(res)
            }
            return
        case .operation(let op):
            op.error = error
            op.expectedQueue.addOperation(op)
            return
        case .endOfChain:
            return
        }
    }
    
    func processSuccess(_ result: AnyObject, next: OperationChainingType) {
        switch next {
        case .callback(let callback, let callbackQueue):
            callbackQueue.addOperation {
                callback(Result<AnyObject,Web3Error>.success(result))
            }
            return
        case .operation(let op):
            op.inputData = result as AnyObject
            op.expectedQueue.addOperation(op)
            return
        case .endOfChain:
            return
        }
    }
}



public enum OperationChainingType {
    case callback(Callback, OperationQueue)
    case operation(Web3Operation)
    case endOfChain
}

protocol OperationProtocol{
    var inputData: AnyObject? {get set}
    var next: OperationChainingType? {get set}
    var expectedQueue: OperationQueue {get set}
    var error: Web3Error? {get set}
}

@available(*, deprecated)
public class Web3Operation: Operation, OperationProtocol {
    var web3: web3
    
    var next: OperationChainingType?
    var inputData: AnyObject?
    var expectedQueue: OperationQueue
    var error: Web3Error?
    
    init(_ web3Instance: web3, queue: OperationQueue? = nil, inputData: AnyObject? = nil ) {
        web3 = web3Instance
        if queue == nil {
            expectedQueue = self.web3.queue
        } else {
            expectedQueue = queue!
        }
        self.inputData = inputData
    }
    
    func processError(_ err: Web3Error) {
        guard let nextOp = next else {return}
        switch nextOp {
        case .callback(let callback, let callbackQueue):
            callbackQueue.addOperation {
                let res = Result<AnyObject, Web3Error>.failure(err)
                callback(res)
            }
            return
        case .operation(let op):
            op.error = err
            op.expectedQueue.addOperation(op)
            return
        case .endOfChain:
            return
        }
    }
    
    func processResult(_ result: Result<AnyObject, Web3Error>) {
        guard let nextOp = next else {return}
        switch nextOp {
        case .callback(let callback, let callbackQueue):
            callbackQueue.addOperation {
                callback(result)
            }
            return
        case .operation(let op):
            switch result{
            case .success(let res):
                op.inputData = res as AnyObject
            case .failure(let error):
                op.error = error
            }
            op.expectedQueue.addOperation(op)
            return
        case .endOfChain:
            return
        }
    }
    
    func processSuccess(_ result: AnyObject) {
        guard let nextOp = next else {return}
        switch nextOp {
        case .callback(let callback, let callbackQueue):
            callbackQueue.addOperation {
                callback(Result<AnyObject,Web3Error>.success(result))
            }
            return
        case .operation(let op):
            op.inputData = result as AnyObject
            op.expectedQueue.addOperation(op)
            return
        case .endOfChain:
            return
        }
    }
}

