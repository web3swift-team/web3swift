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
    // MARK: - Type definitions

    // FIXME: Rewrite this to CodableTransaction
    public class Eth: IEth {
        public var provider: Web3Provider
        public init(provider prov: Web3Provider) {
            provider = prov
        }
    }

    // FIXME: Rewrite this to CodableTransaction
    public class Personal {
        var provider: Web3Provider
        public lazy var eth: IEth = {
            Web3.Eth(provider: provider)
        }()
        public init(provider prov: Web3Provider) {
            provider = prov
        }
    }

    // FIXME: Rewrite this to CodableTransaction
    public class TxPool {
        var provider: Web3Provider
        public lazy var eth: IEth = {
            Web3.Eth(provider: provider)
        }()
        public init(provider prov: Web3Provider) {
            provider = prov
        }
    }

    public class Web3Wallet {
        var provider: Web3Provider
        public lazy var eth: IEth = {
            Web3.Eth(provider: provider)
        }()
        public init(provider prov: Web3Provider) {
            provider = prov
        }
    }

    // FIXME: Rewrite this to CodableTransaction
    public class BrowserFunctions {
        var provider: Web3Provider
        public lazy var eth: IEth = {
            Web3.Eth(provider: provider)
        }()
        public init(provider prov: Web3Provider) {
            provider = prov
        }
    }

    // FIXME: Rewrite this to CodableTransaction
    public class Eventloop {

        public typealias EventLoopCall = (IEth) async -> Void
        public typealias EventLoopContractCall = (Contract) -> Void

        public struct MonitoredProperty {
            public var name: String
            public var calledFunction: EventLoopCall
        }

        var provider: Web3Provider
        var timer: RepeatingTimer?

        public var monitoredProperties: [MonitoredProperty] = [MonitoredProperty]()
        //  public var monitoredContracts: [MonitoredContract] = [MonitoredContract]()
        public var monitoredUserFunctions: [EventLoopRunnableProtocol] = [EventLoopRunnableProtocol]()


        public lazy var eth: IEth = {
            Web3.Eth(provider: provider)
        }()

        public init(provider prov: Web3Provider) {
            provider = prov
        }
    }

    // MARK: - Variables

    public var provider: Web3Provider

    var ethInstance: IEth?

    /// Public web3.eth.* namespace.
    public var eth: IEth {
        if ethInstance != nil {
            return ethInstance!
        }
        ethInstance = Web3.Eth(provider: provider)
        return ethInstance!
    }

    var personalInstance: Web3.Personal?

    /// Public web3.personal.* namespace.
    public var personal: Web3.Personal {
        if let personalInstance = personalInstance {
            return personalInstance
        }
        personalInstance = Web3.Personal(provider: provider)
        return personalInstance!
    }

    var txPoolInstance: Web3.TxPool?

    /// Public web3.personal.* namespace.
    public var txPool: Web3.TxPool {
        if let txPoolInstance = txPoolInstance {
            return txPoolInstance
        }
        txPoolInstance = Web3.TxPool(provider: provider)
        return txPoolInstance!
    }

    var walletInstance: Web3.Web3Wallet?

    /// Public web3.wallet.* namespace.
    public var wallet: Web3.Web3Wallet {
        if let walletInstance = walletInstance{
            return walletInstance
        }
        walletInstance = Web3.Web3Wallet(provider: provider)
        return walletInstance!
    }

    var browserFunctionsInstance: Web3.BrowserFunctions?

    /// Public web3.browserFunctions.* namespace.
    public var browserFunctions: Web3.BrowserFunctions {
        if let browserFunctionsInstance = browserFunctionsInstance {
            return browserFunctionsInstance
        }
        browserFunctionsInstance = Web3.BrowserFunctions(provider: provider)
        return browserFunctionsInstance!
    }

    var eventLoopInstance: Web3.Eventloop?

    /// Public web3.browserFunctions.* namespace.
    public var eventLoop: Web3.Eventloop {
        if let eventLoopInstance = eventLoopInstance {
            return eventLoopInstance
        }
        eventLoopInstance = Web3.Eventloop(provider: provider)
        return eventLoopInstance!
    }


    /// Raw initializer using a Web3Provider protocol object, dispatch queue and request dispatcher.
    public init(provider prov: Web3Provider) {
        provider = prov
    }

    /// Keystore manager can be bound to Web3 instance. If some manager is bound all further account related functions, such
    /// as account listing, transaction signing, etc. are done locally using private keys and accounts found in a manager.
    public func setKeystoreManager(_ manager: KeystoreManager?) {
        provider.keystoreManager = manager
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
