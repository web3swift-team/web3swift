//
//  Network.swift
//  myWeb3Wallet
//
//  Created by 6od9i on 15/01/25.
//

import Foundation

struct Network {
    /// Id of chain
    let chainId: Int
    /// Name of the network
    let name: String
    /// Some rpc api paths - for network provider
    let networkRPC: String
    /// Path to network explorer like https://bscscan.com/
    let explorer: String?

    /// list of tokens added in this network
    var tokens: [Token]
}
