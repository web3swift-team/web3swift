//
//  CreateWalletWrapper.swift
//   Wallet
//
//  Created by Ravi Ranjan on 22/08/21.
//  Copyright © 2021 oodlesTechnologies_r.ranjanchn@gmail.com. All rights reserved.
//

import Foundation
import Foundation
import web3swift
class CreateWalletWrapper: NSObject {
    /*
     Create wallet method
     */
    var prefixPath: String
    init(prefixPath:String) {
        self.prefixPath = prefixPath
    }
    
    public  func createWallet() throws {
        
        var web3KeyStore: BIP32Keystore?
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let web3KeystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
        do {
            if (web3KeystoreManager?.addresses.count ?? 0 >= 0) {
                let web3Mnemonics = Mnemonics(entropySize: EntropySize.b128, language: .english)
                print(web3Mnemonics.description)
                /*
                 save  Mnemonics for later user also it can be stored some other place
                 */
                UserDefaults.standard.set(web3Mnemonics.description, forKey: KeyConstants.UserDefaults.kUserMnemonics)
                web3KeyStore = try BIP32Keystore(mnemonics: web3Mnemonics, prefixPath: prefixPath)
                print("keystore", web3KeyStore as Any)
                guard let kStore = web3KeyStore else {
                    return
                }
                let address = kStore.addresses.first
                let param = kStore.keystoreParams
                #if DEBUG
                print("Mnemonics :-> ", web3Mnemonics.description)
                print("Address :::>>>>> ", address as Any)
                print("Address :::>>>>> ", kStore.addresses as Any)
                let privatKey = try kStore.UNSAFE_getPrivateKeyData(password: "", account: address!)
                print(privatKey, "Is the private key")
                #endif
                let keyData = try? JSONEncoder().encode(param)
                FileManager.default.createFile(atPath: userDir + "/keystore"+"/key.json", contents: keyData, attributes: nil)
            } else {
                web3KeyStore = web3KeystoreManager?.walletForAddress((web3KeystoreManager?.addresses[0])!) as? BIP32Keystore
            }
        } catch {
            throw WalletCreationError.error
        }
    }
    
}
