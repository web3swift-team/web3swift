//
//  Web3+PersonalOperations.swift
//  web3swift
//
//  Created by Alexander Vlasov on 16.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

@available(*, deprecated)
final class PersonalUnlockAccountOperation: Web3Operation {
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, account: EthereumAddress, password: String = "BANKEXFOUNDATION", seconds: UInt64 = 300) {
        let addressString = account.address.lowercased()
        self.init(web3Instance, queue: queue, inputData: [addressString, password, seconds] as AnyObject)
    }
    
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, account: String, password: String = "BANKEXFOUNDATION", seconds: UInt64 = 300) {
        self.init(web3Instance, queue: queue, inputData: [account, password, seconds] as AnyObject)
    }
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let completion = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [AnyObject] else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard input.count == 3 else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let address = input[0] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let password = input[1] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let seconds = input[2] as? UInt64 else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let _ = EthereumAddress(address) else {return processError(Web3Error.inputError("Invalid input supplied"))}
        let request = JSONRPCRequestFabric.prepareRequest(.unlockAccount, parameters: [address, password, seconds])
        let dataOp = DataFetchOperation(self.web3, queue: self.expectedQueue)
        dataOp.inputData = request as AnyObject
        let convOp = ConversionOperation<Bool>(self.web3, queue: self.expectedQueue)
        dataOp.next = OperationChainingType.operation(convOp)
        convOp.next = completion
        self.expectedQueue.addOperation(dataOp)
    }
}

@available(*, deprecated)
final class PersonalSignOperation: Web3Operation {
    
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, message: Data, from: EthereumAddress, password:String = "BANKEXFOUNDATION") {
        self.init(web3Instance, queue: queue, inputData: [message, from, password] as AnyObject)
    }
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let completion = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [AnyObject] else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard input.count == 3 else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let message = input[0] as? Data else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let from = input[1] as? EthereumAddress else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let password = input[2] as? String else {return processError(Web3Error.inputError("Invalid input supplied"))}
        
        if let keystoreManager = self.web3.provider.attachedKeystoreManager {
            var signatureData:Data? = nil
            do {
                signatureData = try Web3Signer.signPersonalMessage(message, keystore: keystoreManager, account: from, password: password)
            }
            catch {
                if error is AbstractKeystoreError {
                    return processError(Web3Error.keystoreError(error as! AbstractKeystoreError))
                }
                return processError(Web3Error.generalError(error))
            }
            guard let sig = signatureData else {
                return processError(Web3Error.dataError)
            }
            return processSuccess(sig as AnyObject)
        }
        let hexData = message.toHexString().addHexPrefix()
        let request = JSONRPCRequestFabric.prepareRequest(.personalSign, parameters: [from.address.lowercased(), hexData])
        let dataOp = DataFetchOperation(self.web3, queue: self.expectedQueue)
        dataOp.inputData = request as AnyObject
        let parsingOp = DataConversionOperation(self.web3, queue: self.expectedQueue)
        dataOp.next = OperationChainingType.operation(parsingOp)
        parsingOp.next = completion
        self.expectedQueue.addOperation(dataOp)

    }
}
