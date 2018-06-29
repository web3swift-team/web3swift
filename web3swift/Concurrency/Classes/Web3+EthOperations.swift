//
//  Web3+ProcessingOperations.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import Result
import BigInt


@available(*, deprecated)
final class GetAccountsOperation: Web3Operation {
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let completion = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        if (self.web3.provider.attachedKeystoreManager != nil) {
            let result = self.web3.wallet.getAccounts()
            switch result {
            case .success(let allAccounts):
                return processSuccess(allAccounts as AnyObject)
            case .failure(let error):
                return processError(error)
            }
        }
        let request = JSONRPCRequestFabric.prepareRequest(.getAccounts, parameters: [])
        let dataOp = DataFetchOperation(self.web3, queue: self.expectedQueue)
        dataOp.inputData = request as AnyObject
        let parsingOp = AddressArrayConversionOperation(self.web3, queue: self.expectedQueue)
        dataOp.next = OperationChainingType.operation(parsingOp)
        parsingOp.next = completion
        self.expectedQueue.addOperation(dataOp)
    }
}

@available(*, deprecated)
final class GetTransactionCountOperation: Web3Operation {
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, address: EthereumAddress, onBlock: String = "latest") {
        let addressString = address.address.lowercased()
        self.init(web3Instance, queue: queue, inputData: [addressString, onBlock] as AnyObject)
    }
    
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, address: String, onBlock: String = "latest") {
        self.init(web3Instance, queue: queue, inputData: [address, onBlock] as AnyObject)
    }
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let completion = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [AnyObject] else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard input.count == 2 else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let address = input[0] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let onBlock = input[1] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let _ = EthereumAddress(address) else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let request = JSONRPCRequestFabric.prepareRequest(.getTransactionCount, parameters: [address, onBlock])
        let dataOp = DataFetchOperation(self.web3, queue: self.expectedQueue)
        dataOp.inputData = request as AnyObject
        let convOp = BigUIntConversionOperation(self.web3, queue: self.expectedQueue)
        dataOp.next = OperationChainingType.operation(convOp)
        convOp.next = completion
        self.expectedQueue.addOperation(dataOp)
    }
}

@available(*, deprecated)
final class GetBalanceOperation: Web3Operation {
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, address: EthereumAddress, onBlock: String = "latest") {
        let addressString = address.address.lowercased()
        self.init(web3Instance, queue: queue, inputData: [addressString, onBlock] as AnyObject)
    }
    
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, address: String, onBlock: String = "latest") {
        self.init(web3Instance, queue: queue, inputData: [address, onBlock] as AnyObject)
    }
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let completion = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [AnyObject] else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard input.count == 2 else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let address = input[0] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let onBlock = input[1] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let _ = EthereumAddress(address) else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let request = JSONRPCRequestFabric.prepareRequest(.getBalance, parameters: [address, onBlock])
        let dataOp = DataFetchOperation(self.web3, queue: self.expectedQueue)
        dataOp.inputData = request as AnyObject
        let convOp = BigUIntConversionOperation(self.web3, queue: self.expectedQueue)
        dataOp.next = OperationChainingType.operation(convOp)
        convOp.next = completion
        self.expectedQueue.addOperation(dataOp)
    }
}

@available(*, deprecated)
final class GetBlockNumberOperation: Web3Operation {
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let completion = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let request = JSONRPCRequestFabric.prepareRequest(.blockNumber, parameters: [])
        let dataOp = DataFetchOperation(self.web3, queue: self.expectedQueue)
        dataOp.inputData = request as AnyObject
        let parsingOp = BigUIntConversionOperation(self.web3, queue: self.expectedQueue)
        dataOp.next = OperationChainingType.operation(parsingOp)
        parsingOp.next = completion
        self.expectedQueue.addOperation(dataOp)
    }
}

@available(*, deprecated)
final class GetGasPriceOperation: Web3Operation {
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let completion = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let request = JSONRPCRequestFabric.prepareRequest(.gasPrice, parameters: [])
        let dataOp = DataFetchOperation(self.web3, queue: self.expectedQueue)
        dataOp.inputData = request as AnyObject
        let parsingOp = BigUIntConversionOperation(self.web3, queue: self.expectedQueue)
        dataOp.next = OperationChainingType.operation(parsingOp)
        parsingOp.next = completion
        self.expectedQueue.addOperation(dataOp)
    }
}

@available(*, deprecated)
final class EstimateGasOperation: Web3Operation {
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, transaction: EthereumTransaction, options: Web3Options?,  onBlock: String = "latest") {
        self.init(web3Instance, queue: queue, inputData: [transaction, options as Any, onBlock] as AnyObject)
    }
    
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, transactionIntermediate: TransactionIntermediate, onBlock: String = "latest") {
        self.init(web3Instance, queue: queue, inputData: [transactionIntermediate.transaction, transactionIntermediate.options as Any, onBlock] as AnyObject)
    }
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let completion = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [AnyObject] else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard input.count == 3 else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let transaction = input[0] as? EthereumTransaction else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let options = input[1] as? Web3Options
        guard let onBlock = input[2] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard var mergedOptions = Web3Options.merge(Web3Options.defaultOptions(), with: options) else {return processError(Web3Error.inputError("Invalid input supplied"))}
        mergedOptions.gasLimit = nil
        let tx = transaction.mergedWithOptions(mergedOptions)
        guard let request = EthereumTransaction.createRequest(method: JSONRPCmethod.estimateGas, transaction: tx, onBlock: onBlock, options: mergedOptions) else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let dataOp = DataFetchOperation(self.web3, queue: self.expectedQueue)
        dataOp.inputData = request as AnyObject
        let parsingOp = BigUIntConversionOperation(self.web3, queue: self.expectedQueue)
        dataOp.next = OperationChainingType.operation(parsingOp)
        parsingOp.next = completion
        self.expectedQueue.addOperation(dataOp)
    }
}

