//
//  ENSViewController.swift
//  Web3SwiftExample
//
//  Created by Максим Алексеев  on 26.11.2021.
//

import UIKit

class ENSViewController: UIViewController {
    // MARK: - Dependencies
    var web3Service: Web3SwiftService! 
    
    // MARK: - Views 
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nodeTextField: UITextField!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nodeTextField.delegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addressLabelSelected))
        addressLabel.addGestureRecognizer(gestureRecognizer)
    }

    // MARK: - Setup
    private func configureLabels() {
        guard let node = nodeTextField.text else { return }
        addressLabel.text = try! web3Service.ens.getAddress(forNode: node).address
    }
    
    // MARK: - Selectors
    @objc private func addressLabelSelected() {
        UIPasteboard.general.string = addressLabel.text
    }
}

extension ENSViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        configureLabels()
        return true
    }
}
