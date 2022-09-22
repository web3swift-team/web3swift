//
//  Web3+Constants.swift
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
    static let GasLimitBoundDivisor: BigUInt = 1024               // The bound divisor of the gas limit, used in update calculations.
    static let MinGasLimit: BigUInt          = 5000               // Minimum the gas limit may ever be.
    static let MaxGasLimit: BigUInt          = 0x7fffffffffffffff // Maximum the gas limit (2^63-1).
    static let GenesisGasLimit: BigUInt      = 4712388            // Gas limit of the Genesis block.

    static let BaseFeeChangeDenominator: BigUInt = 8           // Bounds the amount the base fee can change between blocks.
    static let ElasticityMultiplier: BigUInt     = 2           // Bounds the maximum gas limit an EIP-1559 block may have.
    static let InitialBaseFee: BigUInt           = 1000000000  // Initial base fee for EIP-1559 blocks.
}
