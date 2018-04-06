//
//  Web3+EventOperations.swift
//  web3swift
//
//  Created by Alexander Vlasov on 06.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import Result
import BigInt

final class ParseBlockForEventsOperation: Web3Operation {
    
    convenience init?(_ web3Instance: web3, queue: OperationQueue? = nil, contract: ContractProtocol, eventName: String, filter: EventFilter? = nil, block: UInt64) {
        let blockString = String(block, radix: 16).addHexPrefix()
        self.init(web3Instance, queue: queue, contract: contract, eventName: eventName, filter: filter, block: blockString)
    }
    
    convenience init?(_ web3Instance: web3, queue: OperationQueue? = nil, contract: ContractProtocol, eventName: String, filter: EventFilter? = nil, block: BigUInt) {
        let blockString = String(block, radix: 16).addHexPrefix()
        self.init(web3Instance, queue: queue, contract: contract, eventName: eventName, filter: filter, block: blockString)
    }
    
    convenience init?(_ web3Instance: web3, queue: OperationQueue? = nil, contract: ContractProtocol, eventName: String, filter: EventFilter? = nil, block: String = "latest") {
        guard let _ = contract.allEvents.index(of: eventName) else {return nil}
        self.init(web3Instance, queue: queue, inputData: [contract, eventName, filter as Any, block] as AnyObject)
    }
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let _ = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [AnyObject] else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard input.count == 4 else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let contract = input[0] as? ContractProtocol else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let eventName = input[1] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let filter = input[2] as? EventFilter
        guard let blockNumber = input[3] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let getBlockOperation = GetBlockByNumberOperation.init(self.web3, queue: self.expectedQueue, blockNumber: blockNumber, fullTransactions: false)
        var resultsArray = [EventParserResultProtocol]()
        let lockQueue = DispatchQueue.init(label: "org.bankexfoundation.LockQueue")
        var expectedOperations = 0
        var earlyReturn = false
        let joiningCallback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                lockQueue.sync() {
                    expectedOperations = expectedOperations - 1
                    guard let ev = result as? [EventParserResultProtocol] else {
                        if (!earlyReturn) {
                            earlyReturn = true
                            return self.processError(Web3Error.dataError)
                        } else {
                            return
                        }
                    }
                    resultsArray.append(contentsOf: ev)
                    guard let currentQueue = OperationQueue.current else {
                        if (!earlyReturn) {
                            earlyReturn = true
                            return self.processError(Web3Error.dataError)
                        } else {
                            return
                        }
                    }
                    
                    if expectedOperations == 0 {
                        if (!earlyReturn) {
                            earlyReturn = true
                            currentQueue.underlyingQueue?.async(execute: {
                                let allEvents = resultsArray.flatMap({ (ev) -> EventParserResultProtocol in
                                    return ev
                                })
                                self.processSuccess(allEvents as AnyObject)
                            })
                        } else {
                            return
                        }
                    }
                }
            case .failure(let error):
                lockQueue.sync() {
                    if (!earlyReturn) {
                        earlyReturn = true
                        return self.processError(error)
                    } else {
                        return
                    }
                }
            }
        }
        
        let blockCallback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                guard let block = result as? Block else {
                    return self.processError(Web3Error.dataError)
                }
                guard let bloom = block.logsBloom else {return self.processError(Web3Error.dataError)}
                if contract.address != nil {
                    let addressPresent = block.logsBloom?.test(topic: contract.address!.addressData)
                    if (addressPresent != true) {
                        return self.processSuccess(resultsArray as AnyObject)
                    }
                }
                guard let eventOfSuchTypeIsPresent = contract.testBloomForEventPrecence(eventName: eventName, bloom: bloom) else {return self.processError(Web3Error.dataError)}
                if (!eventOfSuchTypeIsPresent) {
                    return self.processSuccess(resultsArray as AnyObject)
                }
                var allOps = [Web3Operation]()
                for transaction in block.transactions {
                    guard case .hash(let hash) = transaction else {
                        self.processError(Web3Error.dataError)
                        return
                    }
                    guard let parseOperation = ParseTransactionForEventsOperation.init(self.web3, contract: contract, eventName: eventName, filter: filter, transactionHash: hash) else {
                        self.processError(Web3Error.dataError)
                        return
                    }
                    parseOperation.next = OperationChainingType.callback(joiningCallback, self.expectedQueue)
                    allOps.append(parseOperation)
                }
                expectedOperations = allOps.count
                self.expectedQueue.addOperations(allOps, waitUntilFinished: true)
            case .failure(let error):
                return self.processError(error)
            }
        }
        getBlockOperation.next = OperationChainingType.callback(blockCallback, self.expectedQueue)
        self.expectedQueue.addOperation(getBlockOperation)
    }
}

