//
//  KeystoreSignatureProvider.swift
//  
//
//  Created by Ostap Danylovych on 12.01.2022.
//

import Foundation

public struct KeystoreSignatureProvider<Keystore: AbstractKeystore>: SignatureProvider {
    private let keystore: Keystore
    
    public init(keystore: Keystore) {
        self.keystore = keystore
    }
    
    public func accounts(_ cb: @escaping SignatureProviderCallback<[EthereumAddress]>) {
        guard let accounts = keystore.addresses else {
            cb(.failure(Web3Error.inputError(desc: "Cannot get accounts")))
            return
        }
        cb(.success(accounts))
    }
    
    public func sign(transaction: EthereumTransaction,
                     with account: EthereumAddress,
                     using password: String,
                     _ cb: @escaping SignatureProviderCallback<EthereumTransaction>) {
        var transaction = transaction
        do {
            try Web3Signer.signTX(transaction: &transaction, keystore: keystore, account: account, password: password)
        } catch {
            cb(.failure(error))
            return
        }
        cb(.success(transaction))
    }
    
    public func sign(message: Data,
                     with account: EthereumAddress,
                     using password: String,
                     _ cb: @escaping SignatureProviderCallback<Data>) {
        let signedData: Data?
        do {
            signedData = try Web3Signer.signPersonalMessage(message, keystore: keystore, account: account, password: password)
        } catch {
            cb(.failure(error))
            return
        }
        guard let signedData = signedData else {
            cb(.failure(Web3Error.inputError(desc: "Cannot sign a message. Message: \(String(describing: message)). Account: \(String(describing: account))")))
            return
        }
        cb(.success(signedData))
    }
}
