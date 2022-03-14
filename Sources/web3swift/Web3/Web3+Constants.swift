//
//  Web3+Constants.swift
//  web3swift
//
//  Created by Anton on 24/06/2019.
//  Copyright © 2019 Matter Labs. All rights reserved.
//

import Foundation
import BigInt

struct Constants {
    static let infuraHttpScheme = ".infura.io/v3/"
    static let infuraWsScheme = ".infura.io/ws/v3/"
    static let infuraToken = "4406c3acf862426c83991f1752c46dd8"
}

extension Web3 {
    static let BaseFeeChangeDenominator: BigUInt = 8           // Bounds the amount the base fee can change between blocks.
    static let ElasticityMultiplier: BigUInt     = 2           // Bounds the maximum gas limit an EIP-1559 block may have.
    static let InitialBaseFee: BigUInt           = 1000000000  // Initial base fee for EIP-1559 blocks.
}