//
//  Web3Swift+AbstractSigner.swift
//  web3swift
//
//  Created by Alexander Vlasov on 15.01.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

public struct Web3AbstractSigner {
    public static func signedTX(transaction:EthereumTransaction, privateKey: Data) throws -> EthereumTransaction? {
        var newTX = transaction
        guard newTX.sign(privateKey: privateKey) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
        return newTX
    }
    public static func signTX( transaction:inout EthereumTransaction, privateKey: Data) throws {
        guard transaction.sign(privateKey: privateKey) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
    }
    public static func signIntermediate(intermediate: TransactionIntermediate, privateKey: Data) throws {
        try intermediate.sign(privateKey)
    }
    public static func signPersonalMessage(_ personalMessage: Data, privateKey: Data) throws -> Data? {
        var hash: Data
        if personalMessage.count == 32 {
            print("Most likely it's hash already, allow for now")
            hash = personalMessage
        } else {
            guard let h = Web3.Utils.hashPersonalMessage(personalMessage) else {return nil}
            hash = h
        }
        let (compressedSignature, _) = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey)
        return compressedSignature
    }
}
