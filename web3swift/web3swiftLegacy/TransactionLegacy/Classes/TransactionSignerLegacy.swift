//
//  TransactionSigner.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
//import Result
import BigInt
import secp256k1_swift
import EthereumAddress

extension Web3Signer {
    
    @available(*, deprecated, message: "Don't use TransactionIntermediate anymore")
    public static func signIntermediate(intermediate:inout TransactionIntermediate, keystore: AbstractKeystore, account: EthereumAddress, password: String, useExtraEntropy: Bool = false) throws {
        var tx = intermediate.transaction
        try Web3Signer.signTX(transaction: &tx, keystore: keystore, account: account, password: password, useExtraEntropy: useExtraEntropy)
        intermediate.transaction = tx
    }
    
}




