//
//  Web3+TransactionOperations.swift
//  web3swift
//
//  Created by Alexander Vlasov on 06.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import Result
import BigInt

final class ContractCallOperation: Web3Operation {
    var method: String?
    
    convenience init?(_ web3Instance: web3, queue: OperationQueue? = nil, intermediate: TransactionIntermediate, onBlock: String = "latest", options: Web3Options? = nil) {
        self.init(web3Instance, queue: queue, inputData: [intermediate, options as Any, onBlock] as AnyObject)
        self.method = intermediate.method
    }
    
    convenience init?(_ web3Instance: web3, queue: OperationQueue? = nil, contract: web3.web3contract, method: String = "fallback", parameters: [AnyObject] = [], extraData: Data = Data(), options: Web3Options? = nil, onBlock: String = "latest") {
        guard let intermediate = contract.method(method, parameters: parameters, extraData: extraData, options: options) else {return nil}
        self.init(web3Instance, queue: queue, inputData: [intermediate, options as Any, onBlock] as AnyObject)
        self.method = method
    }
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let _ = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [AnyObject] else {return processError(Web3Error.inputError("Invalid input supplied"))}
        
        guard input.count == 3 else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let intermediate = input[0] as? TransactionIntermediate else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let options = input[1] as? Web3Options
        guard let onBlock = input[2] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard var mergedOptions = Web3Options.merge(intermediate.options, with: options) else {return processError(Web3Error.inputError("Invalid input supplied"))}
        mergedOptions.gasLimit = nil
        if (options?.gasLimit != nil) {
            mergedOptions.gasLimit = options?.gasLimit
        }
        guard let _ = mergedOptions.from else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let transaction = intermediate.transaction

        let parsingCallback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                guard let resultData = result as? Data else {
                    return self.processError(Web3Error.dataError)
                }
                if (self.method == "fallback") {
                    let resultHex = resultData.toHexString().addHexPrefix()
                    return self.processSuccess(["result": resultHex as Any] as AnyObject)
                }
                guard let method = self.method else {
                    return self.processError(Web3Error.dataError)
                }
                guard let decodedData = intermediate.contract.decodeReturnData(method, data: resultData) else
                {
                    return self.processError(Web3Error.dataError)
                }
                return self.processSuccess(decodedData as AnyObject)
            case .failure(let error):
                return self.processError(error)
            }
        }
        let tx = transaction.mergedWithOptions(mergedOptions)
        guard let request = EthereumTransaction.createRequest(method: JSONRPCmethod.call, transaction: tx, onBlock: onBlock, options: mergedOptions) else {return self.processError(Web3Error.inputError("Invalid input supplied"))}
        let dataOp = DataFetchOperation(self.web3, queue: self.expectedQueue)
        dataOp.inputData = request as AnyObject
        let parsingOp = DataConversionOperation(self.web3, queue: self.expectedQueue)
        dataOp.next = OperationChainingType.operation(parsingOp)
        parsingOp.next = OperationChainingType.callback(parsingCallback, self.expectedQueue)
        self.expectedQueue.addOperation(dataOp)
        
//        let gasEstimationCallback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                guard let gasEstimate = result as? BigUInt else {
//                    return self.processError(Web3Error.dataError)
//                }
////                if mergedOptions.gasLimit == nil {
////                    mergedOptions.gasLimit = gasEstimate
////                } else {
////                    if (mergedOptions.gasLimit! < gasEstimate) {
////                        if (options?.gasLimit != nil && options!.gasLimit != nil && options!.gasLimit! >=  gasEstimate) {
////                            mergedOptions.gasLimit = options!.gasLimit!
////                        } else {
////                            return self.processError(Web3Error.inputError("Estimated gas is larger than the gas limit"))
////                        }
////                    }
////                }
//                guard let request = EthereumTransaction.createRequest(method: JSONRPCmethod.call, transaction: transaction, onBlock: onBlock, options: mergedOptions) else {return self.processError(Web3Error.inputError("Invalid input supplied"))}
//                let dataOp = DataFetchOperation(self.web3, queue: self.expectedQueue)
//                dataOp.inputData = request as AnyObject
//                let parsingOp = DataConversionOperation(self.web3, queue: self.expectedQueue)
//                dataOp.next = OperationChainingType.operation(parsingOp)
//                parsingOp.next = OperationChainingType.callback(parsingCallback, self.expectedQueue)
//                self.expectedQueue.addOperation(dataOp)
//                return
//            case .failure(let error):
//                return self.processError(error)
//            }
//        }
//
//        guard let gasEstimateOperation = ContractEstimateGasOperation.init(self.web3, queue: self.expectedQueue, intermediate: intermediate, onBlock: onBlock) else {return self.processError(Web3Error.dataError)}
//        gasEstimateOperation.next = OperationChainingType.callback(gasEstimationCallback, self.expectedQueue)
//        self.expectedQueue.addOperation(gasEstimateOperation)

    }
}


final class ContractEstimateGasOperation: Web3Operation {
    
    convenience init?(_ web3Instance: web3, queue: OperationQueue? = nil, contract: web3.web3contract, method: String = "fallback", parameters: [AnyObject] = [], extraData: Data = Data(), options: Web3Options?, onBlock: String = "latest") {
        guard let intermediate = contract.method(method, parameters: parameters, extraData: extraData, options: options) else {return nil}
        self.init(web3Instance, queue: queue, inputData: [intermediate, onBlock] as AnyObject)
    }
    
