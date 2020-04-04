//
//  ViewController.swift
//  web3swiftBrowser
//
//  Created by Alexander Vlasov on 07.01.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class ViewController: BrowserViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        

        let urlToOpen = "https://1inch.exchange/"
//        let urlToOpen = "https://app.compound.finance"
        webView.load(URLRequest(url: URL(string: urlToOpen)!))
        
        do {
            let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            var keystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
            var ks: EthereumKeystoreV3?
            if (keystoreManager?.addresses?.count == 0) {
                ks = try EthereumKeystoreV3(password: "web3swift")
                let keydata = try JSONEncoder().encode(ks!.keystoreParams)
                FileManager.default.createFile(atPath: userDir + "/keystore"+"/key.json", contents: keydata, attributes: nil)
                keystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
            }
            guard let sender = keystoreManager?.addresses![0] else {return}
            print(sender)
            
            let web3 = Web3.InfuraRinkebyWeb3()
            web3.addKeystoreManager(keystoreManager)
            
            self.registerBridges(for: web3)
        }
        catch{
            print(error)
        }
    }
}