final class ParseTransactionForEventsOperation: Web3Operation {
    
    convenience init?(_ web3Instance: web3, queue: OperationQueue? = nil, contract: ContractProtocol, eventName: String, filter: EventFilter? = nil, transactionHash: Data) {
        let hash = transactionHash.toHexString().addHexPrefix()
        self.init(web3Instance, queue: queue, contract: contract, eventName: eventName, filter: filter, transactionHash: hash)
    }
    
    convenience init?(_ web3Instance: web3, queue: OperationQueue? = nil, contract: ContractProtocol, eventName: String, filter: EventFilter? = nil, transaction: EthereumTransaction) {
        guard let hash = transaction.hash else {return nil}
        self.init(web3Instance, queue: queue, contract: contract, eventName: eventName, filter: filter, transactionHash: hash)
    }
    
    convenience init?(_ web3Instance: web3, queue: OperationQueue? = nil, contract: ContractProtocol, eventName: String, filter: EventFilter? = nil, transactionHash: String) {
        self.init(web3Instance, queue: queue, inputData: [contract, eventName, filter as Any, transactionHash] as AnyObject)
    }
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let _ = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [AnyObject] else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard input.count == 4 else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let contract = input[0] as? ContractProtocol else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let eventName = input[1] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let filter = input[2] as? EventFilter
        guard let transactionHash = input[3] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let receiptOperation = GetTransactionReceiptOperation.init(self.web3, queue: self.expectedQueue, txHash: transactionHash)

        let receiptCallback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                var allEvents = [EventParserResultProtocol]()
                guard let receipt = result as? TransactionReceipt else {
                    return self.processError(Web3Error.dataError)
                }
                guard let bloom = receipt.logsBloom else {
                    return self.processError(Web3Error.dataError)
                }
                if contract.address != nil {
                    let addressPresent = bloom.test(topic: contract.address!.addressData)
                    if (addressPresent != true) {
                        return self.processSuccess(allEvents as AnyObject)
                    }
                }
                guard let eventOfSuchTypeIsPresent = contract.testBloomForEventPrecence(eventName: eventName, bloom: bloom) else {
                    return self.processError(Web3Error.dataError)
                }
                if (!eventOfSuchTypeIsPresent) {
                    return self.processSuccess(allEvents as AnyObject)
                }
                var allLogs = receipt.logs
                if contract.address != nil {
                    allLogs = receipt.logs.filter({ (log) -> Bool in
                        log.address == contract.address
                    })
                }
                let decodedLogs = allLogs.flatMap({ (log) -> EventParserResultProtocol? in
                    let (n, d) = contract.parseEvent(log)
                    guard let evName = n, let evData = d else {return nil}
                    return EventParserResult(eventName: evName, transactionReceipt: receipt, contractAddress: log.address, decodedResult: evData)
                }).filter { (res:EventParserResultProtocol?) -> Bool in
                    return res != nil && res?.eventName == eventName
                }
                
                if (filter != nil) {
                    // TODO NYI
                    allEvents = decodedLogs
                } else {
                    allEvents = decodedLogs
                }
                return self.processSuccess(allEvents as AnyObject)
            case .failure(let error):
                return self.processError(error)
            }
        }
        receiptOperation.next = OperationChainingType.callback(receiptCallback, self.expectedQueue)
        self.expectedQueue.addOperation(receiptOperation)
    }
}
