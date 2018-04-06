//
//  Web3+Concurrency.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import Result

typealias Callback = ((Result<AnyObject, Web3Error>) -> ())

enum OperationChainingType {
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

class Web3Operation: Operation, OperationProtocol {
    var web3: web3
    
    var next: OperationChainingType?
    var inputData: AnyObject?
    var expectedQueue: OperationQueue
    var error: Web3Error?
    
    init(_ web3Instance: web3, queue: OperationQueue? = nil, inputData: AnyObject? = nil ) {
        web3 = web3Instance
        if queue == nil {
            expectedQueue = OperationQueue.main
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