@available(*, deprecated)
final class CallOperation: Web3Operation {
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, transaction: EthereumTransaction, options: Web3Options?, onBlock: String = "latest") {
        self.init(web3Instance, queue: queue, inputData: [transaction, options as Any, onBlock] as AnyObject)
    }
    
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, transactionIntermediate: TransactionIntermediate, onBlock: String = "latest") {
        self.init(web3Instance, queue: queue, inputData: [transactionIntermediate.transaction, transactionIntermediate.options as Any, onBlock] as AnyObject)
    }
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let completion = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [AnyObject] else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard input.count == 3 else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let transaction = input[0] as? EthereumTransaction else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let options = input[1] as? Web3Options
        guard let onBlock = input[2] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let mergedOptions = Web3Options.merge(Web3Options.defaultOptions(), with: options) else {
            return processError(Web3Error.inputError("Invalid input supplied"))
        }
        let tx = transaction.mergedWithOptions(mergedOptions)
        guard let request = EthereumTransaction.createRequest(method: JSONRPCmethod.call, transaction: tx, onBlock: onBlock, options: mergedOptions) else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let dataOp = DataFetchOperation(self.web3, queue: self.expectedQueue)
        dataOp.inputData = request as AnyObject
        let parsingOp = DataConversionOperation(self.web3, queue: self.expectedQueue)
        dataOp.next = OperationChainingType.operation(parsingOp)
        parsingOp.next = completion
        self.expectedQueue.addOperation(dataOp)
    }
}

@available(*, deprecated)
final class SendTransactionOperation: Web3Operation {
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, transaction: EthereumTransaction, options: Web3Options?, password:String = "BANKEXFOUNDATION") {
        self.init(web3Instance, queue: queue, inputData: [transaction, options as Any, password] as AnyObject)
    }
    
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, transactionIntermediate: TransactionIntermediate, password:String = "BANKEXFOUNDATION") {
        self.init(web3Instance, queue: queue, inputData: [transactionIntermediate.transaction, transactionIntermediate.options as Any, password] as AnyObject)
    }
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let completion = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [AnyObject] else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard input.count == 3 else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let transaction = input[0] as? EthereumTransaction else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let options = input[1] as? Web3Options
        guard let password = input[2] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let mergedOptions = Web3Options.merge(Web3Options.defaultOptions(), with: options) else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let from = mergedOptions.from else {return processError(Web3Error.walletError)}
        var tx = transaction
        tx = tx.mergedWithOptions(mergedOptions)
        if let keystoreManager = self.web3.provider.attachedKeystoreManager {
            do {
                try Web3Signer.signTX(transaction: &tx, keystore: keystoreManager, account: from, password: password)
            }
            catch {
                if error is AbstractKeystoreError {
                    return processError(Web3Error.keystoreError(error as! AbstractKeystoreError))
                }
                return processError(Web3Error.generalError(error))
            }
            print(tx)
            let sendRawTxOp = SendRawTransactionOperation(self.web3, queue: self.expectedQueue, transaction: tx)
            sendRawTxOp.next = completion
            self.expectedQueue.addOperation(sendRawTxOp)
            return
        }
        guard let request = EthereumTransaction.createRequest(method: JSONRPCmethod.sendTransaction, transaction: tx, onBlock: nil, options: mergedOptions) else
        {
            return processError(Web3Error.transactionSerializationError)
        }
        let dataOp = DataFetchOperation(self.web3, queue: self.expectedQueue)
        dataOp.inputData = request as AnyObject
        let parsingOp = DataConversionOperation(self.web3, queue: self.expectedQueue)
        dataOp.next = OperationChainingType.operation(parsingOp)
        parsingOp.next = completion
        self.expectedQueue.addOperation(dataOp)
    }
}

@available(*, deprecated)
final class SendRawTransactionOperation: Web3Operation {
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, transaction: EthereumTransaction) {
        self.init(web3Instance, queue: queue, inputData: transaction as AnyObject)
    }
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let completion = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let transaction = inputData! as? EthereumTransaction else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let request = EthereumTransaction.createRawTransaction(transaction: transaction) else {return processError(Web3Error.transactionSerializationError)}
        let dataOp = DataFetchOperation(self.web3, queue: self.expectedQueue)
        dataOp.inputData = request as AnyObject
        let parsingOp = StringConversionOperation(self.web3, queue: self.expectedQueue)
        dataOp.next = OperationChainingType.operation(parsingOp)
        parsingOp.next = completion
        self.expectedQueue.addOperation(dataOp)
    }
}
