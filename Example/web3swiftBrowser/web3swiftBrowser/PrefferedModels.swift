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
    enum walletType: Int {
        case EthereumKeystoreV3
        case BIP39
    }

    var name: String = "Wallet"
    var bitsOfEntropy: Int = 128 // Entropy is a measure of password strength. Usually used 128 or 256 bits.
    var password = "web3swift" // We recommend here and everywhere to use the password set by the user.

    var address: String
    var keystore: AbstractKeystore
    var data: Data
    var isHD: Bool

    init(type: walletType) {
        switch type {
        case .EthereumKeystoreV3:
            keystore = try! EthereumKeystoreV3(password: password)!
            self.address = keystore.addresses!.first!.address
            self.data = try! JSONEncoder().encode(keystore.giveKeystoreParams())
            self.isHD = false

        case .BIP39:
            let mnemonics = try! BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy)!
            keystore = try! BIP32Keystore(
                    mnemonics: mnemonics,
                    password: password,
                    mnemonicsPassword: "",
                    language: .english)!
            self.name = "HD Wallet"
            self.data = try! JSONEncoder().encode(keystore.giveKeystoreParams())
            self.isHD = true
        }

        self.address = keystore.addresses!.first!.address
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
