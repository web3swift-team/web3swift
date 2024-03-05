//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
//  Refactor to support EIP-2718 Enveloping by Mark Loit 2022

import Foundation
import BigInt
import Web3Core

public struct Web3Signer {
    public static func signTX(transaction: inout CodableTransaction,
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
                                                                useHash: Bool = true,
                                                                useExtraEntropy: Bool = false) throws -> Data? {
        var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
        defer { Data.zero(&privateKey) }
        var data: Data
        if useHash {
            guard let hash = Utilities.hashPersonalMessage(personalMessage) else { return nil }
            data = hash
        } else {
            data = personalMessage
        }
        let (compressedSignature, _) = SECP256K1.signForRecovery(hash: data,
                                                                 privateKey: privateKey,
                                                                 useExtraEntropy: useExtraEntropy)
        return compressedSignature
    }

    public static func signEIP712(_ eip712TypedDataPayload: EIP712TypedData,
                                  keystore: AbstractKeystore,
                                  account: EthereumAddress,
                                  password: String? = nil) throws -> Data {
        let hash = try eip712TypedDataPayload.signHash()
        guard let signature = try Web3Signer.signPersonalMessage(hash,
                                                                 keystore: keystore,
                                                                 account: account,
                                                                 password: password ?? "",
                                                                 useHash: false)
        else {
            throw Web3Error.dataError
        }
        return signature
    }

    public static func signEIP712(_ eip712Hashable: EIP712Hashable,
                                  keystore: AbstractKeystore,
                                  verifyingContract: EthereumAddress,
                                  account: EthereumAddress,
                                  password: String? = nil,
                                  chainId: BigUInt? = nil) throws -> Data {

        let domainSeparator: EIP712Hashable = EIP712Domain(chainId: chainId, verifyingContract: verifyingContract)
        let hash = try eip712hash(domainSeparator: domainSeparator, message: eip712Hashable)
        guard let signature = try Web3Signer.signPersonalMessage(hash,
                                                                 keystore: keystore,
                                                                 account: account,
                                                                 password: password ?? "",
                                                                 useHash: false)
        else {
            throw Web3Error.dataError
        }
        return signature
    }
}
