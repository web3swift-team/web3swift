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

    var ethKeysoreV3: EthereumKeystoreV3! = nil
    var bip32Keystore: BIP32Keystore! = nil 
    
    // MARK:- Inits
    init(type: walletType, password: String = "web3swift") {
        switch type {
        case .EthereumKeystoreV3:
            ethKeysoreV3 = try! EthereumKeystoreV3(password: password)!
            self.address = ethKeysoreV3?.addresses!.first!.address ?? ""
            self.data = try! JSONEncoder().encode(ethKeysoreV3.keystoreParams)
            self.isHD = false
            self.privateKey = try! ethKeysoreV3.UNSAFE_getPrivateKeyData(password: password, account: EthereumAddress(self.address)!).toHexString() as! String
        case .BIP39(mnemonic: let mnemonic):
            bip32Keystore = try! BIP32Keystore(
                               mnemonics: mnemonic,
                               password: password,
                               mnemonicsPassword: "",
                               language: .english)!
            self.name = "HD Wallet"
            self.data = try! JSONEncoder().encode(bip32Keystore?.keystoreParams)
            self.isHD = true
            self.address = bip32Keystore?.addresses!.first!.address ?? ""
            self.privateKey = try! bip32Keystore?.UNSAFE_getPrivateKeyData(password: password, account: EthereumAddress(self.address)!).toHexString() as! String
        }
    }
}
