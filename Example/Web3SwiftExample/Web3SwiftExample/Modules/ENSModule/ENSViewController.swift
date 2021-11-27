//
//  ENSViewController.swift
//  Web3SwiftExample
//
//  Created by Максим Алексеев  on 26.11.2021.
//

import UIKit

class ENSViewController: UIViewController {
    // MARK: - Dependencies
    var web3service = Web3SwiftService()
    
    // MARK: - Views 
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nodeTextField: UITextField!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nodeTextField.delegate = self
    }

    
    private func configureLabels() {
        guard let node = nodeTextField.text else { return }
        addressLabel.text = try! web3service.ens.getAddress(forNode: node).address
    }
}

extension ENSViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        configureLabels()
        return true
    }
}
