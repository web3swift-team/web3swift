//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
//import secp256k1_swift
//import EthereumAddress

extension web3.BrowserFunctions {
    
    public func getAccounts() -> [String]? {
        do {
            let accounts = try self.web3.eth.getAccounts()
            return accounts.compactMap({$0.address})
        } catch {
            return [String]()
        }
    }
    
    public func getCoinbase() -> String? {
        guard let addresses = self.getAccounts() else {return nil}
        guard addresses.count > 0 else {return nil}
        return addresses[0]
    }
    
    public func personalSign(_ personalMessage: String, account: String, password: String = "web3swift") -> String? {
        return self.sign(personalMessage, account: account, password: password)
    }
    
    public func sign(_ personalMessage: String, account: String, password: String = "web3swift") -> String? {
        guard let data = Data.fromHex(personalMessage) else {return nil}
        return self.sign(data, account: account, password: password)
    }
    
    public func sign(_ personalMessage: Data, account: String, password: String = "web3swift") -> String? {
        do {
            guard let keystoreManager = self.web3.provider.attachedKeystoreManager else {return nil}
            guard let from = EthereumAddress(account, ignoreChecksum: true) else {return nil}
            guard let signature = try Web3Signer.signPersonalMessage(personalMessage, keystore: keystoreManager, account: from, password: password) else {return nil}
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
        var vData = signature[64]
        if vData >= 27 && vData <= 30 {
            vData -= 27
        } else if vData >= 31 && vData <= 34 {
            vData -= 31
        } else if vData >= 35 && vData <= 38 {
            vData -= 35
        }
        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else {return nil}
        guard let hash = Web3.Utils.hashPersonalMessage(personalMessage) else {return nil}
        guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else {return nil}
        return Web3.Utils.publicToAddressString(publicKey)
    }
    
    
    public func sendTransaction(_ transactionJSON: [String: Any], password: String = "web3swift") -> [String:Any]? {
        guard let transaction = EthereumTransaction.fromJSON(transactionJSON) else {return nil}
        guard let options = TransactionOptions.fromJSON(transactionJSON) else {return nil}
        var transactionOptions = TransactionOptions()
        transactionOptions.from = options.from
        transactionOptions.to = options.to
        transactionOptions.value = options.value != nil ? options.value! : BigUInt(0)
        transactionOptions.gasLimit = options.gasLimit != nil ? options.gasLimit! : .automatic
        transactionOptions.gasPrice = options.gasPrice != nil ? options.gasPrice! : .automatic
        return self.sendTransaction(transaction, transactionOptions: transactionOptions, password: password)
    }
    
    public func sendTransaction(_ transaction: EthereumTransaction, transactionOptions: TransactionOptions, password: String = "web3swift") -> [String:Any]? {
        do {
            let result = try self.web3.eth.sendTransaction(transaction, transactionOptions: transactionOptions, password: password)
            return ["txhash": result.hash]
        } catch {
            return nil
        }
    }
    
    public func estimateGas(_ transactionJSON: [String: Any]) -> BigUInt? {
        guard let transaction = EthereumTransaction.fromJSON(transactionJSON) else {return nil}
        guard let options = TransactionOptions.fromJSON(transactionJSON) else {return nil}
        var transactionOptions = TransactionOptions()
        transactionOptions.from = options.from
        transactionOptions.to = options.to
        transactionOptions.value = options.value != nil ? options.value! : BigUInt(0)
        transactionOptions.gasLimit = .automatic
        transactionOptions.gasPrice = options.gasPrice != nil ? options.gasPrice! : .automatic
        return self.estimateGas(transaction, transactionOptions: transactionOptions)
    }
    
    public func estimateGas(_ transaction: EthereumTransaction, transactionOptions: TransactionOptions) -> BigUInt? {
        do {
            let result = try self.web3.eth.estimateGas(transaction, transactionOptions: transactionOptions)
            return result
        } catch {
            return nil
        }
    }
    
    public func prepareTxForApproval(_ transactionJSON: [String: Any]) -> (transaction: EthereumTransaction?, options: TransactionOptions?) {
        guard let transaction = EthereumTransaction.fromJSON(transactionJSON) else {return (nil, nil)}
        guard let options = TransactionOptions.fromJSON(transactionJSON) else {return (nil, nil)}
        do {
            return try self.prepareTxForApproval(transaction, options: options)
        } catch {
            return (nil, nil)
        }
    }

    public func prepareTxForApproval(_ trans: EthereumTransaction, options opts: TransactionOptions) throws -> (transaction: EthereumTransaction?, options: TransactionOptions?) {
        do {
            var transaction = trans
            var options = opts
            guard let _ = options.from else {return (nil, nil)}
            let gasPrice = try self.web3.eth.getGasPrice()
            transaction.gasPrice = gasPrice
            options.gasPrice = .manual(gasPrice)
            guard let gasEstimate = self.estimateGas(transaction, transactionOptions: options) else {return (nil, nil)}
            transaction.gasLimit = gasEstimate
            options.gasLimit = .limited(gasEstimate)
            print(transaction)
            return (transaction, options)
        } catch {
            return (nil, nil)
        }
    }
    
    public func signTransaction(_ transactionJSON: [String: Any], password: String = "web3swift") -> String? {
        guard let transaction = EthereumTransaction.fromJSON(transactionJSON) else {return nil}
        guard let options = TransactionOptions.fromJSON(transactionJSON) else {return nil}
        var transactionOptions = TransactionOptions()
        transactionOptions.from = options.from
        transactionOptions.to = options.to
        transactionOptions.value = options.value != nil ? options.value! : BigUInt(0)
        transactionOptions.gasLimit = options.gasLimit != nil ? options.gasLimit! : .automatic
        transactionOptions.gasPrice = options.gasPrice != nil ? options.gasPrice! : .automatic
        if let nonceString = transactionJSON["nonce"] as? String, let nonce = BigUInt(nonceString.stripHexPrefix(), radix: 16) {
            transactionOptions.nonce = .manual(nonce)
        } else {
            transactionOptions.nonce = .pending
        }
        return self.signTransaction(transaction, transactionOptions: transactionOptions, password: password)
    }
    
    public func signTransaction(_ trans: EthereumTransaction, transactionOptions: TransactionOptions, password: String = "web3swift") -> String? {
        do {
            var transaction = trans
            guard let from = transactionOptions.from else {return nil}
            guard let keystoreManager = self.web3.provider.attachedKeystoreManager else {return nil}
            guard let gasPricePolicy = transactionOptions.gasPrice else {return nil}
            guard let gasLimitPolicy = transactionOptions.gasLimit else {return nil}
            guard let noncePolicy = transactionOptions.nonce else {return nil}
            switch gasPricePolicy {
            case .manual(let gasPrice):
                transaction.gasPrice = gasPrice
            default:
                let gasPrice = try self.web3.eth.getGasPrice()
                transaction.gasPrice = gasPrice
            }
            
            switch gasLimitPolicy {
            case .manual(let gasLimit):
                transaction.gasLimit = gasLimit
            default:
                let gasLimit = try self.web3.eth.estimateGas(transaction, transactionOptions: transactionOptions)
                transaction.gasLimit = gasLimit
            }

            switch noncePolicy {
            case .manual(let nonce):
                transaction.nonce = nonce
            default:
                let nonce = try self.web3.eth.getTransactionCount(address: from, onBlock: "pending")
                transaction.nonce = nonce
            }
            
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
