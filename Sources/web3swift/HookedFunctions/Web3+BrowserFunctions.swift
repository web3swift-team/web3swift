//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

extension Web3.BrowserFunctions {

    public func getAccounts() async -> [String]? {
        do {
            let accounts = try await self.web3.eth.ownedAccounts()
            return accounts.compactMap({$0.address})
        } catch {
            return [String]()
        }
    }

    public func getCoinbase() async -> String? {
        guard let addresses = await self.getAccounts() else { return nil }
        guard addresses.count > 0 else { return nil }
        return addresses[0]
    }

    public func personalSign(_ personalMessage: String, account: String, password: String ) -> String? {
        return self.sign(personalMessage, account: account, password: password)
    }

    public func sign(_ personalMessage: String, account: String, password: String ) -> String? {
        guard let data = Data.fromHex(personalMessage) else { return nil }
        return self.sign(data, account: account, password: password)
    }

    public func sign(_ personalMessage: Data, account: String, password: String ) -> String? {
        do {
            guard let keystoreManager = self.web3.provider.attachedKeystoreManager else { return nil }
            guard let from = EthereumAddress(account, ignoreChecksum: true) else { return nil }
            guard let signature = try Web3Signer.signPersonalMessage(personalMessage, keystore: keystoreManager, account: from, password: password) else { return nil }
            return signature.toHexString().addHexPrefix()
        } catch {
            print(error)
            return nil
        }
    }

    public func personalECRecover(_ personalMessage: String, signature: String) -> String? {
        guard let data = Data.fromHex(personalMessage) else { return nil }
        guard let sig = Data.fromHex(signature) else { return nil }
        return self.personalECRecover(data, signature: sig)
    }

    public func personalECRecover(_ personalMessage: Data, signature: Data) -> String? {
        if signature.count != 65 { return nil }
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
        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else { return nil }
        guard let hash = Utilities.hashPersonalMessage(personalMessage) else { return nil }
        guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else { return nil }
        return Utilities.publicToAddressString(publicKey)
    }

//    // FIXME: Rewrite this to CodableTransaction
//    public func sendTransaction(_ transactionJSON: [String: Any], password: String ) async -> [String: Any]? {
//        do {
//          let jsonData: Data = try JSONSerialization.data(withJSONObject: transactionJSON, options: [])
//          let transaction: CodableTransaction = try JSONDecoder().decode(CodableTransaction.self, from: jsonData)
//          let options: CodableTransaction = try JSONDecoder().decode(CodableTransaction.self, from: jsonData)
//          var transaction = CodableTransaction.emptyTransaction
//          transaction.from = options.from
//          transaction.to = options.to
//          transaction.value = options.value ?? 0
//          transaction.gasLimitPolicy = options.gasLimitPolicy ?? .automatic
//          transaction.gasPricePolicy = options.gasPricePolicy ?? .automatic
//            return await self.sendTransaction(transaction , password: password)
//        } catch { return nil }
//    }

//    public func estimateGas(_ transactionJSON: [String: Any]) async -> BigUInt? {
//        do {
//            let jsonData: Data = try JSONSerialization.data(withJSONObject: transactionJSON, options: [])
//            let transaction: CodableTransaction = try JSONDecoder().decode(CodableTransaction.self, from: jsonData)
//            let options: CodableTransaction = try JSONDecoder().decode(CodableTransaction.self, from: jsonData)
//            var transaction = CodableTransaction.emptyTransaction
//            transaction.from = options.from
//            transaction.to = options.to
//            transaction.value = options.value ?? 0
//            transaction.gasLimitPolicy = .automatic
//            transaction.gasPricePolicy = options.gasPricePolicy ?? .automatic
//            return await self.estimateGas(transaction )
//        } catch { return nil }
//    }

