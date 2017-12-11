//
//  web3Swift.swift
//  web3swift
//
//  Created by Petr Korolev on 11/12/2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation

public class ABIManager {
    public class func getABI(address: String) -> String? {

        return self.getAPIKey()
    }

    static func getAPIKey() -> String? {
        let keys: NSDictionary?
        if let path = Bundle.main.path(forResource: "API_keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
            if let dict = keys {
                return dict["etherscan_api"] as? String
            }
        }
        return nil
    }
}

