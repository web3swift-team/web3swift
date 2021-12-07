//
//  WalletViewController.swift
//  Web3SwiftExample
//
//  Created by Максим Алексеев  on 04.11.2021.
//

import UIKit

class WalletViewController: UIViewController {
    // MARK: - Dependencies
    var web3Service: Web3SwiftService!
    
    // MARK: - Private properties
    
    // MARK: - Views
    @IBOutlet weak var mnemonicTextView: UITextView!
    @IBOutlet weak var publicKeyTextView: UITextView!
    @IBOutlet weak var privateKeyLabel: UILabel!
    @IBOutlet weak var derrivationPathLabel: UILabel!
    @IBOutlet weak var generateAccountButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Bundle.main.loadNibNamed("WalletView", owner: self, options: nil)
    }
    
    // MARK: - Setups
    
    // MARK: - Actions
    @IBAction func generateButtonTouched(_ sender: UIButton) {
        web3Service.generateBIP32(with: web3Service.mnemonic) { [weak self] in
            self?.mnemonicTextView.text = self?.web3Service.mnemonic
            self?.publicKeyTextView.text = self?.web3Service.wallet?.address
            self?.derrivationPathLabel.text = self?.web3Service.wallet?.derivationPath
            self?.privateKeyLabel.text = self?.web3Service.wallet?.privateKey
            self?.balanceLabel.text = strongSelf.web3Service.getBalance(for: self?.web3Service.wallet!.keystore.addresses?.first!)
        }
    }
    
    @IBAction func settingButtonTouched(_ sender: UIButton) {
        let networkViewController = NetworkViewController()
        present(networkViewController, animated: true)
    }
}
