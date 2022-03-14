//
//  File.swift
//  
//
//  Created by Yaroslav on 14.03.2022.
//

import Foundation
import BigInt

/// EIP-1559 Base fee extension
public extension Web3 {
    func verifyEip1559Block(chain version: ChainVersion, parent: Block, current: Block) -> Bool {
        return true
    }

    func calcBaseFee(chain version: ChainVersion, parent: Block) -> BigUInt {
        // If the current block is the first EIP-1559 block, return the InitialBaseFee.
        guard .London == version else { return Web3.InitialBaseFee }

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
        case Byzantium
        case Petersburg
        case Istanbul
        case MuirGlacier
        case Berlin
        case London
        case ArrowGlacier
        case MergeFork
        /* 
            ByzantiumBlock          // Byzantium switch block
            ConstantinopleBlock     // Constantinople switch block
            PetersburgBlock         // Petersburg switch block
            IstanbulBlock           // Istanbul switch block
            MuirGlacierBlock        // Eip-2384 (bomb delay) switch block
            BerlinBlock             // Berlin switch block
            LondonBlock             // London switch block
            ArrowGlacierBlock       // Eip-4345 (bomb delay) switch block
            MergeForkBlock
        */
    }
}

