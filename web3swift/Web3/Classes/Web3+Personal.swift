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
        return Result.failure(Web3Error.dataError)
//        guard let request = EthereumTransaction.createRequest(method: JSONRPCmethod.sendTransaction, transaction: transaction, onBlock: nil, options: mergedOptions) else
//        {
//        return Result.failure(Web3Error.transactionSerializationError)
//        }
//        //        guard let request = EthereumTransaction.createRawTransaction(transaction: transaction) else {return Result.failure(Web3Error.transactionSerializationError)}
//        let response = self.provider.send(request: request)
//        let result = ResultUnwrapper.getResponse(response)
//        switch result {
//        case .failure(let error):
//        return Result.failure(error)
//        case .success(let payload):
//        guard let resultString = payload as? String else {
//        return Result.failure(Web3Error.dataError)
//        }
//        let hash = resultString.addHexPrefix().lowercased()
//        return Result(["txhash": hash, "txhashCalculated" : transaction.hash!.toHexString()] as [String: String])
//        }
    }
}
