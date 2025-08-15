//
//  AuthViewController.swift
//  myWeb3Wallet
//
//  Created by Ravi Ranjan on 22/10/21.
//

import UIKit
import web3swift
import Web3Core

class AuthViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var importWalletButton: UIButton!
    @IBOutlet weak var createWalletButton: UIButton!

    var walletAddress: String? {
        didSet {
            self.walletAddressLabel.text = walletAddress
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.createWalletButton.layer.cornerRadius = 5.0
        self.importWalletButton.layer.cornerRadius = 5.0
    }

    @IBAction func onClickCreateWallet(_ sender: UIButton) {
        self.createMnemonics()

    }
    @IBAction func onClickImportWalletButton(_ sender: UIButton) {
        self.showImportAlert()
    }

    @IBAction func onClickContinueButton(_ sender: UIButton) {
    }
}

extension AuthViewController {
    func showImportAlert() {
        let alert = UIAlertController(title: "MyWeb3Wallet", message: "", preferredStyle: .alert)
        alert.addTextField { textfied in
            textfied.placeholder = "Enter mnemonics/private Key"
        }
        let mnemonicsAction = UIAlertAction(title: "Mnemonics", style: .default) { _ in
            guard let mnemonics = alert.textFields?[0].text else { return }
            self.importWalletWith(mnemonics: mnemonics)
        }
        let privateKeyAction = UIAlertAction(title: "Private Key", style: .default) { _ in
            guard let privateKey = alert.textFields?[0].text else { return }
            self.importWalletWith(privateKey: privateKey)

        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(mnemonicsAction)
        alert.addAction(privateKeyAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func createMnemonics() {
        guard let mnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: 256, language: .english) else {
            self.showAlertMessage(title: "", message: "We are unable to create wallet", actionName: "Ok")
            return
        }
        print(mnemonics)

        guard let keystore = try? BIP32Keystore(mnemonics: mnemonics, password: WalletManager.keystorePassword),
              let walletAddress = keystore.addresses?.first else {
            self.showAlertMessage(title: "", message: "Unable to create wallet", actionName: "Ok")
            return
        }
        self.walletAddress = walletAddress.address
        let privateKey = try! keystore.UNSAFE_getPrivateKeyData(password: WalletManager.keystorePassword,
                                                                account: walletAddress)
        print(privateKey)

        Task {
            let walletManager = await WalletManager(keystoreManager: KeystoreManager([keystore]))
            openWallet(walletManager: walletManager)
        }
    }

    func importWalletWith(privateKey: String) {
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let dataKey = Data.fromHex(formattedKey) else {
            self.showAlertMessage(title: "Error", message: "Please enter a valid Private key ", actionName: "Ok")
            return
        }
        do {
            guard let keystore = try EthereumKeystoreV3(privateKey: dataKey, password: WalletManager.keystorePassword),
                  let address = keystore.addresses?.first?.address else {
                throw NSError(domain: "Unknown", code: 400)
            }
            self.walletAddress = address
            Task { @MainActor in
                let walletManager = await WalletManager(keystoreManager: KeystoreManager([keystore]))
                openWallet(walletManager: walletManager)
            }
        } catch {
            let alert = UIAlertController(title: "Error", message: "Please enter correct Private key", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .destructive)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }

    }

    func importWalletWith(mnemonics: String) {
        guard let keystore = try? BIP32Keystore(mnemonics: mnemonics, password: WalletManager.keystorePassword),
              let walletAddress = keystore.addresses?.first else {
            self.showAlertMessage(title: "", message: "Unable to create wallet", actionName: "Ok")
            return
        }
        self.walletAddress = walletAddress.address
        Task { @MainActor in
            let walletManager = await WalletManager(keystoreManager: KeystoreManager([keystore]))
            openWallet(walletManager: walletManager)
        }
    }

    func openWallet(walletManager: WalletManager) {
        let walletVC = WalletViewController(walletManager: walletManager)
        navigationController?.setViewControllers([walletVC], animated: true)
    }
}

extension UIViewController {
    func showAlertMessage(title: String = "MyWeb3Wallet", message: String = "Message is empty", actionName: String = "OK") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: actionName, style: .destructive)
        alertController.addAction(action)
        self.present(alertController, animated: true)
    }
}
