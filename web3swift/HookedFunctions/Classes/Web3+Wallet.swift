//
//  Web3+HookedWallet.swift
//  web3swift
//
//  Created by Alexander Vlasov on 07.01.2018.
//

import Foundation
import BigInt
import Result

extension web3.Web3Wallet {
    
    public func getAccounts() -> Result<[EthereumAddress], Web3Error> {
        guard let keystoreManager = self.web3?.provider.attachedKeystoreManager else {
            return Result.failure(Web3Error.walletError)
        }
        guard let ethAddresses = keystoreManager.addresses else {
            return Result.failure(Web3Error.walletError)
        }
        return Result(ethAddresses)
    }
    
    public func getCoinbase() -> Result<EthereumAddress, Web3Error> {
        let result = self.getAccounts()
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let addresses):
            guard addresses.count > 0 else {
                return Result.failure(Web3Error.walletError)
            }
            return Result(addresses[0])
        }
    }
    
//    public static func signTX(transaction:inout EthereumTransaction, account: EthereumAddress, password: String = "BANKEXFOUNDATION") -> Result<Bool, Web3Error>
//        do {
//            guard let keystoreManager = self.web3?.provider.attachedKeystoreManager else {
//                return Result.failure(Web3Error.walletError)
//            }
//             var privateKey = try keystoreManager.UNSAFE
//            if (network != nil) {
//                let signer = EIP155Signer(network: network!)
//                signer.sign(transaction: &newTX, privateKey: Data)
//            }
//            else if (newTX.chainID != nil) {
//                let signer = EIP155Signer(Networks.Custom(networkID: newTX.chainID!))
//                signer.sign(transaction: &newTX, privateKey: Data)
//            } else {
//                let signer = FallbackSigner()
//                signer.sign(transaction: &newTX, privateKey: Data)
//            }
//        } catch {
//
//    }
//    }
//    public static func signIntermediate(intermediate:inout TransactionIntermediate, privateKey: Data, network: Networks?) throws {
//        var tx = intermediate.transaction
//        Web3AbstractSigner.signTX(transaction: &tx, privateKey: privateKey, network: network)
//        try intermediate.sign(privateKey)
//    }
//
//    public static func signPersonalMessage(_ personalMessage: Data, privateKey: Data) throws -> Data? {
//        guard let hash = Web3.Utils.hashPersonalMessage(personalMessage) else {return nil}
//        let (compressedSignature, _) = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey)
//        return compressedSignature
//    }
    
    public func signPersonalMessage(_ personalMessage: String, account: String, password: String = "BANKEXFOUNDATION") -> Result<Data, Web3Error> {
        guard let data = Data.fromHex(personalMessage) else
        {
            return Result.failure(Web3Error.dataError)
        }
        return self.sign(personalMessage, account: account, password: password)
    }
    
    public func signPersonalMessage(_ personalMessage: Data, account: String, password: String = "BANKEXFOUNDATION") -> Result<Data, Web3Error> {
        do {
            guard let keystoreManager = self.web3?.provider.attachedKeystoreManager else
            {
                return Result.failure(Web3Error.walletError)
            }
            guard let signature = try keystoreManager.signPersonalMessage(personalMessage, password: password, account: EthereumAddress(account)) else
            {
                Result.failure(Web3Error.walletError)
            }
            guard let sender = self.personalECRecover(personalMessage, signature: signature) else
            {
                Result.failure(Web3Error.walletError)
            }
            print(sender)
            if sender.lowercased() != account.lowercased()
            {
                Result.failure(Web3Error.walletError)
            }
            return Result(signature)
        }
        catch{
            return Result(Web3Error.keystoreError(error))
        }
    }
    

    
    
    public func sendTransaction(_ transactionJSON: [String: Any], password: String = "BANKEXFOUNDATION") -> [String:Any]? {
        guard let transaction = EthereumTransaction.fromJSON(transactionJSON) else {return nil}
        guard let options = Web3Options.fromJSON(transactionJSON) else {return nil}
        return self.sendTransaction(transaction, options: options, password: password)
    }
    
    public func sendTransaction(_ trans: EthereumTransaction, options: Web3Options, password: String = "BANKEXFOUNDATION") -> [String:Any]? {
        do {
            var transaction = trans
            guard let from = options.from else {return nil}
            guard let keystoreManager = self.web3?.provider.attachedKeystoreManager else {return nil}
            guard let nonce = self.web3?.eth.getTransactionCount(address: from, onBlock: "pending") else {return nil}
            transaction.nonce = nonce
            if (self.web3?.provider.network != nil) {
                transaction.chainID = self.web3?.provider.network?.chainID
            }
            try keystoreManager.signTX(transaction: &transaction, password: password, account: from)
            print(transaction)
            guard let request = EthereumTransaction.createRawTransaction(transaction: transaction) else {return nil}
            let response = self.web3?.provider.send(request: request)
            if response == nil {
                return nil
            }
            guard let res = response else {return nil}
            if let error = res["error"] as? String {
                print(error as String)
                return nil
            }
            guard let resultString = res["result"] as? String else {return nil}
            let hash = resultString.addHexPrefix().lowercased()
            return ["txhash": hash as Any, "txhashCalculated" : transaction.txhash as Any]
        }
        catch {
            return nil
        }
    }
    
    public func estimateGas(_ transactionJSON: [String: Any]) -> BigUInt? {
        guard let transaction = EthereumTransaction.fromJSON(transactionJSON) else {return nil}
        guard let options = Web3Options.fromJSON(transactionJSON) else {return nil}
        return self.estimateGas(transaction, options: options)
    }
    
    public func estimateGas(_ transaction: EthereumTransaction, options: Web3Options) -> BigUInt? {
        return self.web3?.eth.estimateGas(transaction, options: options)
    }
    
    public func prepareTxForApproval(_ transactionJSON: [String: Any]) -> (transaction: EthereumTransaction?, options: Web3Options?) {
        guard let transaction = EthereumTransaction.fromJSON(transactionJSON) else {return (nil, nil)}
        guard let options = Web3Options.fromJSON(transactionJSON) else {return (nil, nil)}
        return self.prepareTxForApproval(transaction, options: options)
    }
    
    public func prepareTxForApproval(_ trans: EthereumTransaction, options  opts: Web3Options) -> (transaction: EthereumTransaction?, options: Web3Options?) {
        var transaction = trans
        var options = opts
        guard let from = options.from else {return (nil, nil)}
        guard let keystoreManager = self.web3?.provider.attachedKeystoreManager else {return (nil, nil)}
        guard let _ = keystoreManager.walletForAddress(from) else {return (nil, nil)}
        guard let gasPrice = self.web3?.eth.getGasPrice() else {return (nil, nil)}
        transaction.gasPrice = gasPrice
        options.gasPrice = gasPrice
        guard let gasEstimate = self.estimateGas(transaction, options: options) else {return (nil, nil)}
        transaction.gasLimit = gasEstimate
        options.gasLimit = gasEstimate
        print(transaction)
        return (transaction, options)
    }
    
    public func signPreparedTransaction(_ trans: EthereumTransaction, options: Web3Options, password: String = "BANKEXFOUNDATION") -> String? {
        do {
            var transaction = trans
            guard let from = options.from else {return nil}
            guard let keystoreManager = self.web3?.provider.attachedKeystoreManager else {return nil}
            guard let nonce = self.web3?.eth.getTransactionCount(address: from, onBlock: "pending") else {return nil}
            transaction.nonce = nonce
            if (self.web3?.provider.network != nil) {
                transaction.chainID = self.web3?.provider.network?.chainID
            }
            guard let keystore = keystoreManager.walletForAddress(from) else {return nil}
            try keystore.signTX(transaction: &transaction, password: password, account: from)
            print(transaction)
            let signedData = transaction.encode(forSignature: false, chainID: nil)?.toHexString().addHexPrefix()
            return signedData
        }
        catch {
            return nil
        }
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
            guard let keystoreManager = self.web3?.provider.attachedKeystoreManager else {return nil}
            
            guard let gasPrice = self.web3?.eth.getGasPrice() else {return nil}
            transaction.gasPrice = gasPrice
            
            guard let gasEstimate = self.estimateGas(transaction, options: options) else {return nil}
            transaction.gasLimit = gasEstimate
            
            guard let nonce = self.web3?.eth.getTransactionCount(address: from, onBlock: "pending") else {return nil}
            transaction.nonce = nonce
            if (self.web3?.provider.network != nil) {
                transaction.chainID = self.web3?.provider.network?.chainID
            }
            guard let keystore = keystoreManager.walletForAddress(from) else {return nil}
            try keystore.signTX(transaction: &transaction, password: password, account: from)
            print(transaction)
            let signedData = transaction.encode(forSignature: false, chainID: nil)?.toHexString().addHexPrefix()
            return signedData
        }
        catch {
            return nil
        }
    }
}
