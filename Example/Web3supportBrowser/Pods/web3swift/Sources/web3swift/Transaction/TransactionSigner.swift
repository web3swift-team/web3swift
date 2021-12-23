//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
//import secp256k1_swift
//import EthereumAddress

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
            var d = BigUInt(0)
            if unmarshalledSignature.v >= 0 && unmarshalledSignature.v <= 3 {
                d = BigUInt(35)
            } else if unmarshalledSignature.v >= 27 && unmarshalledSignature.v <= 30 {
                d = BigUInt(8)
            } else if unmarshalledSignature.v >= 31 && unmarshalledSignature.v <= 34 {
                d = BigUInt(4)
            }
            transaction.v = BigUInt(unmarshalledSignature.v) + d + chainID + chainID
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
            var d = BigUInt(0)
            var a = BigUInt(0)
            if unmarshalledSignature.v >= 0 && unmarshalledSignature.v <= 3 {
                d = BigUInt(27)
            } else if unmarshalledSignature.v >= 31 && unmarshalledSignature.v <= 34 {
                a = BigUInt(4)
            } else if unmarshalledSignature.v >= 35 && unmarshalledSignature.v <= 38 {
                a = BigUInt(8)
            }
            transaction.v = BigUInt(unmarshalledSignature.v) + d - a
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




