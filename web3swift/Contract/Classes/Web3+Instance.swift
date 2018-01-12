//
//  Web3+Instance.swift
//  web3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

public class web3 {
    public var provider:Web3Provider
    public var options : Web3Options = Web3Options.defaultOptions()
//    public func send(request: JSONRPCrequest) -> Promise<[String: Any]?> {
//        return self.provider.send(request: request)
//    }
    public func sendSync(request: JSONRPCrequest) -> [String: Any]? {
        return self.provider.sendSync(request: request)
    }

    public init(provider prov: Web3Provider) {
        provider = prov
    }
    public func addKeystoreManager(_ manager: KeystoreManager?) {
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

    var hookedFunctionsInstance: web3.HookedFunctions?
    public var hookedFunctions: web3.HookedFunctions {
        if (self.hookedFunctionsInstance != nil) {
            return self.hookedFunctionsInstance!
        }
        self.hookedFunctionsInstance = web3.HookedFunctions(provider : self.provider, web3: self)
        return self.hookedFunctionsInstance!
    }
    
    public class HookedFunctions {
        var provider:Web3Provider
        weak var web3: web3?
        public init(provider prov: Web3Provider, web3 web3instance: web3) {
            provider = prov
            web3 = web3instance
        }
    }
    
}
