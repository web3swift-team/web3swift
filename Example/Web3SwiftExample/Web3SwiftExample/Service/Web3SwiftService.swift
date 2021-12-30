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
    /// Current network in which you will work
    var network: Networks = .Mainnet
    lazy var ens = ENS(web3: web3(provider: InfuraProvider(network)!))!
    
    // MARK:- Functions
    /// Generates mnemonic phrase
    func generateBIP39(completion: @escaping () -> ()) {
        if let mnemonic = try? BIP39.generateMnemonics(bitsOfEntropy: 128) {
            self.mnemonic = mnemonic
        }
        
        completion()
        
    }
    
    
    /// Generates wallet using mnemonic phrase
    /// - Parameter mnemonic: BIP39 mnemonic phrase
    /// - Parameter password: password for wallet
    func generateBIP32(password: String = "web3swift", completion: @escaping () -> ()) {
        self.generateBIP39 {
            DispatchQueue.global().async {
                var wallet = Wallet(type: .BIP39(mnemonic: self.mnemonic), password: password)
                
                if wallet.isHD {
                    guard let keystore = wallet.keystore as? BIP32Keystore else { return }
                    wallet.derivationPath = keystore.rootPrefix
                    self.wallet = wallet
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }
    
    
    /// Generates wallet using private key
    /// - Parameters:
    ///   - privateKey: Private key for wallet
    ///   - password: Password for wallet
    func generateWallet(with privateKey: String, password: String = "web3swift", completion: @escaping () -> ()) {
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let dataKey = Data.fromHex(formattedKey) else { return }
        
        self.wallet = Wallet(type: .EthereumKeystoreV3(privateKey: dataKey), password: password)
        completion()
    }
    
    // MARK:- Private methods
    private func getKeystoreManager() -> KeystoreManager?  {
        guard let wallet = wallet else { return nil }
        
        var keystoreManager: KeystoreManager
        if wallet.isHD {
            guard let keystore = wallet.keystore as? BIP32Keystore else { return nil }
            keystoreManager = KeystoreManager([keystore])
        } else {
            guard let keystore = wallet.keystore as? EthereumKeystoreV3 else { return nil }
            keystoreManager = KeystoreManager([keystore])
        }
        
        return keystoreManager
    }
    
    func getBalance(for walletAddress: EthereumAddress?, complete: @escaping (String?) -> ()) {
        DispatchQueue.global().async {
            if let walletAddress = walletAddress {
                let balanceResult = try! web3(provider: InfuraProvider(.Mainnet)!).eth.getBalance(address: walletAddress)
                complete(Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3)!)
            } else  {
                complete(nil)
            }
        }
    }
    
    func changeCurrentNetwork(chainId: Int) {
        network = Networks.fromInt(chainId) ?? .Mainnet
    }
    
    func createChildAccount(path: String) -> [PathAddressPair] {
        do {
            try wallet?.bip32Keystore.createNewCustomChildAccount(path: path)
        } catch let error {
            print(error.localizedDescription)
        }
        
        guard let wallet = wallet else {
            return []
        }
        
        return wallet.bip32Keystore.addressStorage.toPathAddressPairs()
    }
}
