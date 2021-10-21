//
//  WalletViewController.swift
//  myWeb3Wallet
//
//  Created by Ravi Ranjan on 22/10/21.
//

import UIKit
import web3swift
class WalletViewController: UIViewController {
    
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var importWalletButton: UIButton!
    @IBOutlet weak var createWalletButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createWalletButton.layer.cornerCurve = .continuous
        self.importWalletButton.layer.cornerCurve = .continuous
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onClickCreateWallet(_ sender: UIButton) {
#if DEBUG
        print("Clicked on Create Wallet Option")
#endif
        self.createMnemonics()
        
    }
    @IBAction func onClickImportWalletButton(_ sender: UIButton) {
#if DEBUG
        print("Clicked on import Wallet Option")
#endif
        let alert = UIAlertController(title: "MyWeb3Wallet", message: "", preferredStyle: .alert)
        alert.addTextField { textfied in
            textfied.placeholder = "Enter mnemonics/private Key"
        }
        let mnemonicsAction = UIAlertAction(title: "Mnemonics", style: .default) { _ in
#if DEBUG
            print("Clicked on Mnemonics Option")
#endif
            guard let mnemonics = alert.textFields?[0].text else { return }
            print(mnemonics)
        }
        let privateKeyAction = UIAlertAction(title: "Private Key", style: .default) { _ in
#if DEBUG
            print("Clicked on Private Key Wallet Option")
#endif
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
    
    
    func importWalletWith(privateKey: String){
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let dataKey = Data.fromHex(formattedKey) else {
            self.showAlertMessage(title: "Error", message: "Please enter a valid Private key ", actionName: "Ok")
            return
        }
        do {
            let keystore =  try EthereumKeystoreV3(privateKey: dataKey)
            if let myWeb3KeyStore = keystore {
                let manager = KeystoreManager([myWeb3KeyStore])
                let address = keystore?.addresses?.first
#if DEBUG
                print("Address :::>>>>> ", address as Any)
                print("Address :::>>>>> ", manager.addresses as Any)
#endif
                let walletAddress = manager.addresses?.first?.address
                self.walletAddressLabel.text = walletAddress ?? "0x"
                
                print(walletAddress as Any)
            } else {
                print("error")
            }
        } catch {
#if DEBUG
            print("error creating keyStrore")
            print("Private key error.")
#endif
            let alert = UIAlertController(title: "Error", message: "Please enter correct Private key", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .destructive)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
        
        
        
    }
    func importWalletWith(mnemonics: String) {
        let walletAddress = try? BIP32Keystore(mnemonics: mnemonics , prefixPath: "m/44'/77777'/0'/0")
        print(walletAddress?.addresses as Any)
        self.walletAddressLabel.text = "\(walletAddress?.addresses?.first?.address ?? "0x")"
        
    }
    
    
}
extension WalletViewController {
    
    fileprivate func createMnemonics(){
        let mnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: 256, language: .english)
        print(mnemonics as Any)
        let walletAddress = try? BIP32Keystore(mnemonics: mnemonics ?? "", prefixPath: "m/44'/77777'/0'/0")
        print(walletAddress?.addresses as Any)
        self.walletAddressLabel.text = "\(walletAddress?.addresses?.first?.address ?? "0x")"
        
        
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
