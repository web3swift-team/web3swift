//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import BigInt
import Foundation

/// A web3 instance bound to provider. All further functionality is provided under web.*. namespaces.
public class Web3 {
    public var provider: Web3Provider
    public var transactionOptions: TransactionOptions = .defaultOptions
    public var defaultBlock = "latest"

    /// Add a provider request to the dispatch queue.
    public func dispatch(_ request: JSONRPCrequest) async throws -> JSONRPCresponse {
        try await provider.sendAsync(request)
    }

    /// Raw initializer using a Web3Provider protocol object, dispatch queue and request dispatcher.
    public init(provider prov: Web3Provider) {
        provider = prov
    }

    /// Keystore manager can be bound to Web3 instance. If some manager is bound all further account related functions, such
    /// as account listing, transaction signing, etc. are done locally using private keys and accounts found in a manager.
    public func addKeystoreManager(_ manager: KeystoreManager?) {
        self.provider.attachedKeystoreManager = manager
    }

    var ethInstance: Web3.Eth?

    /// Public web3.eth.* namespace.
    public var eth: Web3.Eth {
        if self.ethInstance != nil {
            return self.ethInstance!
        }
        self.ethInstance = Web3.Eth(provider: self.provider, web3: self)
        return self.ethInstance!
    }

    public class Eth: TransactionOptionsInheritable {
        var provider: Web3Provider
        //  weak var web3: web3?
        var web3: Web3
        public var transactionOptions: TransactionOptions {
            self.web3.transactionOptions
        }

        public init(provider prov: Web3Provider, web3 web3instance: Web3) {
            provider = prov
            web3 = web3instance
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

    public class Personal: TransactionOptionsInheritable {
        var provider: Web3Provider
        //        weak var web3: web3?
        var web3: Web3
        public var transactionOptions: TransactionOptions {
            self.web3.transactionOptions
        }

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

    public class TxPool: TransactionOptionsInheritable {
        var provider: Web3Provider
        //        weak var web3: web3?
        var web3: Web3
        public var transactionOptions: TransactionOptions {
            self.web3.transactionOptions
        }

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
        //  weak var web3: web3?
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

    public class BrowserFunctions: TransactionOptionsInheritable {
        var provider: Web3Provider
        //        weak var web3: web3?
        var web3: Web3
        public var transactionOptions: TransactionOptions {
            self.web3.transactionOptions
        }

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

    // swiftlint:disable nesting
    public class Eventloop: TransactionOptionsInheritable {

        public typealias EventLoopCall = (Web3) async -> Void
        public typealias EventLoopContractCall = (Web3contract) -> Void

        public struct MonitoredProperty {
            public var name: String
            public var calledFunction: EventLoopCall
        }

        //  public struct MonitoredContract {
        //      public var name: String
        //      public var queue: DispatchQueue
        //      public var calledFunction: EventLoopContractCall
        //  }

        var provider: Web3Provider
        //        weak var web3: web3?
        var web3: Web3
        var timer: RepeatingTimer?

        public var monitoredProperties: [MonitoredProperty] = [MonitoredProperty]()
        //  public var monitoredContracts: [MonitoredContract] = [MonitoredContract]()
        public var monitoredUserFunctions: [EventLoopRunnableProtocol] = [EventLoopRunnableProtocol]()

        public var transactionOptions: TransactionOptions {
            self.web3.transactionOptions
        }

        public init(provider prov: Web3Provider, web3 web3instance: Web3) {
            provider = prov
            web3 = web3instance
        }
    }

    public typealias AssemblyHookFunction = ((EthereumTransaction, EthereumContract, TransactionOptions)) -> (EthereumTransaction, EthereumContract, TransactionOptions, Bool)

    public typealias SubmissionHookFunction = ((EthereumTransaction, TransactionOptions)) -> (EthereumTransaction, TransactionOptions, Bool)

    public typealias SubmissionResultHookFunction = (TransactionSendingResult) -> Void

    public struct AssemblyHook {
        public var function: AssemblyHookFunction
    }

    public struct SubmissionHook {
        public var function: SubmissionHookFunction
    }

    public struct SubmissionResultHook {
        public var function: SubmissionResultHookFunction
    }

    public var preAssemblyHooks: [AssemblyHook] = [AssemblyHook]()
    public var postAssemblyHooks: [AssemblyHook] = [AssemblyHook]()

    public var preSubmissionHooks: [SubmissionHook] = [SubmissionHook]()
    public var postSubmissionHooks: [SubmissionResultHook] = [SubmissionResultHook]()

}
