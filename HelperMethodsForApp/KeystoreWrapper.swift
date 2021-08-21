//
//  KeystoreWrapper.swift
//  Wethio Wallet
//
//  Created by Ravi Ranjan on 22/08/21.
//  Copyright © 2021 oodlesTechnologies_r.ranjanchn@gmail.com. All rights reserved.
//

import Foundation
import web3swift

class KeystoreWrapper: NSObject {
    /// Get KeyStore manager Instance
    ///
    /// - Parameters: nil
    /// - Returns: Key store manager
    
    static func getKeystoreManager () -> KeystoreManager? {
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = userDir+"/keystore/"
        return KeystoreManager.managerForPath(path, scanForHDwallets: true, suffix: "json")
       
    }
    /// Get Wallet address
    ///
    /// - Parameters:
    /// - Returns: Current wallet address
    static func getWalletAddress () -> String? {
        return getKeystoreManager()?.addresses.first?.address
    }
    
}
