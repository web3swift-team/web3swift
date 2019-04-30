//
//  RIPEMD160_SO.swift
//  web3swift
//
//  Created by Alexander Vlasov on 10.01.2018.
//

import Foundation
import struct BigInt.BigUInt

public extension BigUInt {
    init?(_ naturalUnits: String, _ ethereumUnits: Web3.Utils.Units) {
        guard let value = Web3.Utils.parseToBigUInt(naturalUnits, units: ethereumUnits) else {return nil}
        self = value
    }
}
