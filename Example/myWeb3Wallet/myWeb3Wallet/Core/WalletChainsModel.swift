//
//  WalletChainsModel.swift
//  myWeb3Wallet
//
//  Created by 6od9i on 15/01/25.
//

import Foundation

struct WalletChainsModel {
    static let networks: [Network] = [
        Network(chainId: 1, name: "Ethereum",
                networkRPC: "https://ethereum-rpc.publicnode.com",
                explorer: "https://etherscan.io/", tokens: [
                    Token(isNative: true,
                          symbol: "ETH",
                          address: "0x0",
                          decimals: 18),
                    Token(symbol: "USDT",
                          address: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
                          decimals: 6),
                    Token(symbol: "USDC",
                          address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
                          decimals: 6),
                    Token(symbol: "BTC",
                          address: "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",
                          decimals: 8)
                ]),
        Network(chainId: 56, name: "Binance Smart Chain",
                networkRPC: "https://bsc-dataseed.binance.org/",
                explorer: "https://bscscan.com/", tokens: [
                    Token(isNative: true,
                          symbol: "BNB",
                          address: "0x0",
                          decimals: 18),
                    Token(symbol: "USDT",
                          address: "0x55d398326f99059fF775485246999027B3197955",
                          decimals: 18),
                    Token(symbol: "USDC",
                          address: "0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d",
                          decimals: 18),
                    Token(symbol: "BTC",
                          address: "0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c",
                          decimals: 18)
                ]),
        Network(chainId: 137, name: "Polygon",
                networkRPC: "https://polygon.llamarpc.com",
                explorer: "https://polygonscan.com/", tokens: [
                    Token(isNative: true,
                          symbol: "POL",
                          address: "0x0",
                          decimals: 18),
                    Token(symbol: "USDT",
                          address: "0xc2132D05D31c914a87C6611C10748AEb04B58e8F",
                          decimals: 6),
                    Token(symbol: "USDC",
                          address: "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359",
                          decimals: 6),
                    Token(symbol: "WBTC",
                          address: "0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6",
                          decimals: 8)
                ])
    ]
}
