//
//  Web3+Instance.swift
//  web3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit


/// A web3 instance bound to provider. All further functionality is provided under web.*. namespaces.
public class web3: Web3OptionsInheritable {
    public var provider : Web3Provider
    public var options : Web3Options = Web3Options.defaultOptions()
    public var defaultBlock = "latest"
    public var requestDispatcher: JSONRPCrequestDispatcher
    
    /// Add a provider request to the dispatch queue.
    public func dispatch(_ request: JSONRPCrequest) -> Promise<JSONRPCresponse> {
        return self.requestDispatcher.addToQueue(request: request)
    }

    /// Raw initializer using a Web3Provider protocol object, dispatch queue and request dispatcher.
    public init(provider prov: Web3Provider, queue: OperationQueue? = nil, requestDispatcher: JSONRPCrequestDispatcher? = nil) {
        provider = prov        
        if requestDispatcher == nil {
            self.requestDispatcher = JSONRPCrequestDispatcher(provider: provider, queue: DispatchQueue.global(qos: .userInteractive), policy: .Batch(32))
        } else {
            self.requestDispatcher = requestDispatcher!
        }
    }
    
    /// Keystore manager can be bound to Web3 instance. If some manager is bound all further account related functions, such
    /// as account listing, transaction signing, etc. are done locally using private keys and accounts found in a manager.
    public func addKeystoreManager(_ manager: KeystoreManager?) {
        self.provider.attachedKeystoreManager = manager
    }
    
    var ethInstance: web3.Eth?
    
    /// Public web3.eth.* namespace.
    public var eth: web3.Eth {
        if (self.ethInstance != nil) {
            return self.ethInstance!
        }
        self.ethInstance = web3.Eth(provider : self.provider, web3: self)
        return self.ethInstance!
    }
    
    public class Eth:Web3OptionsInheritable {
        var provider:Web3Provider
//        weak var web3: web3?
        var web3: web3
        public var options: Web3Options {
            return self.web3.options
        }
        public init(provider prov: Web3Provider, web3 web3instance: web3) {
            provider = prov
            web3 = web3instance
        }
    }
    
    var personalInstance: web3.Personal?
    
    /// Public web3.personal.* namespace.
    public var personal: web3.Personal {
        if (self.personalInstance != nil) {
            return self.personalInstance!
        }
        self.personalInstance = web3.Personal(provider : self.provider, web3: self)
        return self.personalInstance!
    }
    
    public class Personal:Web3OptionsInheritable {
        var provider:Web3Provider
        //        weak var web3: web3?
        var web3: web3
        public var options: Web3Options {
            return self.web3.options
        }
        public init(provider prov: Web3Provider, web3 web3instance: web3) {
            provider = prov
            web3 = web3instance
        }
    }

    var walletInstance: web3.Web3Wallet?
    
    /// Public web3.wallet.* namespace.
    public var wallet: web3.Web3Wallet {
        if (self.walletInstance != nil) {
            return self.walletInstance!
        }
        self.walletInstance = web3.Web3Wallet(provider : self.provider, web3: self)
        return self.walletInstance!
    }
    
    public class Web3Wallet {
        var provider:Web3Provider
//        weak var web3: web3?
        var web3: web3
        public init(provider prov: Web3Provider, web3 web3instance: web3) {
            provider = prov
            web3 = web3instance
        }
    }
    
    var browserFunctionsInstance: web3.BrowserFunctions?
    
    /// Public web3.browserFunctions.* namespace.
    public var browserFunctions: web3.BrowserFunctions {
        if (self.browserFunctionsInstance != nil) {
            return self.browserFunctionsInstance!
        }
        self.browserFunctionsInstance = web3.BrowserFunctions(provider : self.provider, web3: self)
        return self.browserFunctionsInstance!
    }
    
    public class BrowserFunctions:Web3OptionsInheritable {
        var provider:Web3Provider
        //        weak var web3: web3?
        var web3: web3
        public var options: Web3Options {
            return self.web3.options
        }
        public init(provider prov: Web3Provider, web3 web3instance: web3) {
            provider = prov
            web3 = web3instance
        }
    }
    
}
