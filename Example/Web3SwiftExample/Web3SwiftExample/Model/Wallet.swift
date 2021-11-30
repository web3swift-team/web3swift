//
//  Wallet.swift
//  Web3SwiftExample
//
//  Created by Максим Алексеев  on 03.11.2021.
//

import Foundation
import web3swift

struct Wallet {
    enum walletType {
        case EthereumKeystoreV3(privateKey: Data)
        case BIP39(mnemonic: String)
    }
    
    // MARK:- Properties
    var name: String = "Wallet"
    /// Entropy is a measure of password strength. Usually used 128 or 256 bits.
    var bitsOfEntropy: Int = 128
    var derivationPath: String = ""

    /// Public key
    var address: String
    var privateKey: String
    
    var data: Data

    
    /// BIP-39 mnemonic phrase
    var mnemonic: String?
    
    /// Is it HD wallet
    var isHD: Bool

    // MARK:- Inits
    init(type: walletType, password: String = "web3swift") {
        switch type {
        case .EthereumKeystoreV3:
            let keystore = try! EthereumKeystoreV3(password: password)!
            self.address = keystore.addresses!.first!.address
            self.data = try! JSONEncoder().encode(keystore.keystoreParams)
            self.isHD = false
            self.address = keystore.addresses!.first!.address
            self.privateKey = try! keystore.UNSAFE_getPrivateKeyData(password: password, account: EthereumAddress(self.address)!).toHexString()
        case .BIP39(mnemonic: let mnemonic):
            let keystore = try! BIP32Keystore(
                               mnemonics: mnemonic,
                               password: password,
                               mnemonicsPassword: "",
                               language: .english)!
            self.name = "HD Wallet"
            self.data = try! JSONEncoder().encode(keystore.keystoreParams)
            self.isHD = true
            self.address = keystore.addresses!.first!.address
            self.privateKey = try! keystore.UNSAFE_getPrivateKeyData(password: password, account: EthereumAddress(self.address)!).toHexString()
        }
    }
}
