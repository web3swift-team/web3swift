//
//  Web3SwiftService.swift
//  Web3SwiftExample
//
//  Created by Максим Алексеев  on 03.11.2021.
//

import Foundation
import web3swift

class Web3SwiftService {
    // MARK:- Properties
    var mnemonic: String = "" 
    var wallet: Wallet?
    var keystoreManager: KeystoreManager?
    var password: String = "web3swift"
    
    // MARK:- Functions
    /// Generates mnemonic phrase
    func generateBIP39(completion: @escaping (String?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let mnemonic = try? BIP39.generateMnemonics(bitsOfEntropy: 128) {
                self.mnemonic = mnemonic
            }
            DispatchQueue.main.async {
                completion(self.mnemonic)
            }
        }
    }
    
    /// Generates wallet using mnemonic phrase
    /// - Parameter mnemonic: BIP39 mnemonic phrase
    /// - Parameter password: password for wallet
    func generateBIP32(with mnemonic: String, password: String = "web3swift", completion: @escaping () -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            var wallet = Wallet(type: .BIP39(mnemonic: mnemonic), password: password)
            
            if wallet.isHD {
                guard let keystore = BIP32Keystore(wallet.data) else { return }
                wallet.derivationPath = keystore.rootPrefix
                self.wallet = wallet
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    /// Generates wallet using private key
    /// - Parameters:
    ///   - privateKey: Private key for wallet
    ///   - password: Password for wallet
    func generateWallet(with privateKey: String, password: String = "web3swift", completion: @escaping () -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let dataKey = Data.fromHex(formattedKey) else { return }
            
            self.wallet = Wallet(type: .EthereumKeystoreV3(privateKey: dataKey), password: password)
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    // MARK:- Private methods
    private func getKeystoreManager() -> KeystoreManager?  {
        guard let wallet = wallet else { return nil }
        let data = wallet.data
        
        var keystoreManager: KeystoreManager
        if wallet.isHD {
            let keystore = BIP32Keystore(data)!
            keystoreManager = KeystoreManager([keystore])
        } else {
            let keystore = EthereumKeystoreV3(data)!
            keystoreManager = KeystoreManager([keystore])
        }
        
        return keystoreManager
    }
}
