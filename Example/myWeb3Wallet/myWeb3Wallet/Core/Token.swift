//
//  Token.swift
//  myWeb3Wallet
//
//  Created by 6od9i on 15/01/25.
//

import Foundation

struct Token {
    var isNative: Bool = false
    /// Token symbol, for example - "ETH"/"USDT"
    let symbol: String
    /// Token contract address
    let address: String
    /// Decimals number
    let decimals: Int
}
