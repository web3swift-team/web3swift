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
    func generateBIP39(completion: ((String?) -> ())? = nil) {
        if let mnemonic = try? BIP39.generateMnemonics(bitsOfEntropy: 128) {
            self.mnemonic = mnemonic
        }
        if let completion = completion {
            completion(self.mnemonic)
        }
    }
    
    
    /// Generates wallet using mnemonic phrase
    /// - Parameter mnemonic: BIP39 mnemonic phrase
    /// - Parameter password: password for wallet
    func generateBIP32(with mnemonic: String, password: String = "web3swift", completion: @escaping () -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.generateBIP39 { mnemonic in
                guard let mnemonic = mnemonic else { return }
                var wallet = Wallet(type: .BIP39(mnemonic: mnemonic), password: password)
                
                if wallet.isHD {
//                    guard let keystore = BIP32Keystore(wallet.data) else { return }
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
//        let data = wallet.data
        
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
    
    func getBalance(for walletAddress: EthereumAddress?) -> String? {
        guard let walletAddress = walletAddress else { return nil }

        let balanceResult = try! web3(provider: InfuraProvider(.Mainnet)!).eth.getBalance(address: walletAddress)
        return Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3)!
    }
    
    func changeCurrentNetwork(chainId: Int) {
        network = Networks.fromInt(chainId) ?? .Mainnet
    }
}
