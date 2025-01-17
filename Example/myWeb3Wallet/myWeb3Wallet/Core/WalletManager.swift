//
//  WalletManager.swift
//  myWeb3Wallet
//
//  Created by 6od9i on 15/01/25.
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


final class WalletManager {
    static let keystorePassword = "password"
    
    /// Container with private keys
    private let keystoreManager: KeystoreManager
    
    private(set) var networks: [Web3Network]  = []
    
    let address: EthereumAddress
    
    init(keystoreManager: KeystoreManager) async {
        self.keystoreManager = keystoreManager
        self.address = keystoreManager.addresses!.first!
        
        for model in WalletChainsModel.networks {
            let network = Networks.Custom(networkID: BigUInt(model.chainId))
            guard let providerURL = URL(string: model.networkRPC),
                  let provider = try? await Web3HttpProvider(url: providerURL, network: network,
                                                             keystoreManager: keystoreManager)
            else { continue }
            
            let web3 = web3swift.Web3(provider: provider)
            networks.append(Web3Network(network: model, web3: web3))
        }
    }
    
    func loadBalances() async {
        for network in networks {
            if let nativeBalance = try? await network.web3.eth.getBalance(for: address),
               let nativeSymbol = network.network.tokens.first(where: { $0.isNative })?.symbol {
                network.tokensBalances[nativeSymbol] = nativeBalance
            }
            for token in network.network.tokens {
                guard token.isNative == false,
                      let contract = network.web3.contract(Web3.Utils.erc20ABI, at: EthereumAddress(token.address)),
                      let operation = contract.createReadOperation("balanceOf", parameters: [address]),
                      let result = try? await operation.callContractMethod(),
                      let balance = result["balance"] as? BigUInt
                else { continue }
                network.tokensBalances[token.symbol] = balance
            }
        }
    }
}
