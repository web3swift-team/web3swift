//
//  Web3+TransactionIntermediate.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import Result
import BigInt

extension web3.web3contract {

    public class TransactionIntermediate{
        public var transaction:EthereumTransaction
        public var contract: Contract
        public var method: String
        public var options: Web3Options? = Web3Options.defaultOptions()
        var web3: web3
        public init (transaction: EthereumTransaction, web3 web3Instance: web3, contract: Contract, method: String, options: Web3Options?) {
            self.transaction = transaction
            self.web3 = web3Instance
            self.contract = contract
            self.contract.options = options
            self.method = method
            self.options = Web3Options.merge(web3.options, with: options)
            if self.web3.provider.network != nil {
                self.transaction.chainID = self.web3.provider.network?.chainID
            }
        }
        
        public func setNonce(_ nonce: BigUInt) throws {
            self.transaction.nonce = nonce
            if (self.web3.provider.network != nil) {
                self.transaction.chainID = self.web3.provider.network?.chainID
            }
        }
        
        //            public func sign(_ privateKey: Data, network: Networks? = nil) throws {
        //                if (network != nil) {
        //                    self.transaction.chainID = network?.chainID
        //                } else if (self.web3.provider.network != nil) {
        //                    self.transaction.chainID = self.web3.provider.network?.chainID
        //                }
        //                let _ = self.transaction.sign(privateKey: privateKey)
        //            }
        
        public func send(password: String = "BANKEXFOUNDATION", options: Web3Options? = nil) -> Result<[String:String], Web3Error> {
            do {
                guard var mergedOptions = Web3Options.merge(self.options, with: options) else
                {
                    return Result.failure(Web3Error.inputError("Invalid options supplied"))
                }
                guard let from = mergedOptions.from else
                {
                    return Result.failure(Web3Error.inputError("Invalid options supplied"))
                }
                let nonceResult = self.web3.eth.getTransactionCount(address: from, onBlock: "pending")
                if case .failure(let err) = nonceResult {
                    return Result.failure(err)
                }
                try self.setNonce(nonceResult.value!)
                let estimatedGasResult = self.estimateGas(options: self.options)
                if case .failure(let err) = estimatedGasResult {
                    return Result.failure(err)
                }
                if mergedOptions.gasLimit == nil {
                    mergedOptions.gasLimit = estimatedGasResult.value!
                } else {
                    if (mergedOptions.gasLimit! > estimatedGasResult.value!) {
                        return Result.failure(Web3Error.inputError("Estimated gas is larger than the gas limit"))
                    }
                }
                self.options = mergedOptions
                if let keystoreManager = self.web3.provider.attachedKeystoreManager {
                    try Web3Signer.signTX(transaction: &self.transaction, keystore: keystoreManager, account: from, password: password)
//                    try keystoreManager.signIntermediate(intermediate: self, password: password, account: from)
                    print(self.transaction)
                    return self.web3.eth.sendRawTransaction(self.transaction)
                }
            }
            catch {
                return Result.failure(Web3Error.generalError(error))
            }
            return Result.failure(Web3Error.unknownError)
        }
        
        public func sendSigned() -> Result<[String:String], Web3Error> {
            print(self.transaction)
            return self.web3.eth.sendRawTransaction(self.transaction)
        }
        
        
        public func call(options: Web3Options?, onBlock: String = "latest") -> Result<[String:Any], Web3Error> {
            let mergedOptions = Web3Options.merge(self.options, with: options)
            guard let request = EthereumTransaction.createRequest(method: JSONRPCmethod.call, transaction: self.transaction, onBlock: onBlock, options: mergedOptions) else
            {
                return Result.failure(Web3Error.inputError("Transaction or options are malformed"))
            }
            let response = self.web3.provider.send(request: request)
            let result = ResultUnwrapper.getResponse(response)
            switch result {
                case .failure(let error):
                    return Result.failure(error)
                case .success(let payload):
                    guard let resultString = payload as? String else {
                        return Result.failure(Web3Error.dataError)
                    }
                    if (self.method == "fallback") {
                        let resultAsBigUInt = BigUInt(resultString.stripHexPrefix(), radix : 16)
                        return Result(["result": resultAsBigUInt as Any])
                    }
                    let foundMethod = self.contract.methods.filter { (key, value) -> Bool in
                        return key == self.method
                    }
                    guard foundMethod.count == 1 else
                    {
                        return Result.failure(Web3Error.dataError)
                    }
                    let abiMethod = foundMethod[self.method]
                    guard let responseData = Data.fromHex(resultString) else
                    {
                        return Result.failure(Web3Error.dataError)
                    }
                    guard let decodedData = abiMethod?.decodeReturnData(responseData) else
                    {
                        return Result.failure(Web3Error.dataError)
                    }
                    return Result(decodedData)
            }
            
        }
        
        public func estimateGas(options: Web3Options?) -> Result<BigUInt, Web3Error> {
            let mergedOptions = Web3Options.merge(self.options, with: options)
            return self.web3.eth.estimateGas(self.transaction, options: mergedOptions)
        }
    }
}
