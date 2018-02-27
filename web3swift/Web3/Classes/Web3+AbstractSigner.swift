//
//  Web3Swift+AbstractSigner.swift
//  web3swift
//
//  Created by Alexander Vlasov on 15.01.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

public struct Web3Signer {
    public static func signTX(transaction:inout EthereumTransaction, keystore: AbstractKeystore, account: EthereumAddress, password: String) throws {
        var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
        defer {Data.zero(&privateKey)}
        if (transaction.chainID != nil) {
            let signer = EIP155Signer()
            try signer.sign(transaction: &transaction, privateKey: privateKey)
        } else {
            let signer = FallbackSigner()
            try signer.sign(transaction: &transaction, privateKey: privateKey)
        }
    }
    public static func signIntermediate(intermediate:inout TransactionIntermediate, keystore: AbstractKeystore, account: EthereumAddress, password: String) throws {
        var tx = intermediate.transaction
        try Web3Signer.signTX(transaction: &tx, keystore: keystore, account: account, password: password)
        intermediate.transaction = tx
    }
    public static func signPersonalMessage(_ personalMessage: Data, keystore: AbstractKeystore, account: EthereumAddress, password: String) throws -> Data? {
        var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
        defer {Data.zero(&privateKey)}
        guard let hash = Web3.Utils.hashPersonalMessage(personalMessage) else {return nil}
        let (compressedSignature, _) = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey)
        return compressedSignature
    }
}
