//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

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
        let ethInstance = ethInstance ?? Web3.Eth(provider: provider)
        self.ethInstance = ethInstance
        return ethInstance
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
        let personalInstance = personalInstance ?? Web3.Personal(provider: provider, web3: self)
        self.personalInstance = personalInstance
        return personalInstance
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
        let txPoolInstance = txPoolInstance ?? Web3.TxPool(provider: provider, web3: self)
        self.txPoolInstance = txPoolInstance
        return txPoolInstance
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
        let walletInstance = walletInstance ?? Web3.Web3Wallet(provider: provider, web3: self)
        self.walletInstance = walletInstance
        return walletInstance
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
        let browserFunctionsInstance = browserFunctionsInstance ?? Web3.BrowserFunctions(provider: provider, web3: self)
        self.browserFunctionsInstance = browserFunctionsInstance
        return browserFunctionsInstance
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
        let eventLoopInstance = eventLoopInstance ?? Web3.Eventloop(provider: provider, web3: self)
        self.eventLoopInstance = eventLoopInstance
        return eventLoopInstance
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
        public var monitoredUserFunctions: [EventLoopRunnableProtocol] = [EventLoopRunnableProtocol]()
        public init(provider prov: Web3Provider, web3 web3instance: Web3) {
            provider = prov
            web3 = web3instance
        }
    }

    public typealias SubmissionResultHookFunction = (TransactionSendingResult) -> Void

    public struct SubmissionResultHook {
        public var function: SubmissionResultHookFunction
    }

    public var postSubmissionHooks: [SubmissionResultHook] = [SubmissionResultHook]()

}
