//
//  Web3+BrowserFunctions.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import secp256k1_swift

extension web3.BrowserFunctions {
    
    @available(*, deprecated, message: "Use TransactionOptions instead")
    public func sendTransaction(_ transaction: EthereumTransaction, options: Web3Options, password: String = "web3swift") -> [String:Any]? {
        let result = self.web3.eth.sendTransaction(transaction, options: options, password: password)
        switch result {
        case .failure(_):
            return nil
        case .success(let res):
            return ["txhash": res.hash]
        }
    }
    
    @available(*, deprecated, message: "Use TransactionOptions instead")
    public func estimateGas(_ transaction: EthereumTransaction, options: Web3Options) -> BigUInt? {
        let result = self.web3.eth.estimateGas(transaction, options: options)
        switch result {
        case .failure(_):
            return nil
        case .success(let res):
            return res
        }
    }
    
    @available(*, deprecated, message: "Use TransactionOptions instead")
    public func prepareTxForApproval(_ transactionJSON: [String: Any]) -> (transaction: EthereumTransaction?, options: Web3Options?) {
        guard let transaction = EthereumTransaction.fromJSON(transactionJSON) else {return (nil, nil)}
        guard let options = Web3Options.fromJSON(transactionJSON) else {return (nil, nil)}
        return self.prepareTxForApproval(transaction, options: options)
    }
    
    @available(*, deprecated, message: "Use TransactionOptions instead")
    public func prepareTxForApproval(_ trans: EthereumTransaction, options  opts: Web3Options) -> (transaction: EthereumTransaction?, options: Web3Options?) {
        var transaction = trans
        var options = opts
        guard let _ = options.from else {return (nil, nil)}
        guard let gasPriceResult = try? self.web3.eth.getGasPrice() else {
            return (nil, nil)
        }
        transaction.gasPrice = gasPriceResult
        options.gasPrice = gasPriceResult
        guard let gasEstimate = self.estimateGas(transaction, options: options) else {return (nil, nil)}
        transaction.gasLimit = gasEstimate
        options.gasLimit = gasEstimate
        print(transaction)
        return (transaction, options)
    }
    
    @available(*, deprecated, message: "Use TransactionOptions instead")
    public func signTransaction(_ trans: EthereumTransaction, options: Web3Options, password: String = "web3swift") -> String? {
        do {
            var transaction = trans
            guard let from = options.from else {return nil}
            guard let keystoreManager = self.web3.provider.attachedKeystoreManager else {return nil}
            let gasPriceResult = try self.web3.eth.getGasPrice()
            transaction.gasPrice = gasPriceResult
            guard let gasEstimate = self.estimateGas(transaction, options: options) else {return nil}
            transaction.gasLimit = gasEstimate
            
            let nonceResult = try self.web3.eth.getTransactionCount(address: from, onBlock: "pending")
            transaction.nonce = nonceResult
            
            if (self.web3.provider.network != nil) {
                transaction.chainID = self.web3.provider.network?.chainID
            }
            
            guard let keystore = keystoreManager.walletForAddress(from) else {return nil}
            try Web3Signer.signTX(transaction: &transaction, keystore: keystore, account: from, password: password)
            print(transaction)
            let signedData = transaction.encode(forSignature: false, chainID: nil)?.toHexString().addHexPrefix()
            return signedData
        }
        catch {
            return nil
        }
    }
}
