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
    func verifyGasLimit(parentGasLimit: BigUInt, currentGasLimit: BigUInt) -> Bool {
        var diff = BigInt(parentGasLimit) - BigInt(currentGasLimit)

        // make diff positive number
        diff = diff < 0 ? diff * -1 : diff

        let limit = parentGasLimit / Web3.GasLimitBoundDivisor

        // Check that gas limit below upper bound
        if BigUInt(diff) >= limit { return false }

        // Check that gas limit above lower bound
        if currentGasLimit < Web3.MinGasLimit { return false }

        return true
    }

    /// Method to check is given block valid EIP-1559 block
    ///
    /// Verifies some header attributes which were changed in EIP-1559
    ///
    /// - gas limit check
    /// - basefee check
    ///
    /// - Parameters:
    ///   - parent: Previous Block
    ///   - current: Current block
    /// - Returns: True or false if block is EIP-1559 or not
    func isEip1559Block(parent: Block, current: Block) -> Bool {
        let parentGasLimit = parent.chainVersion >= .London ? parent.gasLimit : parent.gasLimit * Web3.ElasticityMultiplier

        guard verifyGasLimit(parentGasLimit: parentGasLimit, currentGasLimit: current.gasLimit) else { return false }

        guard calcBaseFee(parent) == current.baseFeePerGas else { return false }

        return true
    }

    /// Calculates base fee amount
    ///
    /// You should pass **parent** block to that method to calculate **expected** baseFee for currently
    /// processing by blockchain `Block`
    ///
    /// Calculation for current `Block` based on parents block object only
    ///
    /// If passed block isn't `ChainVersion.London` one will return
    ///
    /// - Parameter parent: Parent `Block`
    /// - Returns: Amount of expected base fee for current `Block`
    func calcBaseFee(_ parent: Block) -> BigUInt {
        // If given blocks ChainVersion is lower than London — always returns InitialBaseFee
        guard parent.chainVersion >= .London else { return Web3.InitialBaseFee }

        let parentGasTarget = parent.gasLimit / Web3.ElasticityMultiplier

        if parent.gasUsed > parentGasTarget {
            // If the parent block used more gas than its target, the baseFee should increase.
            let gasUsedDelta = parent.gasUsed - parentGasTarget
            let baseFeePerGasDelta = max(parent.baseFeePerGas * gasUsedDelta / parentGasTarget / Web3.BaseFeeChangeDenominator, 1)
            let expectedBaseFeePerGas = parent.baseFeePerGas + baseFeePerGasDelta

            return expectedBaseFeePerGas
        } else if parent.gasUsed < parentGasTarget  {
            // Otherwise if the parent block used less gas than its target, the baseFee should decrease.
            let gasUsedDelta = parentGasTarget - parent.gasUsed
            let baseFeePerGasDelta = parent.baseFeePerGas * gasUsedDelta / parentGasTarget / Web3.BaseFeeChangeDenominator
            let expectedBaseFeePerGas = parent.baseFeePerGas - baseFeePerGasDelta

            return expectedBaseFeePerGas
        } else {
            // If the parent gasUsed is the same as the target, the baseFee remains unchanged.
            return parent.baseFeePerGas
        }
    }
}

public extension Web3 {
    enum ChainVersion: BigUInt {
        /// Byzantium switch block
        ///
        /// Date: 16.10.2017
        ///
        /// Block number: 4_370_000
        case Byzantium
        /// Constantinople switch block
        ///
        /// Date: 27.11.2019
        ///
        /// Block number: 7_280_000
        case Constantinople
        /// Petersburg switch block
        ///
        /// Date: 27.11.2019
        ///
        /// Block number: 7_280_000
        case Petersburg
        /// Istanbul switch block
        ///
        /// Date: 07.12.2019
        ///
        /// Block number: 9_069_000
        case Istanbul
        /// Eip-2384 (bomb delay) switch block
        ///
        /// Date: 01.01.2020
        ///
        /// Block number: 9_200_000
        case MuirGlacier
        /// Berlin switch block
        ///
        /// Date: 15.04.2021
        ///
        /// Block number: 12_244_000
        case Berlin
        /// London switch block
        ///
        /// Date: 05.08.2021
        ///
        /// Block number: 12_965_000
        case London
        /// Eip-4345 (bomb delay) switch block
        ///
        /// Date: 09.12.2021
        ///
        /// Block number: 13_773_000
        case ArrowGlacier

        var mainNetFisrtBlockNumber: BigUInt {
            switch self {
                case .Byzantium: return 4_370_000
                case .Constantinople: return 7_280_000
                case .Petersburg: return 7_280_000
                case .Istanbul: return 9_069_000
                case .MuirGlacier: return 9_200_000
                case .Berlin: return 12_244_000
                case .London: return 12_965_000
                case .ArrowGlacier: return 13_773_000
            }
        }
    }

    static func getChainVersion(of block: BigUInt) -> ChainVersion {
        // Iterate given block number over each ChainVersion block numbers
        // to get the block's ChainVersion.
        if block < ChainVersion.Constantinople.mainNetFisrtBlockNumber {
            return .Byzantium
        // ~= means included in a given range
        } else if ChainVersion.Constantinople.mainNetFisrtBlockNumber..<ChainVersion.Istanbul.mainNetFisrtBlockNumber ~= block {
            return .Constantinople
        } else if ChainVersion.Istanbul.mainNetFisrtBlockNumber..<ChainVersion.MuirGlacier.mainNetFisrtBlockNumber ~= block {
            return .Istanbul
        } else if ChainVersion.MuirGlacier.mainNetFisrtBlockNumber..<ChainVersion.Berlin.mainNetFisrtBlockNumber ~= block {
            return .MuirGlacier
        } else if ChainVersion.Berlin.mainNetFisrtBlockNumber..<ChainVersion.London.mainNetFisrtBlockNumber ~= block {
            return .Berlin
        } else if ChainVersion.London.mainNetFisrtBlockNumber..<ChainVersion.ArrowGlacier.mainNetFisrtBlockNumber ~= block {
            return .London
        } else if block >= ChainVersion.ArrowGlacier.mainNetFisrtBlockNumber {
            // Pass to the default return.
        }
        return .ArrowGlacier
    }
}

extension Web3.ChainVersion: Comparable {
    public static func < (lhs: Web3.ChainVersion, rhs: Web3.ChainVersion) -> Bool { return lhs.mainNetFisrtBlockNumber < rhs.mainNetFisrtBlockNumber }
 }
