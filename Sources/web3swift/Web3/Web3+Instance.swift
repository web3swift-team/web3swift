//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

/// A web3 instance bound to provider. All further functionality is provided under web.*. namespaces.
public class web3 {
    public var provider : Web3Provider
    public var transactionOptions: TransactionOptions = TransactionOptions.defaultOptions
    public var defaultBlock = "latest"
    public var requestDispatcher: JSONRPCrequestDispatcher

    // Add a provider request to the dispatch queue.
    public func dispatch(_ request: JSONRPCrequest) async -> JSONRPCresponse? {
        await withCheckedContinuation { continuation in
            Task {
                try await self.requestDispatcher.addToQueue(request: request) { jsonRPCresponses in
                    continuation.resume(returning: jsonRPCresponses.first)
                }
            }
        }
    }

    /// Raw initializer using a Web3Provider protocol object, dispatch queue and request dispatcher.
    public init(provider prov: Web3Provider, queue: OperationQueue? = nil, requestDispatcher: JSONRPCrequestDispatcher? = nil) {
        provider = prov
        if let requestDispatcher = requestDispatcher {
            self.requestDispatcher = requestDispatcher
        } else {
            self.requestDispatcher = JSONRPCrequestDispatcher(provider: provider, queue: DispatchQueue.global(qos: .userInteractive), policy: .Batch(32))
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
        if let ethInstance = ethInstance {
            return ethInstance
        }
        let ethObject = web3.Eth(provider : provider, web3: self)
        ethInstance = ethObject
        return ethObject
    }

    public class Eth:TransactionOptionsInheritable {
        var provider:Web3Provider
        var web3: web3
        public var transactionOptions: TransactionOptions {
            return self.web3.transactionOptions
        }
        public init(provider prov: Web3Provider, web3 web3instance: web3) {
            provider = prov
            web3 = web3instance
        }
    }

    var personalInstance: web3.Personal?

    /// Public web3.personal.* namespace.
    public var personal: web3.Personal {
        if let personalInstance = personalInstance {
            return personalInstance
        }
        let personalObject = web3.Personal(provider : self.provider, web3: self)
        self.personalInstance = personalObject
        return personalObject
    }

    public class Personal:TransactionOptionsInheritable {
        var provider:Web3Provider
        var web3: web3
        public var transactionOptions: TransactionOptions {
            return self.web3.transactionOptions
        }
        public init(provider prov: Web3Provider, web3 web3instance: web3) {
            provider = prov
            web3 = web3instance
        }
    }

    var txPoolInstance: web3.TxPool?

    /// Public web3.personal.* namespace.
    public var txPool: web3.TxPool {
        if let txPoolInstance = txPoolInstance {
            return txPoolInstance
        }
        let txPoolObject = web3.TxPool(provider : self.provider, web3: self)
        self.txPoolInstance = txPoolObject
        return txPoolObject
    }

    public class TxPool: TransactionOptionsInheritable {
        var provider:Web3Provider
        //        weak var web3: web3?
        var web3: web3
        public var transactionOptions: TransactionOptions {
            return self.web3.transactionOptions
        }
        public init(provider prov: Web3Provider, web3 web3instance: web3) {
            provider = prov
            web3 = web3instance
        }
    }

    var walletInstance: web3.Web3Wallet?

    /// Public web3.wallet.* namespace.
    public var wallet: web3.Web3Wallet {
        if let walletInstance = walletInstance {
            return walletInstance
        }
        let web3WalletObject = web3.Web3Wallet(provider : self.provider, web3: self)
        self.walletInstance = web3WalletObject
        return web3WalletObject
    }

    public class Web3Wallet {
        var provider:Web3Provider
        var web3: web3
        public init(provider prov: Web3Provider, web3 web3instance: web3) {
            provider = prov
            web3 = web3instance
        }
    }

    var browserFunctionsInstance: web3.BrowserFunctions?

    /// Public web3.browserFunctions.* namespace.
    public var browserFunctions: web3.BrowserFunctions {
        if let browserFunctionsInstance = browserFunctionsInstance {
            return browserFunctionsInstance
        }
        let browserfunctions = web3.BrowserFunctions(provider : self.provider, web3: self)
        self.browserFunctionsInstance = browserfunctions
        return browserfunctions
    }

    public class BrowserFunctions:TransactionOptionsInheritable {
        var provider:Web3Provider
        var web3: web3
        public var transactionOptions: TransactionOptions {
            return self.web3.transactionOptions
        }
        public init(provider prov: Web3Provider, web3 web3instance: web3) {
            provider = prov
            web3 = web3instance
        }
    }

    var eventLoopInstance: web3.Eventloop?

    /// Public web3.browserFunctions.* namespace.
    public var eventLoop: web3.Eventloop {
        if let eventLoopInstance = eventLoopInstance {
            return eventLoopInstance
        }
        let evenloop = web3.Eventloop(provider : self.provider, web3: self)
        self.eventLoopInstance = evenloop
        return evenloop
    }

    public class Eventloop: TransactionOptionsInheritable {

        public typealias EventLoopCall = (web3) -> Void
        public typealias EventLoopContractCall = (web3contract) -> Void

        public struct MonitoredProperty {
            public var name: String
            public var queue: DispatchQueue
            public var calledFunction: EventLoopCall
        }

        var provider:Web3Provider
        var web3: web3
        var timer: RepeatingTimer? = nil

        public var monitoredProperties: [MonitoredProperty] = [MonitoredProperty]()
        public var monitoredUserFunctions: [EventLoopRunnableProtocol] = [EventLoopRunnableProtocol]()

        public var transactionOptions: TransactionOptions {
            return self.web3.transactionOptions
        }
        public init(provider prov: Web3Provider, web3 web3instance: web3) {
            provider = prov
            web3 = web3instance
        }
    }

    public typealias AssemblyHookFunction = ((EthereumTransaction, EthereumContract, TransactionOptions)) -> (EthereumTransaction, EthereumContract, TransactionOptions, Bool)

    public typealias SubmissionHookFunction = ((EthereumTransaction, TransactionOptions)) -> (EthereumTransaction, TransactionOptions, Bool)

    public typealias SubmissionResultHookFunction = (TransactionSendingResult) -> ()

    public struct AssemblyHook {
        public var queue: DispatchQueue
        public var function: AssemblyHookFunction
    }

    public struct SubmissionHook {
        public var queue: DispatchQueue
        public var function: SubmissionHookFunction
    }

    public struct SubmissionResultHook {
        public var queue: DispatchQueue
        public var function: SubmissionResultHookFunction
    }

    public var preAssemblyHooks: [AssemblyHook] = [AssemblyHook]()
    public var postAssemblyHooks: [AssemblyHook] = [AssemblyHook]()

    public var preSubmissionHooks: [SubmissionHook] = [SubmissionHook]()
    public var postSubmissionHooks: [SubmissionResultHook] = [SubmissionResultHook]()

}
