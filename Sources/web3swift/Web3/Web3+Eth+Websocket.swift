//
//  Web3+Eth+Websocket.swift
//  web3swift
//
//  Created by Anton on 03/04/2019.
//  Copyright © 2019 The Matter Inc. All rights reserved.
//
import BigInt
import Foundation
import Starscream

extension Web3.Eth {

    public func getWebsocketProvider(forDelegate delegate: Web3SocketDelegate) throws -> InfuraWebsocketProvider {
        var infuraWSProvider: InfuraWebsocketProvider

        if let prov = provider as? InfuraWebsocketProvider {
            infuraWSProvider = prov
        } else {
            guard let infuraNetwork = provider.network else {
                throw Web3Error.processingError(desc: "Wrong network")
            }
            guard let infuraProvider = InfuraWebsocketProvider(infuraNetwork, delegate: delegate, keystoreManager: provider.attachedKeystoreManager) else {
                throw Web3Error.processingError(desc: "Wrong network")
            }
            infuraWSProvider = infuraProvider
        }

        infuraWSProvider.connectSocket()
        return infuraWSProvider
    }

    public func getLatestPendingTransactions(forDelegate delegate: Web3SocketDelegate) throws {
        let provider = try getWebsocketProvider(forDelegate: delegate)
        try provider.setFilterAndGetChanges(method: .newPendingTransactionFilter)
    }

    public func subscribeOnPendingTransactions(forDelegate delegate: Web3SocketDelegate) throws {
        let provider = try getWebsocketProvider(forDelegate: delegate)
        try provider.subscribeOnNewPendingTransactions()
    }
}
