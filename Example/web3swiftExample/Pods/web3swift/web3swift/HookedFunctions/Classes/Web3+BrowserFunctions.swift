//
//  Web3+BrowserFunctions.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

extension web3.BrowserFunctions {
    
    public func getAccounts() -> [String]? {
        let result = self.web3.eth.getAccounts()
        switch result {
        case .failure(_):
            return nil
        case .success(let accounts):
            return accounts.compactMap({$0.address})
        }
    }
    
    public func getCoinbase() -> String? {
        guard let addresses = self.getAccounts() else {return nil}
        guard addresses.count > 0 else {return nil}
        return addresses[0]
    }
    
    public func personalSign(_ personalMessage: String, account: String, password: String = "BANKEXFOUNDATION") -> String? {
        return self.sign(personalMessage, account: account, password: password)
    }
    
    public func sign(_ personalMessage: String, account: String, password: String = "BANKEXFOUNDATION") -> String? {
        guard let data = Data.fromHex(personalMessage) else {return nil}
        return self.sign(data, account: account, password: password)
    }
    
    public func sign(_ personalMessage: Data, account: String, password: String = "BANKEXFOUNDATION") -> String? {
        do {
            guard let keystoreManager = self.web3.provider.attachedKeystoreManager else {return nil}
            
            guard let signature = try Web3Signer.signPersonalMessage(personalMessage, keystore: keystoreManager, account: EthereumAddress(account)!, password: password) else {return nil}
            guard let sender = self.personalECRecover(personalMessage, signature: signature) else {return nil}
            print(sender)
            if sender.lowercased() != account.lowercased() {
                print("Invalid sender")
            }
            return signature.toHexString().addHexPrefix()
        }
        catch{
            print(error)
            return nil
        }
    }
    
    public func personalECRecover(_ personalMessage: String, signature: String) -> String? {
        guard let data = Data.fromHex(personalMessage) else {return nil}
        guard let sig = Data.fromHex(signature) else {return nil}
        return self.personalECRecover(data, signature:sig)
    }
    
    public func personalECRecover(_ personalMessage: Data, signature: Data) -> String? {
        if signature.count != 65 { return nil}
        let rData = signature[0..<32].bytes
        let sData = signature[32..<64].bytes
        let vData = signature[64]
        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else {return nil}
        var hash: Data
        if personalMessage.count == 32 {
            print("Most likely it's hash already, allow for now")
            hash = personalMessage
        } else {
            guard let h = Web3.Utils.hashPersonalMessage(personalMessage) else {return nil}
            hash = h
        }
        guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else {return nil}
        return Web3.Utils.publicToAddressString(publicKey)
    }
    
    
    public func sendTransaction(_ transactionJSON: [String: Any], password: String = "BANKEXFOUNDATION") -> [String:Any]? {
        guard let transaction = EthereumTransaction.fromJSON(transactionJSON) else {return nil}
        guard let options = Web3Options.fromJSON(transactionJSON) else {return nil}
        return self.sendTransaction(transaction, options: options, password: password)
    }
    
    public func sendTransaction(_ transaction: EthereumTransaction, options: Web3Options, password: String = "BANKEXFOUNDATION") -> [String:Any]? {
        let result = self.web3.eth.sendTransaction(transaction, options: options, password: password)
        switch result {
        case .failure(_):
            return nil
        case .success(let res):
            return ["txhash": res.hash]
        }
    }
    
    public func estimateGas(_ transactionJSON: [String: Any]) -> BigUInt? {
        guard let transaction = EthereumTransaction.fromJSON(transactionJSON) else {return nil}
        guard let options = Web3Options.fromJSON(transactionJSON) else {return nil}
        return self.estimateGas(transaction, options: options)
    }
    
    public func estimateGas(_ transaction: EthereumTransaction, options: Web3Options) -> BigUInt? {
        let result = self.web3.eth.estimateGas(transaction, options: options)
        switch result {
        case .failure(_):
            return nil
        case .success(let res):
            return res
        }
    }
    
    public func prepareTxForApproval(_ transactionJSON: [String: Any]) -> (transaction: EthereumTransaction?, options: Web3Options?) {
        guard let transaction = EthereumTransaction.fromJSON(transactionJSON) else {return (nil, nil)}
        guard let options = Web3Options.fromJSON(transactionJSON) else {return (nil, nil)}
        return self.prepareTxForApproval(transaction, options: options)
    }
    
    public func prepareTxForApproval(_ trans: EthereumTransaction, options  opts: Web3Options) -> (transaction: EthereumTransaction?, options: Web3Options?) {
        var transaction = trans
        var options = opts
        guard let _ = options.from else {return (nil, nil)}
        let gasPriceResult = self.web3.eth.getGasPrice()
        if case .failure(_) = gasPriceResult {
            return (nil, nil)
        }
        transaction.gasPrice = gasPriceResult.value!
        options.gasPrice = gasPriceResult.value!
        guard let gasEstimate = self.estimateGas(transaction, options: options) else {return (nil, nil)}
        transaction.gasLimit = gasEstimate
        options.gasLimit = gasEstimate
        print(transaction)
        return (transaction, options)
    }
    
    public func signTransaction(_ transactionJSON: [String: Any], password: String = "BANKEXFOUNDATION") -> String? {
        guard let transaction = EthereumTransaction.fromJSON(transactionJSON) else {return nil}
        guard let options = Web3Options.fromJSON(transactionJSON) else {return nil}
        return self.signTransaction(transaction, options: options, password: password)
    }
    
    public func signTransaction(_ trans: EthereumTransaction, options: Web3Options, password: String = "BANKEXFOUNDATION") -> String? {
        do {
            var transaction = trans
            guard let from = options.from else {return nil}
            guard let keystoreManager = self.web3.provider.attachedKeystoreManager else {return nil}
            let gasPriceResult = self.web3.eth.getGasPrice()
            if case .failure(_) = gasPriceResult {
                return nil
            }
            transaction.gasPrice = gasPriceResult.value!
            guard let gasEstimate = self.estimateGas(transaction, options: options) else {return nil}
            transaction.gasLimit = gasEstimate
            
            let nonceResult = self.web3.eth.getTransactionCount(address: from, onBlock: "pending")
            if case .failure(_) = nonceResult {
                return nil
            }
            transaction.nonce = nonceResult.value!
            
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
