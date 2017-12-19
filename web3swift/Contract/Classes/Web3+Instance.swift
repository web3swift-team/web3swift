//
//  Web3+Instance.swift
//  web3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit

public struct web3 {
    var provider:Web3Provider
    public func send(transaction: EthereumTransaction, network: Networks = .Mainnet) -> Promise<Data?> {
        return provider.send(transaction: transaction, network: network)
    }
    public func call(transaction: EthereumTransaction, options: Web3Options?, network: Networks = .Mainnet) -> Promise<Data?> {
        return provider.call(transaction: transaction, options: options, network: network)
    }
    public func estimateGas(transaction: EthereumTransaction, options: Web3Options?, network: Networks = .Mainnet) -> Promise<Data?> {
        return provider.estimateGas(transaction: transaction, options: options, network: network)
    }
}
