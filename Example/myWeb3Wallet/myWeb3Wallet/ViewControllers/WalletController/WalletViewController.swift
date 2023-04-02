//
//  WalletViewController.swift
//  myWeb3Wallet
//
//  Created by Ravi Ranjan on 22/10/21.
//

import UIKit
import web3swift
import Web3Core

class WalletViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var importWalletButton: UIButton!
    @IBOutlet weak var createWalletButton: UIButton!
    var _walletAddress: String {
        set {
            self.continueButton.isHidden = false
            self.walletAddressLabel.text = newValue
        }
        get {
            return self._walletAddress
        }
    }
    var _mnemonics: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createWalletButton.layer.cornerRadius = 5.0
        self.importWalletButton.layer.cornerRadius = 5.0

        // Do any additional setup after loading the view.
    }

    @IBAction func onClickCreateWallet(_ sender: UIButton) {
#if DEBUG
        print("Clicked on Create Wallet Option")
#endif
        self.createMnemonics()

    }
    @IBAction func onClickImportWalletButton(_ sender: UIButton) {
        print("Clicked on import Wallet Option")
        self.showImportALert()
    }

    @IBAction func onClickContinueButton(_ sender: UIButton) {
        print("Clicked on COntinue button")
        guard let dashboardScreen = self.storyboard?.instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController else {
#if DEBUG
            printContent("Unable to get Wallet controller")
#endif
            return
        }
        self.navigationController?.pushViewController(dashboardScreen, animated: true)
    }
    fileprivate func showImportALert() {
        let alert = UIAlertController(title: "MyWeb3Wallet", message: "", preferredStyle: .alert)
        alert.addTextField { textfied in
            textfied.placeholder = "Enter mnemonics/private Key"
        }
        let mnemonicsAction = UIAlertAction(title: "Mnemonics", style: .default) { _ in
            print("Clicked on Mnemonics Option")
            guard let mnemonics = alert.textFields?[0].text else { return }
            print(mnemonics)
        }
        let privateKeyAction = UIAlertAction(title: "Private Key", style: .default) { _ in
            print("Clicked on Private Key Wallet Option")
            guard let privateKey = alert.textFields?[0].text else { return }
            print(privateKey)
            self.importWalletWith(privateKey: privateKey)

        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(mnemonicsAction)
        alert.addAction(privateKeyAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    func importWalletWith(privateKey: String) {
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let dataKey = Data.fromHex(formattedKey) else {
            self.showAlertMessage(title: "Error", message: "Please enter a valid Private key ", actionName: "Ok")
            return
        }
        do {
            let keystore =  try EthereumKeystoreV3(privateKey: dataKey, password: "")
            if let myWeb3KeyStore = keystore {
                let manager = KeystoreManager([myWeb3KeyStore])
                let address = keystore?.addresses?.first
#if DEBUG
                print("Address :::>>>>> ", address)
                print("Address :::>>>>> ", manager.addresses)
#endif
                let walletAddress = manager.addresses?.first?.address
                self.walletAddressLabel.text = walletAddress ?? "0x"

                print(walletAddress)
            } else {
                print("error")
            }
        } catch {
#if DEBUG
            print("error creating keyStore")
            print("Private key error.")
#endif
            let alert = UIAlertController(title: "Error", message: "Please enter correct Private key", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .destructive)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }

    }

    func importWalletWith(mnemonics: String) {
        let walletAddress = try? BIP32Keystore(mnemonics: mnemonics, password: "", prefixPath: "m/44'/77777'/0'/0")
        self.walletAddressLabel.text = "\(walletAddress?.addresses?.first?.address ?? "0x")"
    }
}

extension WalletViewController {

    fileprivate func createMnemonics() {
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let web3KeystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
        do {
            if web3KeystoreManager?.addresses?.count ?? 0 >= 0 {
                let tempMnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: 256, language: .english)
                guard let tMnemonics = tempMnemonics else {
                    self.showAlertMessage(title: "", message: "We are unable to create wallet", actionName: "Ok")
                    return
                }
                self._mnemonics = tMnemonics
                print(_mnemonics)

                let tempWalletAddress = try? BIP32Keystore(mnemonics: self._mnemonics, password: "", prefixPath: "m/44'/77777'/0'/0")
                guard let walletAddress = tempWalletAddress?.addresses?.first else {
                    self.showAlertMessage(title: "", message: "Unable to create wallet", actionName: "Ok")
                    return
                }
                self._walletAddress = walletAddress.address
                let privateKey = try tempWalletAddress?.UNSAFE_getPrivateKeyData(password: "", account: walletAddress)
#if DEBUG
                print(privateKey, "Is the private key")
#endif
                let keyData = try? JSONEncoder().encode(tempWalletAddress?.keystoreParams)
                FileManager.default.createFile(atPath: userDir + "/keystore" + "/key.json", contents: keyData, attributes: nil)
            }
        } catch {

        }

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