    convenience init?(_ web3Instance: web3, queue: OperationQueue? = nil, intermediate: TransactionIntermediate, onBlock: String = "latest") {
        self.init(web3Instance, queue: queue, inputData: [intermediate, onBlock] as AnyObject)
    }
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let completion = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [AnyObject] else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard input.count == 2 else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let intermediate = input[0] as? TransactionIntermediate else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let onBlock = input[1] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let sendOp = EstimateGasOperation(web3, queue: expectedQueue, transactionIntermediate: intermediate, onBlock: onBlock)
        sendOp.next = completion
        self.expectedQueue.addOperation(sendOp)
    }
}

final class ContractSendOperation: Web3Operation {
    
    convenience init?(_ web3Instance: web3, queue: OperationQueue? = nil, contract: web3.web3contract, method: String = "fallback", parameters: [AnyObject] = [], extraData: Data = Data(), options: Web3Options?, onBlock: String = "pending", password: String = "BANKEXFOUNDATION") {
        guard let intermediate = contract.method(method, parameters: parameters, extraData: extraData, options: options) else {return nil}
        self.init(web3Instance, queue: queue, inputData: [intermediate, password, onBlock, options as Any] as AnyObject)
    }
    
    convenience init?(_ web3Instance: web3, queue: OperationQueue? = nil, intermediate: TransactionIntermediate, options: Web3Options? = nil, onBlock: String = "pending", password: String = "BANKEXFOUNDATION") {
        self.init(web3Instance, queue: queue, inputData: [intermediate, password, onBlock, options as Any] as AnyObject)
    }
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let completion = self.next else {return processError(Web3Error.inputError("No completion handler supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("No input data supploed"))}
        guard let input = inputData! as? [AnyObject] else {return processError(Web3Error.inputError("Invalid input data supplied"))}
        guard input.count == 4 else {return processError(Web3Error.inputError("Invalid number of inputs supplied"))}
        guard let intermediate = input[0] as? TransactionIntermediate else {return processError(Web3Error.inputError("Invalid transaction intermediate supplied"))}
        guard let password = input[1] as? String else {return processError(Web3Error.inputError("Invalid (no) password supplied"))}
        guard let onBlock = input[2] as? String else {return processError(Web3Error.inputError("Invalid onBlock supplied"))}
        let options = input[3] as? Web3Options
        guard var mergedOptions = Web3Options.merge(intermediate.options, with: options) else {return processError(Web3Error.inputError("Can not merge options"))}
        guard let from = mergedOptions.from else {return processError(Web3Error.inputError("Invalid from supplied"))}
        
        
        let gasEstimationCallback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                guard let gasEstimate = result as? BigUInt else {
                    return self.processError(Web3Error.dataError)
                }
                guard let gasEstimateMerged = Web3Options.smartMergeGasLimit(originalOptions: intermediate.options, extraOptions: options, gasEstimage: gasEstimate) else {
                    return self.processError(Web3Error.inputError("Estimated gas is larger than the gas limit"))
                }
                mergedOptions.gasLimit = gasEstimateMerged
                let transaction = intermediate.transaction
                intermediate.transaction = transaction.mergedWithOptions(mergedOptions)
                intermediate.options = mergedOptions
                
                let sendOp = SendTransactionOperation.init(self.web3, queue: self.expectedQueue, transactionIntermediate: intermediate, password: password)
                sendOp.next = completion
                self.expectedQueue.addOperation(sendOp)
                return
            case .failure(let error):
                return self.processError(error)
            }
        }
    
        let nonceCallback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                guard let nonce = result as? BigUInt else {
                    return self.processError(Web3Error.dataError)
                }
                var transaction = intermediate.transaction
                if self.web3.provider.network != nil {
                    transaction.chainID = self.web3.provider.network?.chainID
                }
                transaction.nonce = nonce
                intermediate.transaction = transaction
                guard let gasEstimateOperation = ContractEstimateGasOperation.init(self.web3, queue: self.expectedQueue, intermediate: intermediate, onBlock: onBlock) else {return self.processError(Web3Error.dataError)}
                gasEstimateOperation.next = OperationChainingType.callback(gasEstimationCallback, self.expectedQueue)
                self.expectedQueue.addOperation(gasEstimateOperation)
                return
            case .failure(let error):
                return self.processError(error)
            }
        }
        
        let gasPriceCallback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                guard let gasPrice = result as? BigUInt else {
                    return self.processError(Web3Error.dataError)
                }
                if mergedOptions.gasPrice == nil {
                    mergedOptions.gasPrice = gasPrice
                }
                let transaction = intermediate.transaction
                intermediate.transaction = transaction.mergedWithOptions(mergedOptions)
                intermediate.options = mergedOptions
                
                let nonceOp = GetTransactionCountOperation.init(self.web3, queue: self.expectedQueue, address: from, onBlock: onBlock)
                nonceOp.next = OperationChainingType.callback(nonceCallback, self.expectedQueue)
                self.expectedQueue.addOperation(nonceOp)
                return
            case .failure(let error):
                return self.processError(error)
            }
        }
        
        let gasPriceOp = GetGasPriceOperation.init(self.web3, queue: self.expectedQueue)
        gasPriceOp.next = OperationChainingType.callback(gasPriceCallback, self.expectedQueue)
        self.expectedQueue.addOperation(gasPriceOp)
    }
}
