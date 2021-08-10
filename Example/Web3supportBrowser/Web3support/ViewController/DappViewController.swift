//
//  DappViewController.swift
//  Web3support
//
//  Created by Ravi Ranjan on 09/08/21.
//

import UIKit
import WebKit
import web3swift
class DappViewController: BrowserViewController {
    
    @IBOutlet weak var dappWebKitScreen: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        var urlToOpen = "https://1inch.exchange/"
        urlToOpen = "https://app.compound.finance"
//        urlToOpen = "https://app.uniswap.org"
//        urlToOpen = "https://exchange.pancakeswap.finance/#/swap"

        
        
        dappWebKitScreen.load(URLRequest(url: URL(string: urlToOpen)!))
        
        let web3 = Web3.InfuraMainnetWeb3()
        web3.addKeystoreManager(FilestoreWrapper.getKeystoreManager())
        
        self.registerBridges(for: web3)
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
}
class FilestoreWrapper: NSObject {
    /// Get KeyStore manager Instance
    ///
    /// - Parameters: nil
    /// - Returns: Key store manager
    static func getKeystoreManager () -> KeystoreManager? {
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = userDir+"/keystore/"
        let userLoginType = UserDefaults.standard.value(forKey: "KeyConstants.UserDefaults.kUserLoginType") as? String ?? "create"
        if userLoginType == "create" {
            return KeystoreManager.managerForPath(path, scanForHDwallets: true, suffix: "json")
        } else {
            return KeystoreManager.managerForPath(path)
        }
    }
    /// Get Wallet address
    ///
    /// - Parameters:
    /// - Returns: Current wallet address
    static func getWalletAddress () -> String? {
        return getKeystoreManager()?.addresses?.first?.address
    }
    
}
