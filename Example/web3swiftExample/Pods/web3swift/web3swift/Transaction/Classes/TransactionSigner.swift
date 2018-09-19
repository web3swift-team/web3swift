//
//  TransactionSigner.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import Result
import BigInt

public enum TransactionSignerError: Error {
    case signatureError(String)
}

public struct Web3Signer {
    public static func signTX(transaction:inout EthereumTransaction, keystore: AbstractKeystore, account: EthereumAddress, password: String, useExtraEntropy: Bool = false) throws {
        var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
        defer {Data.zero(&privateKey)}
        if (transaction.chainID != nil) {
            try EIP155Signer.sign(transaction: &transaction, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
        } else {
            try FallbackSigner.sign(transaction: &transaction, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
        }
    }
    public static func signIntermediate(intermediate:inout TransactionIntermediate, keystore: AbstractKeystore, account: EthereumAddress, password: String, useExtraEntropy: Bool = false) throws {
        var tx = intermediate.transaction
        try Web3Signer.signTX(transaction: &tx, keystore: keystore, account: account, password: password, useExtraEntropy: useExtraEntropy)
        intermediate.transaction = tx
    }
    public static func signPersonalMessage(_ personalMessage: Data, keystore: AbstractKeystore, account: EthereumAddress, password: String, useExtraEntropy: Bool = false) throws -> Data? {
        var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
        defer {Data.zero(&privateKey)}
        guard let hash = Web3.Utils.hashPersonalMessage(personalMessage) else {return nil}
        let (compressedSignature, _) = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
        return compressedSignature
    }
    
    public struct EIP155Signer {
        public static func sign(transaction:inout EthereumTransaction, privateKey: Data, useExtraEntropy: Bool = false) throws {
            for _ in 0..<1024 {
                let result = self.attemptSignature(transaction: &transaction, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
                if (result) {
                    return
                }
            }
            throw AbstractKeystoreError.invalidAccountError
        }
        
        private static func attemptSignature(transaction:inout EthereumTransaction, privateKey: Data, useExtraEntropy: Bool = false) -> Bool {
            guard let chainID = transaction.chainID else {return false}
            guard let hash = transaction.hashForSignature(chainID: chainID) else {return false}
            let signature  = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
            guard let serializedSignature = signature.serializedSignature else {return false}
            guard let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: serializedSignature) else {
                return false
            }
            let originalPublicKey = SECP256K1.privateToPublic(privateKey: privateKey)
            transaction.v = BigUInt(unmarshalledSignature.v) + BigUInt(35) + chainID + chainID
            transaction.r = BigUInt(Data(unmarshalledSignature.r))
            transaction.s = BigUInt(Data(unmarshalledSignature.s))
            let recoveredPublicKey = transaction.recoverPublicKey()
            if (!(originalPublicKey!.constantTimeComparisonTo(recoveredPublicKey))) {
                return false
            }
            return true
        }
    }
    
    public struct FallbackSigner {
        public static func sign(transaction:inout EthereumTransaction, privateKey: Data, useExtraEntropy: Bool = false) throws {
            for _ in 0..<1024 {
                let result = self.attemptSignature(transaction: &transaction, privateKey: privateKey)
                if (result) {
                    return
                }
            }
            throw AbstractKeystoreError.invalidAccountError
        }
        
        private static func attemptSignature(transaction:inout EthereumTransaction, privateKey: Data, useExtraEntropy: Bool = false) -> Bool {
            guard let hash = transaction.hashForSignature(chainID: nil) else {return false}
            let signature  = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
            guard let serializedSignature = signature.serializedSignature else {return false}
            guard let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: serializedSignature) else {
                return false
            }
            let originalPublicKey = SECP256K1.privateToPublic(privateKey: privateKey)
            transaction.chainID = nil
            transaction.v = BigUInt(unmarshalledSignature.v) + BigUInt(27)
            transaction.r = BigUInt(Data(unmarshalledSignature.r))
            transaction.s = BigUInt(Data(unmarshalledSignature.s))
            let recoveredPublicKey = transaction.recoverPublicKey()
            if (!(originalPublicKey!.constantTimeComparisonTo(recoveredPublicKey))) {
                return false
            }
            return true
        }
    }
    
}




