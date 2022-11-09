//
//  Policies.swift
//  
//
//  Created by Jann Driessen on 01.11.22.
//

import Foundation
import BigInt

public typealias NoncePolicy = BlockNumber

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

public enum FeePerGasPolicy {
    case automatic
    case manual(BigUInt)
}

public enum PriorityFeePerGasPolicy {
    case automatic
    case manual(BigUInt)
}

public struct Policies {
    public let noncePolicy: NoncePolicy
    public let gasLimitPolicy: GasLimitPolicy
    public let gasPricePolicy: GasPricePolicy
    public let maxFeePerGasPolicy: FeePerGasPolicy
    public let maxPriorityFeePerGasPolicy: PriorityFeePerGasPolicy

    public init(
        noncePolicy: NoncePolicy = .latest,
        gasLimitPolicy: GasLimitPolicy = .automatic,
        gasPricePolicy: GasPricePolicy = .automatic,
        maxFeePerGasPolicy: FeePerGasPolicy = .automatic,
        maxPriorityFeePerGasPolicy: PriorityFeePerGasPolicy = .automatic) {
            self.noncePolicy = noncePolicy
            self.gasLimitPolicy = gasLimitPolicy
            self.gasPricePolicy = gasPricePolicy
            self.maxFeePerGasPolicy = maxFeePerGasPolicy
            self.maxPriorityFeePerGasPolicy = maxPriorityFeePerGasPolicy
        }

    public private(set) static var auto = Policies()
}
