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
    @IBOutlet weak var generateAccountButton: UIButton!
    @IBOutlet weak var pathTextField: UITextField!
    @IBOutlet weak var walletsTextView: UITextView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Bundle.main.loadNibNamed("WalletView", owner: self, options: nil)
        pathTextField.delegate = self
        activityIndicatorView.isHidden = true
    }
    
    // MARK: - Setups
    
    // MARK: - Actions
    @IBAction func generateButtonTouched(_ sender: UIButton) {
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
        web3Service.generateBIP32 { [weak self] in
            self?.activityIndicatorView.stopAnimating()
            self?.activityIndicatorView.isHidden = true
            
            self?.mnemonicTextView.text = self?.web3Service.mnemonic
            self?.publicKeyTextView.text = self?.web3Service.wallet?.address
            self?.privateKeyLabel.text = self?.web3Service.wallet?.privateKey
        }
    }
}

extension WalletViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let path = textField.text else { return true }
        
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
        
        web3Service.createChildAccount(path: path) { [weak self] pathPairs in
            self?.walletsTextView.text = ""
            pathPairs.forEach { pathPair in
                self?.walletsTextView.text.append("\(pathPair.path) : \(pathPair.address) \n")
                
                self?.activityIndicatorView.stopAnimating()
                self?.activityIndicatorView.isHidden = true
            }
        }
        
        return true
    }
}
