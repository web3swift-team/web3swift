//
//  Web3+TransactionAndBlockDetailsOperations.swift
//  web3swift
//
//  Created by Alexander Vlasov on 06.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

@available(*, deprecated)
final class GetTransactionDetailsOperation: Web3Operation {
    
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, txHash: String) {
        self.init(web3Instance, queue: queue, inputData: txHash as AnyObject)
    }
    
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, txHash: Data) {
        self.init(web3Instance, queue: queue, inputData: txHash.toHexString().addHexPrefix() as AnyObject)
    }
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let completion = self.next else {return}
        guard inputData != nil else {return}
        guard let txhash = inputData! as? String else {return processError(Web3Error.inputError("Invalid transaction hash supplied"))}
        let request = JSONRPCRequestFabric.prepareRequest(.getTransactionByHash, parameters: [txhash])
        let dataOp = DataFetchOperation(self.web3, queue: self.expectedQueue)
        dataOp.inputData = request as AnyObject
        let convOp = DictionaryConversionOperation(self.web3, queue: self.expectedQueue)
        dataOp.next = OperationChainingType.operation(convOp)
        let parsingOp = TransactionDetailsConversionOperation(self.web3, queue: self.expectedQueue)
        convOp.next = OperationChainingType.operation(parsingOp)
        parsingOp.next = completion
        self.expectedQueue.addOperation(dataOp)
    }
}

@available(*, deprecated)
final class GetTransactionReceiptOperation: Web3Operation {
    
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, txHash: String) {
        self.init(web3Instance, queue: queue, inputData: txHash as AnyObject)
    }
    
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, txHash: Data) {
        self.init(web3Instance, queue: queue, inputData: txHash.toHexString().addHexPrefix() as AnyObject)
    }
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let completion = self.next else {return}
        guard inputData != nil else {return}
        guard let txhash = inputData! as? String else {return processError(Web3Error.inputError("Invalid transaction hash supplied"))}
        let request = JSONRPCRequestFabric.prepareRequest(.getTransactionReceipt, parameters: [txhash])
        let dataOp = DataFetchOperation(self.web3, queue: self.expectedQueue)
        dataOp.inputData = request as AnyObject
        let convOp = DictionaryConversionOperation(self.web3, queue: self.expectedQueue)
        dataOp.next = OperationChainingType.operation(convOp)
        let parsingOp = TransactionReceiptConversionOperation(self.web3, queue: self.expectedQueue)
        convOp.next = OperationChainingType.operation(parsingOp)
        parsingOp.next = completion
        self.expectedQueue.addOperation(dataOp)
    }
}

@available(*, deprecated)
final class GetBlockByNumberOperation: Web3Operation {
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, blockNumber: UInt64, fullTransactions: Bool = false) {
        let blockNumberString = String(blockNumber, radix: 16).addHexPrefix()
        self.init(web3Instance, queue: queue, blockNumber: blockNumberString, fullTransactions: fullTransactions)
    }
    
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, blockNumber: BigUInt, fullTransactions: Bool = false) {
        let blockNumberString = String(blockNumber, radix: 16).addHexPrefix()
        self.init(web3Instance, queue: queue, blockNumber: blockNumberString, fullTransactions: fullTransactions)
    }
    
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, blockNumber: String, fullTransactions: Bool = false) {
        self.init(web3Instance, queue: queue, inputData: [blockNumber, fullTransactions] as AnyObject)
    }
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let completion = self.next else {return}
        guard inputData != nil else {return}
        guard let input = inputData! as? [AnyObject] else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard input.count == 2 else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let block = input[0] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let fullTX = input[1] as? Bool else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let request = JSONRPCRequestFabric.prepareRequest(.getBlockByNumber, parameters: [block, fullTX])
        let dataOp = DataFetchOperation(self.web3, queue: self.expectedQueue)
        dataOp.inputData = request as AnyObject
        let convOp = JSONasDataConversionOperation(self.web3, queue: self.expectedQueue)
        dataOp.next = OperationChainingType.operation(convOp)
        let parsingOp = BlockConversionOperation(self.web3, queue: self.expectedQueue)
        convOp.next = OperationChainingType.operation(parsingOp)
        parsingOp.next = completion
        self.expectedQueue.addOperation(dataOp)
    }
}

@available(*, deprecated)
final class GetBlockByHashOperation: Web3Operation {
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, hash: String, fullTransactions: Bool = false) {
        self.init(web3Instance, queue: queue, inputData: [hash, fullTransactions] as AnyObject)
    }
    
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, hash: Data, fullTransactions: Bool = false) {
        let h = hash.toHexString().addHexPrefix()
        self.init(web3Instance, queue: queue, inputData: [h, fullTransactions] as AnyObject)
    }
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let completion = self.next else {return}
        guard inputData != nil else {return}
        guard let input = inputData! as? [AnyObject] else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard input.count == 2 else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let block = input[0] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let fullTX = input[1] as? Bool else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let request = JSONRPCRequestFabric.prepareRequest(.getBlockByHash, parameters: [block, fullTX])
        let dataOp = DataFetchOperation(self.web3, queue: self.expectedQueue)
        dataOp.inputData = request as AnyObject
        let convOp = JSONasDataConversionOperation(self.web3, queue: self.expectedQueue)
        dataOp.next = OperationChainingType.operation(convOp)
        let parsingOp = BlockConversionOperation(self.web3, queue: self.expectedQueue)
        convOp.next = OperationChainingType.operation(parsingOp)
        parsingOp.next = completion
        self.expectedQueue.addOperation(dataOp)
    }
}
