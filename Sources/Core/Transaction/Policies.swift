//
//  File.swift
//  
//
//  Created by Jann Driessen on 01.11.22.
//

import Foundation
import BigInt

public enum GasLimitPolicy {
    case automatic
    case manual(BigUInt)
    case limited(BigUInt)
    case withMargin(Double)
}

public enum GasPricePolicy {
    case automatic
    case manual(BigUInt)
    case withMargin(Double)
}

public enum PriorityFeePerGasPolicy {
    case automatic
    case manual(BigUInt)
}

public enum FeePerGasPolicy {
    case automatic
    case manual(BigUInt)
}
