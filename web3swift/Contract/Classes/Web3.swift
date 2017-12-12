//
//  Web3.swift
//  web3swift
//
//  Created by Alexander Vlasov on 11.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation

import BigInt

struct Web3Options {
    var to: EthereumAddress? = nil
    var from: EthereumAddress? = nil
    var gas: BigUInt? = BigUInt(21000)
    var gasPrice: BigUInt? = BigUInt(5000000000)
    var value: BigUInt? = BigUInt(0)
}

