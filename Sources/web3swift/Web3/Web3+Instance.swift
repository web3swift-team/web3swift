//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core

// FIXME: Rewrite this to CodableTransaction
/// A web3 instance bound to provider. All further functionality is provided under web.*. namespaces.
public class Web3 {
    public var provider: Web3Provider

    /// Raw initializer using a Web3Provider protocol object, dispatch queue and request dispatcher.
    public init(provider prov: Web3Provider) {
        provider = prov
    }

    /// Keystore manager can be bound to Web3 instance. If some manager is bound all further account related functions, such
    /// as account listing, transaction signing, etc. are done locally using private keys and accounts found in a manager.
    public func addKeystoreManager(_ manager: KeystoreManager?) {
        provider.attachedKeystoreManager = manager
    }

    var ethInstance: IEth?

    /// Public web3.eth.* namespace.
    public var eth: IEth {
        if ethInstance != nil {
            return ethInstance!
        }
        ethInstance = Web3.Eth(provider: provider)
        return ethInstance!
    }

    // FIXME: Rewrite this to CodableTransaction
    public class Eth: IEth {
        public var provider: Web3Provider

        public init(provider prov: Web3Provider) {
            provider = prov
        }
    }

    var personalInstance: Web3.Personal?

    /// Public web3.personal.* namespace.
    public var personal: Web3.Personal {
        if self.personalInstance != nil {
            return self.personalInstance!
        }
        self.personalInstance = Web3.Personal(provider: self.provider, web3: self)
        return self.personalInstance!
    }

    // FIXME: Rewrite this to CodableTransaction
    public class Personal {
        var provider: Web3Provider
        // FIXME: remove dependency on web3 instance!!
        var web3: Web3
        public init(provider prov: Web3Provider, web3 web3instance: Web3) {
            provider = prov
            web3 = web3instance
        }
    }

    var txPoolInstance: Web3.TxPool?

    /// Public web3.personal.* namespace.
    public var txPool: Web3.TxPool {
        if self.txPoolInstance != nil {
            return self.txPoolInstance!
        }
        self.txPoolInstance = Web3.TxPool(provider: self.provider, web3: self)
        return self.txPoolInstance!
    }

    // FIXME: Rewrite this to CodableTransaction
    public class TxPool {
        var provider: Web3Provider
        // FIXME: remove dependency on web3 instance!!
        var web3: Web3
        public init(provider prov: Web3Provider, web3 web3instance: Web3) {
            provider = prov
            web3 = web3instance
        }
    }

    var walletInstance: Web3.Web3Wallet?

    /// Public web3.wallet.* namespace.
    public var wallet: Web3.Web3Wallet {
        if self.walletInstance != nil {
            return self.walletInstance!
        }
        self.walletInstance = Web3.Web3Wallet(provider: self.provider, web3: self)
        return self.walletInstance!
    }

    public class Web3Wallet {
        var provider: Web3Provider
        // FIXME: remove dependency on web3 instance!!
        var web3: Web3
        public init(provider prov: Web3Provider, web3 web3instance: Web3) {
            provider = prov
            web3 = web3instance
        }
    }

    var browserFunctionsInstance: Web3.BrowserFunctions?

    /// Public web3.browserFunctions.* namespace.
    public var browserFunctions: Web3.BrowserFunctions {
        if self.browserFunctionsInstance != nil {
            return self.browserFunctionsInstance!
        }
        self.browserFunctionsInstance = Web3.BrowserFunctions(provider: self.provider, web3: self)
        return self.browserFunctionsInstance!
    }

    // FIXME: Rewrite this to CodableTransaction
    public class BrowserFunctions {
        var provider: Web3Provider
        // FIXME: remove dependency on web3 instance!!
        public var web3: Web3
        public init(provider prov: Web3Provider, web3 web3instance: Web3) {
            provider = prov
            web3 = web3instance
        }
    }

    var eventLoopInstance: Web3.Eventloop?

    /// Public web3.browserFunctions.* namespace.
    public var eventLoop: Web3.Eventloop {
        if self.eventLoopInstance != nil {
            return self.eventLoopInstance!
        }
        self.eventLoopInstance = Web3.Eventloop(provider: self.provider, web3: self)
        return self.eventLoopInstance!
    }

    // FIXME: Rewrite this to CodableTransaction
    public class Eventloop {

        public typealias EventLoopCall = (Web3) async -> Void
        public typealias EventLoopContractCall = (Contract) -> Void

        public struct MonitoredProperty {
            public var name: String
            public var calledFunction: EventLoopCall
        }

        var provider: Web3Provider
        // FIXME: remove dependency on web3 instance!!
        var web3: Web3
        var timer: RepeatingTimer?

        public var monitoredProperties: [MonitoredProperty] = [MonitoredProperty]()
        //  public var monitoredContracts: [MonitoredContract] = [MonitoredContract]()
        public var monitoredUserFunctions: [EventLoopRunnableProtocol] = [EventLoopRunnableProtocol]()
        public init(provider prov: Web3Provider, web3 web3instance: Web3) {
            provider = prov
            web3 = web3instance
        }
    }

//    public typealias AssemblyHookFunction = ((inout CodableTransaction, EthereumContract)) -> Bool
//
//    public typealias SubmissionHookFunction = (inout CodableTransaction) -> Bool

    public typealias SubmissionResultHookFunction = (TransactionSendingResult) -> Void

//    public struct AssemblyHook {
//        public var function: AssemblyHookFunction
//    }

//    public struct SubmissionHook {
//        public var function: SubmissionHookFunction
//    }

    public struct SubmissionResultHook {
        public var function: SubmissionResultHookFunction
    }

//    public var preAssemblyHooks: [AssemblyHook] = [AssemblyHook]()
//    public var postAssemblyHooks: [AssemblyHook] = [AssemblyHook]()
//
//    public var preSubmissionHooks: [SubmissionHook] = [SubmissionHook]()
    public var postSubmissionHooks: [SubmissionResultHook] = [SubmissionResultHook]()

}
