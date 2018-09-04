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
        guard let completion = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [AnyObject] else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard input.count == 4 else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let contract = input[0] as? ContractProtocol else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let eventName = input[1] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let filter = input[2] as? EventFilter
        guard let blockNumber = input[3] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let getBlockOperation = GetBlockByNumberOperation.init(self.web3, queue: self.expectedQueue, blockNumber: blockNumber, fullTransactions: false)
        let resultsArray = [EventParserResultProtocol]()
        
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
                    allOps.append(parseOperation)
                }
                let joinOperation = JoinOperation(self.web3, queue: self.expectedQueue, operations: allOps)
                let conversionOp = ConversionOperation<[EventParserResultProtocol]>(self.web3, queue: self.expectedQueue)
                joinOperation.next = OperationChainingType.operation(conversionOp)
                conversionOp.next = completion
                self.expectedQueue.addOperation(joinOperation)
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
                guard let receipt = result as? TransactionReceipt else {
                    return self.processError(Web3Error.dataError)
                }
                guard let allEvents = parseReceiptForLogs(receipt: receipt, contract: contract, eventName: eventName, filter: filter) else {return self.processError(Web3Error.dataError)}
                return self.processSuccess(allEvents as AnyObject)
            case .failure(let error):
                return self.processError(error)
            }
        }
        receiptOperation.next = OperationChainingType.callback(receiptCallback, self.expectedQueue)
        self.expectedQueue.addOperation(receiptOperation)
    }
}
