//
//  Web3+Personal.swift
//  web3swift
//
//  Created by Alexander Vlasov on 14.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import Result

extension web3.Personal {
    func signPersonalMessage(message: Data, from: EthereumAddress, password:String = "BANKEXFOUNDATION", callback: @escaping Callback, queue: OperationQueue = OperationQueue.main) {
        let operation = PersonalSignOperation.init(self.web3, queue: self.web3.queue, message: message, from: from, password: password)
        operation.next = OperationChainingType.callback(callback, queue)
        self.web3.queue.addOperation(operation)
    }
    
    public func signPersonalMessage(message: Data, from: EthereumAddress, password:String = "BANKEXFOUNDATION") -> Result<Data, Web3Error> {
        if let keystoreManager = self.web3.provider.attachedKeystoreManager {
            var signature: Data?
            do {
                signature = try Web3Signer.signPersonalMessage(message, keystore: keystoreManager, account: from, password: password)
            }
            catch {
                if error is AbstractKeystoreError {
                    return Result.failure(Web3Error.keystoreError(error as! AbstractKeystoreError))
                }
                return Result.failure(Web3Error.generalError(error))
            }
            if signature == nil {
                return Result.failure(Web3Error.dataError)
            }
            return Result(signature!)
        }
        let hexData = message.toHexString().addHexPrefix()
        let request = JSONRPCRequestFabric.prepareRequest(.personalSign, parameters: [from.address.lowercased(), hexData])
        let response = self.provider.send(request: request)
        let result = ResultUnwrapper.getResponse(response)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let payload):
            guard let resultString = payload as? String else {
                return Result.failure(Web3Error.dataError)
            }
            guard let sigData = Data.fromHex(resultString) else {
                return Result.failure(Web3Error.dataError)
            }
            return Result(sigData)
        }
    }
    
    func unlockAccount(account: EthereumAddress, password:String = "BANKEXFOUNDATION", seconds: UInt64 = 300, callback: @escaping Callback, queue: OperationQueue = OperationQueue.main) {
        let operation = PersonalUnlockAccountOperation.init(self.web3, queue: self.web3.queue, account: account, password: password, seconds: seconds)
        operation.next = OperationChainingType.callback(callback, queue)
        self.web3.queue.addOperation(operation)
    }
    
    public func unlockAccount(account: EthereumAddress, password:String = "BANKEXFOUNDATION", seconds: UInt64 = 300) -> Result<Bool, Web3Error> {
        if let _ = self.web3.provider.attachedKeystoreManager {
            return Result.failure(Web3Error.walletError)
        }
        let request = JSONRPCRequestFabric.prepareRequest(.unlockAccount, parameters: [account.address.lowercased(), password, seconds])
        let response = self.provider.send(request: request)
        let result = ResultUnwrapper.getResponse(response)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let payload):
            guard let resultBool = payload as? Bool else {
                return Result.failure(Web3Error.dataError)
            }
            return Result(resultBool)
        }
    }
    
    public func ecrecover(personalMessage: Data, signature: Data) -> Result<EthereumAddress, Web3Error> {
        guard let recovered = Web3.Utils.personalECRecover(personalMessage, signature: signature) else {
            return Result.failure(Web3Error.dataError)
        }
        return Result(recovered)
    }
    
    public func ecrecover(hash: Data, signature: Data) -> Result<EthereumAddress, Web3Error> {
        guard let recovered = Web3.Utils.hashECRecover(hash: hash, signature: signature) else {
            return Result.failure(Web3Error.dataError)
        }
        return Result(recovered)
    }
}
