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

public struct EIP155Signer {
    public func sign(transaction:inout EthereumTransaction, privateKey: Data) throws {
        for _ in 0..<1024 {
            let result = self.attemptSignature(transaction: &transaction, privateKey: privateKey)
            if (result) {
                return
            }
        }
        throw AbstractKeystoreError.invalidAccountError
    }
        
    private func attemptSignature(transaction:inout EthereumTransaction, privateKey: Data) -> Bool {
        guard let chainID = transaction.chainID else {return false}
        guard let hash = transaction.hashForSignature(chainID: chainID) else {return false}
        let signature  = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey)
        guard let compressedSignature = signature.compressed else {return false}
        guard let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: compressedSignature) else {
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
    public func sign(transaction:inout EthereumTransaction, privateKey: Data) throws {
        for _ in 0..<1024 {
            let result = self.attemptSignature(transaction: &transaction, privateKey: privateKey)
            if (result) {
                return
            }
        }
        throw AbstractKeystoreError.invalidAccountError
    }
    
    private func attemptSignature(transaction:inout EthereumTransaction, privateKey: Data) -> Bool {
        guard let hash = transaction.hashForSignature(chainID: nil) else {return false}
        let signature  = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey)
        guard let compressedSignature = signature.compressed else {return false}
        guard let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: compressedSignature) else {
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

