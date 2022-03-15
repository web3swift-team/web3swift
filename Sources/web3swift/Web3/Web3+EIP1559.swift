//
//  Web3+EIP1559.swift
//
//
//  Created by Yaroslav on 14.03.2022.
//

import Foundation
import BigInt


/// EIP-1559 Base fee extension
///
/// Source: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1559.md
///
/// Additional info about base fee options: https://ethereum.org/en/developers/docs/gas/#post-london
public extension Web3 {
    func verifyGasLimit(parentGasLimit: BigUInt, currentGasLimit: BigUInt) throws -> Bool {
        var diff = BigInt(parentGasLimit) - BigInt(currentGasLimit)
        
        if diff < 0 { diff *= -1 }

        let limit = parentGasLimit / Web3.GasLimitBoundDivisor

        // TODO: Make error more descriptiove
        // "invalid gas limit: have %d, want %d +-= %d", headerGasLimit, parentGasLimit, limit-1)
        if BigUInt(diff) >= limit { throw Web3Error.unknownError }

        // TODO: Make error more descriptiove
        // return errors.New("invalid gas limit below 5000")
        if currentGasLimit < Web3.MinGasLimit { throw Web3Error.unknownError }

        return true
    }

    /// VerifyEip1559Header verifies some header attributes which were changed in EIP-1559,
    /// - gas limit check
    /// - basefee check
    /// This function make checks that this given block is valid post EIP-1559 block and returns true if it is
    /// and thors an error if it isn't.
    func verifyEip1559Block(chain version: ChainVersion, parent: Block, current: Block) throws -> Bool {
        var parentGasLimit = parent.gasLimit
        if case .London = version {
            parentGasLimit = parent.gasLimit * Web3.ElasticityMultiplier
        }

        _ = try verifyGasLimit(parentGasLimit: parentGasLimit, currentGasLimit: current.gasLimit)

        // ??? In go implementation this field is optional
        // if current.baseFeePerGas == nil { throw Web3Error.unknownError }

        let expectedBaseFeePerGas = self.calcBaseFee(chain: version, parent: parent)

        // TODO: Make all errors trows more descriptive errors
        // ("invalid baseFee: have %s, want %s, parentBaseFee %s, parentGasUsed %d", expectedBaseFee, header.BaseFee, parent.BaseFee, parent.GasUsed)
        guard expectedBaseFeePerGas == current.baseFeePerGas else { throw Web3Error.unknownError }

        return true
    }

    func calcBaseFee(chain version: ChainVersion, parent: Block) -> BigUInt {
        // If the current block is the first EIP-1559 block, return the InitialBaseFee.
        guard version == .London else { return Web3.InitialBaseFee }

        let parentGasTarget = parent.gasLimit / Web3.ElasticityMultiplier

        // If the parent gasUsed is the same as the target, the baseFee remains unchanged.
        if parent.gasUsed == parentGasTarget {
            return parent.baseFeePerGas
            
        } else if parent.gasUsed > parentGasTarget {
            // If the parent block used more gas than its target, the baseFee should increase.
            let gasUsedDelta = parent.gasUsed - parentGasTarget
            let baseFeePerGasDelta = max(parent.baseFeePerGas * gasUsedDelta / parentGasTarget / Web3.BaseFeeChangeDenominator, 1)
            let expectedBaseFeePerGas = parent.baseFeePerGas + baseFeePerGasDelta

            return expectedBaseFeePerGas
        } else {
            // Otherwise if the parent block used less gas than its target, the baseFee should decrease.
            let gasUsedDelta = parentGasTarget - parent.gasUsed
            let baseFeePerGasDelta = parent.baseFeePerGas * gasUsedDelta / parentGasTarget / Web3.BaseFeeChangeDenominator
            let expectedBaseFeePerGas = parent.baseFeePerGas - baseFeePerGasDelta

            return expectedBaseFeePerGas
        }
    }
}

public extension Web3 {
    enum ChainVersion {
            /// Byzantium switch block
        case Byzantium
            /// Constantinople switch block
        case Constantinople
            /// Petersburg switch block
        case Petersburg
            /// Istanbul switch block
        case Istanbul
            /// Eip-2384 (bomb delay) switch block
        case MuirGlacier
            /// Berlin switch block
        case Berlin
            /// London switch block
        case London
            /// Eip-4345 (bomb delay) switch block
        case ArrowGlacier
        case MergeFork
    }
}

