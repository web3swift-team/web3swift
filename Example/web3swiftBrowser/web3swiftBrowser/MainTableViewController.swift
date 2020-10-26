//
//  MainTableViewController.swift
//  web3swiftBrowser
//
//  Created by Petr Korolev on 26.10.2020.
//  Copyright © 2020 Matter Labs. All rights reserved.
//

import UIKit
import web3swift

class MainTableViewController: UITableViewController {
    var wallet: Wallet = Wallet(type: .EthereumKeystoreV3)
    let password = "web3swift"
     
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBOutlet weak var mnemonic: UILabel!

    
    @IBOutlet weak var accountName: UILabel!

    
    @IBAction func createAccount(_ sender: Any) {
        
        let wallet = Wallet(type: .EthereumKeystoreV3)
        
        accountName.text = wallet.name
        mnemonic.text = wallet.address
        
    }
    @IBAction func generateBipMnemonic(_ sender: Any) {
        
        let wallet = Wallet(type: .BIP39)
        
    }
    
    @IBOutlet weak var bipMnemonic: UILabel!
    @IBOutlet weak var bipKey: UILabel!
    

}
