//
//  RIPEMD160_SO.swift
//
//  Created by Alexander Vlasov on 10.01.2018.
//

import Foundation
import struct BigInt.BigUInt

public extension BigUInt {
    init?(_ naturalUnits: String, _ ethereumUnits: Utilities.Units) {
        guard let value = Utilities.parseToBigUInt(naturalUnits, units: ethereumUnits) else {return nil}
        self = value
    }
}

#if COCOAPODS
extension BigUInt {
    var isZero: Bool {
        switch kind {
        case .inline(0, 0): return true
        case .array: return storage.isEmpty
        default:
            return false
        }
    }
}
#endif
