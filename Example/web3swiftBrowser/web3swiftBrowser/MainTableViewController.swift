//
//  MainTableViewController.swift
//  web3swiftBrowser
//
//  Created by Petr Korolev on 26.10.2020.
//  Copyright © 2020 Matter Labs. All rights reserved.
//

import UIKit
import web3swift

class MainTableViewController: UITableViewController {
    var wallet: Wallet = Wallet(type: .EthereumKeystoreV3)
    var mnemonics: String? {
        didSet {
            wallet = Wallet.init(type: .BIP39(mnemonic: self.mnemonics!))
            self.genBip32Account(self)
            bipMnemonic.text = self.mnemonics
            self.privKeyLabel.text = "hidden"

        }
    }
    let password = "web3swift"

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBOutlet weak var derPath: UILabel!
    @IBOutlet weak var key: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var prefixTF: UITextField!

    @IBOutlet weak var mnemonic: UILabel!
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var prefixLabel: UILabel!
    @IBOutlet weak var bipMnemonic: UILabel!
    @IBOutlet weak var bipKey: UILabel!
    @IBOutlet weak var privKeyLabel: UILabel!

    @IBAction func getPrivKey(_ sender: Any) {

        let ethereumAddress = EthereumAddress(wallet.address)!
        let km = getKeystoreManager()
        let pkData = try! km.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress).toHexString()
        self.privKeyLabel.text = pkData

    }

    func getKeystoreManager() -> KeystoreManager {
        let data = wallet.data
        let keystoreManager: KeystoreManager
        if wallet.isHD {
            let keystore = BIP32Keystore(data)!
            keystoreManager = KeystoreManager([keystore])
        } else {
            let keystore = EthereumKeystoreV3(data)!
            keystoreManager = KeystoreManager([keystore])
        }
        return keystoreManager
    }


    @IBAction func createAccount(_ sender: Any) {

        let wallet = Wallet(type: .EthereumKeystoreV3)

        accountName.text = wallet.name
        mnemonic.text = wallet.address

    }

    @IBAction func generateBipMnemonic(_ sender: Any) {

        self.mnemonics = try! BIP39.generateMnemonics(bitsOfEntropy: 128)!

    }

    @IBAction func genBip32Account(_ sender: Any) {
        if (self.mnemonics == nil) {
            self.generateBipMnemonic(self)
        }

        let wallet = Wallet(type: .BIP39(mnemonic: self.mnemonics!))

        if wallet.isHD {
            let keystore = BIP32Keystore(wallet.data)!
            prefixLabel.text = keystore.rootPrefix
            derPath.text = keystore.rootPrefix

            if let index = (keystore.rootPrefix.range(of: "/44'/60'/0'")?.upperBound) {
                //prints "=value"
                let afterEqualsToContainingSymbol = String(keystore.rootPrefix.suffix(from: index))
                prefixTF.text = afterEqualsToContainingSymbol
            }

            bipKey.text = wallet.address

            getPrivKey(self)
            genChildAccount(self)
        }
    }

    @IBAction func canged(_ sender: Any) {
        print(derPath.text as Any)

        genChildAccount(self)
    }

    // MARK: CHild account

    @IBAction func genChildAccount(_ sender: Any) {
        if wallet.isHD {
            let keystore = BIP32Keystore(wallet.data)!

            var s: String = prefixTF.text ?? ""
//            s = String(s.dropLast(2))

            do {
                try keystore.createNewCustomChildAccount(path: s)
            } catch let error {
                print(error.localizedDescription)
            }

            textView.invalidateIntrinsicContentSize()

//                try? keystore.createNewChildAccount()

            textView.text = ""
            for (key, value) in keystore.paths {
                textView.text.append("\(key) : \(value.address)\n")
            }
            wallet.data = try! JSONEncoder().encode(keystore.keystoreParams)
        }


    }


}