    // FIXME: Rewrite this to CodableTransaction
    public func estimateGas(_ transaction: CodableTransaction) async -> BigUInt? {
        do {
            let result = try await self.web3.eth.estimateGas(for: transaction)
            return result
        } catch {
            return nil
        }
    }

//    // FIXME: Rewrite this to CodableTransaction
//    public func prepareTxForApproval(_ transactionJSON: [String: Any]) async -> (transaction: CodableTransaction?, options: TransactionOptions?) {
//        do {
//            let jsonData: Data = try JSONSerialization.data(withJSONObject: transactionJSON, options: [])
//            let transaction: CodableTransaction = try JSONDecoder().decode(CodableTransaction.self, from: jsonData)
//            let options: CodableTransaction = try JSONDecoder().decode(CodableTransaction.self, from: jsonData)
//            return try await self.prepareTxForApproval(transaction, options: options)
//        } catch {
//            return (nil, nil)
//        }
//    }
//
//    // FIXME: Rewrite this to CodableTransaction
//    public func prepareTxForApproval(_ trans: CodableTransaction, options opts: CodableTransaction) async throws -> (transaction: CodableTransaction?, options: CodableTransaction?) {
//        do {
//            var transaction = trans
//            var options = opts
//            guard let _ = options.from else {return (nil, nil)}
//            let gasPrice = try await self.web3.eth.gasPrice()
//            transaction.gasPrice = gasPrice
//            options.gasPricePolicy = .manual(gasPrice)
//            guard let gasEstimate = await self.estimateGas(transaction) else {return (nil, nil)}
//            transaction.gasLimit = gasEstimate
//
//            options.gasLimitPolicy = .limited(gasEstimate)
//            print(transaction)
//            return (transaction, options)
//        } catch {
//            return (nil, nil)
//        }
//    }

//    // FIXME: Rewrite this to CodableTransaction
//    public func signTransaction(_ transactionJSON: [String: Any], password: String ) async -> String? {
//        do {
//            let jsonData: Data = try JSONSerialization.data(withJSONObject: transactionJSON, options: [])
//            let transaction: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)
//            let options: CodableTransaction = try JSONDecoder().decode(TransactionOptions.self, from: jsonData)
//            var transaction = TransactionOptions.emptyTransaction
//            transaction.from = options.from
//            transaction.to = options.to
//            transaction.value = options.value ?? 0
//            transaction.gasLimitPolicy = options.gasLimit ?? .automatic
//            transaction.gasPricePolicy = options.gasPrice ?? .automatic
//            if let nonceString = transactionJSON["nonce"] as? String, let nonce = BigUInt(nonceString.stripHexPrefix(), radix: 16) {
//                transaction.nonce = .manual(nonce)
//            } else {
//                transaction.nonce = .pending
//            }
//            return await self.signTransaction(transaction , password: password)
//        } catch { return nil }
//    }

    // FIXME: Rewrite this to EthereumTransaction
//    public func signTransaction(_ trans: EthereumTransaction, transaction: TransactionOptions, password: String ) async -> String? {
//        do {
//            var transaction = trans
//            guard let from = transaction.from else { return nil }
//            guard let keystoreManager = self.web3.provider.attachedKeystoreManager else { return nil }
//            guard let gasPricePolicy = transaction.gasPrice else { return nil }
//            guard let gasLimitPolicy = transaction.gasLimit else { return nil }
//            guard let noncePolicy = transaction.nonce else { return nil }
//            switch gasPricePolicy {
//            case .manual(let gasPrice):
//                transaction.parameters.gasPrice = gasPrice
//            default:
//                let gasPrice = try await self.web3.eth.gasPrice()
//                transaction.parameters.gasPrice = gasPrice
//            }
//
//            switch gasLimitPolicy {
//            case .manual(let gasLimit):
//                transaction.parameters.gasLimit = gasLimit
//            default:
//                let gasLimit = try await self.web3.eth.estimateGas(for: transaction )
//                transaction.parameters.gasLimit = gasLimit
//            }
//
//            switch noncePolicy {
//            case .manual(let nonce):
//                transaction.nonce = nonce
//            default:
//                let nonce = try await self.web3.eth.getTransactionCount(for: from, onBlock: .pending)
//                transaction.nonce = nonce
//            }
//
//            if (self.web3.provider.network != nil) {
//                transaction.chainID = self.web3.provider.network?.chainID
//            }
//
//            guard let keystore = keystoreManager.walletForAddress(from) else { return nil }
//            try Web3Signer.signTX(transaction: &transaction, keystore: keystore, account: from, password: password)
//            print(transaction)
//            let signedData = transaction.encode(for: .transaction)?.toHexString().addHexPrefix()
//            return signedData
//        } catch {
//            return nil
//        }
//    }
}
