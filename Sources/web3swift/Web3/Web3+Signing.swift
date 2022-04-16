//  Package: web3swift
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
// Refactor to support EIP-2718 Enveloping by Mark Loit 2022

import Foundation
import BigInt

public struct Web3Signer {
    public static func signTX(transaction: inout EthereumTransaction,
                              keystore: AbstractKeystore,
                              account: EthereumAddress,
                              password: String,
                              useExtraEntropy: Bool = false) throws {
        var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
        defer { Data.zero(&privateKey) }
        try transaction.sign(privateKey: privateKey, useExtraEntropy: useExtraEntropy)
    }

    public static func signPersonalMessage<T: AbstractKeystore>(_ personalMessage: Data,
                                                                keystore: T,
                                                                account: EthereumAddress,
                                                                password: String,
                                                                useExtraEntropy: Bool = false) throws -> Data? {
        var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
        defer { Data.zero(&privateKey) }
        guard let hash = Web3.Utils.hashPersonalMessage(personalMessage) else { return nil }
        let (compressedSignature, _) = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
        return compressedSignature
    }

    public static func signEIP712(safeTx: SafeTx,
                                  keystore: BIP32Keystore,
                                  verifyingContract: EthereumAddress,
                                  account: EthereumAddress,
                                  password: String? = nil,
                                  chainId: BigUInt? = nil) throws -> Data {

        let domainSeparator: EIP712DomainHashable = EIP712Domain(chainId: chainId, verifyingContract: verifyingContract)

        let password = password ?? ""
        let hash = try eip712encode(domainSeparator: domainSeparator, message: safeTx)

        guard let signature = try Web3Signer.signPersonalMessage(hash, keystore: keystore, account: account, password: password) else {
            throw Web3Error.dataError
        }

        return signature
    }
}
