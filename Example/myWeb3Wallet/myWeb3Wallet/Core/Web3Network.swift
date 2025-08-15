//
//  Web3Network.swift
//  myWeb3Wallet
//
//  Created by 6od9i on 20/01/25.
//

import Foundation
import web3swift
import Web3Core
import BigInt

final class Web3Network {
    let network: Network

    /// web3 - sign, request and etc
    let web3: Web3

    var tokensBalances: [String: BigUInt] = [:]

    init(network: Network, web3: Web3) {
        self.network = network
        self.web3 = web3
    }
}
