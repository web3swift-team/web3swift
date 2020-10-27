//
//  PrefferedModels.swift
//  web3swiftBrowser
//
//  Created by Petr Korolev on 26.10.2020.
//  Copyright © 2020 Matter Labs. All rights reserved.
//

import Foundation
import web3swift

struct Wallet {
    enum walletType {
        case EthereumKeystoreV3
        case BIP39(mnemonic: String)
    }

    var name: String = "Wallet"
    var bitsOfEntropy: Int = 128 // Entropy is a measure of password strength. Usually used 128 or 256 bits.
    var password = "web3swift" // We recommend here and everywhere to use the password set by the user.

    var address: String

    var data: Data
    var mnemonics: String? {
        didSet {
            let keystore = try! BIP32Keystore(
                mnemonics: self.mnemonics!,
                    password: password,
                    mnemonicsPassword: "",
                    language: .english)!
            self.data = try! JSONEncoder().encode(keystore.keystoreParams)
            self.isHD = true
            self.address = keystore.addresses!.first!.address
        }
    }
    var isHD: Bool

    init(type: walletType) {
        switch type {
        case .EthereumKeystoreV3:
            let keystore = try! EthereumKeystoreV3(password: password)!
            self.address = keystore.addresses!.first!.address
            self.data = try! JSONEncoder().encode(keystore.keystoreParams)
            self.isHD = false
            self.address = keystore.addresses!.first!.address
           
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
        }


    }
}

struct HDKey {
    let name: String?
    let address: String
}

struct ERC20Token {
    var name: String
    var address: String
    var decimals: String
    var symbol: String
}
