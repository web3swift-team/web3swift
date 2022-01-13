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
    
    public func personalSign(_ personalMessage: String, account: String, password: String = "web3swift", _ cb: @escaping (String?) -> Void) {
        self.sign(personalMessage, account: account, password: password, cb)
    }
    
    public func sign(_ personalMessage: String, account: String, password: String = "web3swift", _ cb: @escaping (String?) -> Void) {
        guard let data = Data.fromHex(personalMessage) else {
            cb(nil)
            return
        }
        self.sign(data, account: account, password: password, cb)
    }
    
    public func sign(_ personalMessage: Data, account: String, password: String = "web3swift", _ cb: @escaping (String?) -> Void) {
        guard let signer = self.web3.signer,
              let from = EthereumAddress(account, ignoreChecksum: true) else {
            cb(nil)
            return
        }
        signer.sign(message: personalMessage, with: from, using: password) { result in
            switch result {
            case .success(let data):
                cb(data.toHexString().addHexPrefix())
            case .failure(let error):
                print(error)
                cb(nil)
            }
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
    
    public func signTransaction(_ transactionJSON: [String: Any], password: String = "web3swift", _ cb: @escaping (String?) -> Void) {
        guard let transaction = EthereumTransaction.fromJSON(transactionJSON),
              let options = TransactionOptions.fromJSON(transactionJSON) else {
            cb(nil)
            return
        }
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
        self.signTransaction(transaction, transactionOptions: transactionOptions, password: password, cb)
    }
    
    public func signTransaction(_ trans: EthereumTransaction, transactionOptions: TransactionOptions, password: String = "web3swift", _ cb: @escaping (String?) -> Void) {
        var transaction = trans
        guard let from = transactionOptions.from,
              let signer = self.web3.signer,
              let gasPricePolicy = transactionOptions.gasPrice,
              let gasLimitPolicy = transactionOptions.gasLimit,
              let noncePolicy = transactionOptions.nonce else {
            cb(nil)
            return
        }
        switch gasPricePolicy {
        case .manual(let gasPrice):
            transaction.gasPrice = gasPrice
        default:
            guard let gasPrice = try? self.web3.eth.getGasPrice() else {
                cb(nil)
                return
            }
            transaction.gasPrice = gasPrice
        }
        
        switch gasLimitPolicy {
        case .manual(let gasLimit):
            transaction.gasLimit = gasLimit
        default:
            guard let gasLimit = try? self.web3.eth.estimateGas(transaction, transactionOptions: transactionOptions) else {
                cb(nil)
                return
            }
            transaction.gasLimit = gasLimit
        }

        switch noncePolicy {
        case .manual(let nonce):
            transaction.nonce = nonce
        default:
            guard let nonce = try? self.web3.eth.getTransactionCount(address: from, onBlock: "pending") else {
                cb(nil)
                return
            }
            transaction.nonce = nonce
        }
        
        if (self.web3.provider.network != nil) {
            transaction.chainID = self.web3.provider.network?.chainID
        }
        
        signer.sign(transaction: transaction, with: from, using: password) { result in
            switch result {
            case .success(let data):
                print(transaction)
                let signedData = transaction.encode(forSignature: false, chainID: nil)?.toHexString().addHexPrefix()
                cb(signedData)
            case .failure:
                cb(nil)
            }
        }
    }
}
