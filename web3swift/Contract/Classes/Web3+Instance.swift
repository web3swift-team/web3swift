//
//  Web3+Instance.swift
//  web3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit
import BigInt

public class web3 {
    var provider:Web3Provider
    public func send(request: JSONRPCrequest) -> Promise<[String: Any]?> {
        return self.provider.send(request: request)
    }
    public init(provider prov: Web3Provider) {
        provider = prov
    }
    public func addKeystoreManager(_ manager: KeystoreManagerV3?) {
        self.provider.attachedKeystoreManager = manager
    }
    var ethInstance: web3.Eth?
    public var eth: web3.Eth {
        if (self.ethInstance != nil) {
            return self.ethInstance!
        }
        self.ethInstance = web3.Eth(provider : self.provider)
        return self.ethInstance!
    }
    
    public class Eth {
        var provider:Web3Provider
        public init(provider prov: Web3Provider) {
            provider = prov
        }
    }

}
