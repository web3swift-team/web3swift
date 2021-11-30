//
//  BalanceViewController.swift
//  Web3SwiftExample
//
//  Created by Максим Алексеев  on 27.11.2021.
//

import UIKit
import web3swift

class BalanceViewController: UIViewController {
    var web3Service: Web3SwiftService!
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addressTextField.delegate = self
    }
    
    private func showBalance() {
        guard let addressText = addressTextField.text else { return }
        if let address = try? web3Service.ens.getAddress(forNode: addressText) {
            balanceLabel.text = web3Service.getBalance(for: address)
            return
        }
        
        let address = EthereumAddress(addressText)!
        balanceLabel.text = web3Service.getBalance(for: address)
    }
}

extension BalanceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        showBalance()
        return true
    }
}
