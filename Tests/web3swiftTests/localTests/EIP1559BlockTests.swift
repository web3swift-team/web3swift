import XCTest
import BigInt

@testable
import web3swift

@testable
import Web3Core

class EIP1559BlockTests: LocalTestCase {
    let uselessBlockPart = (
        number: BigUInt(12_965_000),
        hash: Data(from: "0xef95f2f1ed3ca60b048b4bf67cde2195961e0bba6f70bcbea9a2c4e133e34b46")!, // "hash":
        parentHash: Data(from: "0x2302e1c0b972d00932deb5dab9eb2982f570597d9d42504c05d9c2147eaf9c88")!, // "parentHash":
        nonce: Data(from: "0xfb6e1a62d119228b"), // "nonce":
        sha3Uncles: Data(from: "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347")!, // "sha3Uncles":
        receiptsRoot: Data(from: "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347")!, // "receiptsRoot":
        logsBloom: EthereumBloomFilter(Data(from: "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")!), // "logsBloom":
        transactionsRoot: Data(from: "0x3a1b03875115b79539e5bd33fb00d8f7b7cd61929d5a3c574f507b8acf415bee")!, // "transactionsRoot":
        stateRoot: Data(from: "0xf1133199d44695dfa8fd1bcfe424d82854b5cebef75bddd7e40ea94cda515bcb")!, // "stateRoot":
        miner: EthereumAddress(Data(from: "0x8888f1f195afa192cfee860698584c030f4c9db1")!)!, // "miner":
        difficulty: BigUInt(21345678965432), // "difficulty":
        totalDifficulty: BigUInt(324567845321), // "totalDifficulty":
        size: BigUInt(616), // "size":
        extraData: Data(from: "0x")!, // extraData":
        gasLimit: BigUInt(3141592), // "gasLimit":
        gasUsed: BigUInt(21662), // "gasUsed":
        timestamp: Date(), // "timestamp":
        transactions: [TransactionInBlock](), // "transactions":
        uncles: [Data]() // "uncles":
    )

    /// testBlockGasLimits tests the gasLimit checks for blocks both across
    /// the EIP-1559 boundary and post-1559 blocks
    func testBlockGasLimits() throws {
        // [0] - parentGasLimit
        // [1] - parentNumber
        // [2] - currentGasLimit
        // [3] - Should fail or not
        let headerArray: [(BigUInt, BigUInt, BigUInt, Bool)] = [
            // Transitions from non-london to london
            (10_000_000, 12_964_999, 20_000_000, true),  // No change
            (10_000_000, 12_964_999, 20_019_530, true),  // Upper limit
            (10_000_000, 12_964_999, 20_019_531, false), // Upper +1
            (10_000_000, 12_964_999, 19_980_470, true),  // Lower limit
            (10_000_000, 12_964_999, 19_980_469, false), // Lower limit -1

            // London to London
            (20_000_000, 12_965_000, 20_000_000, true),
            (20_000_000, 12_965_000, 20_019_530, true),  // Upper limit
            (20_000_000, 12_965_000, 20_019_531, false), // Upper limit +1
            (20_000_000, 12_965_000, 19_980_470, true),  // Lower limit
            (20_000_000, 12_965_000, 19_980_469, false), // Lower limit -1
            (40_000_000, 12_965_000, 40_039_061, true),  // Upper limit
            (40_000_000, 12_965_000, 40_039_062, false), // Upper limit +1
            (40_000_000, 12_965_000, 39_960_939, true),  // lower limit
            (40_000_000, 12_965_000, 39_960_938, false) // Lower limit -1
        ]

        headerArray.forEach { (tuple: (parentGasLimit: BigUInt, parentNumber: BigUInt, currentGasLimit: BigUInt, is1559: Bool)) in
            let parent = Block(number: tuple.parentNumber,
                               hash: uselessBlockPart.hash,
                               parentHash: uselessBlockPart.parentHash,
                               nonce: uselessBlockPart.nonce,
                               sha3Uncles: uselessBlockPart.sha3Uncles,
                               logsBloom: uselessBlockPart.logsBloom,
                               transactionsRoot: uselessBlockPart.transactionsRoot,
                               stateRoot: uselessBlockPart.stateRoot,
                               receiptsRoot: uselessBlockPart.receiptsRoot,
                               miner: uselessBlockPart.miner,
                               difficulty: uselessBlockPart.difficulty,
                               totalDifficulty: uselessBlockPart.totalDifficulty,
                               extraData: uselessBlockPart.extraData,
                               size: uselessBlockPart.size,
                               gasLimit: tuple.parentGasLimit,
                               gasUsed: tuple.parentGasLimit / 2,
                               baseFeePerGas: Web3.InitialBaseFee,
                               timestamp: uselessBlockPart.timestamp,
                               transactions: uselessBlockPart.transactions,
                               uncles: uselessBlockPart.uncles)

            let current = Block(number: tuple.parentNumber + 1,
                                hash: uselessBlockPart.hash,
                                parentHash: uselessBlockPart.parentHash,
                                nonce: uselessBlockPart.nonce,
                                sha3Uncles: uselessBlockPart.sha3Uncles,
                                logsBloom: uselessBlockPart.logsBloom,
                                transactionsRoot: uselessBlockPart.transactionsRoot,
                                stateRoot: uselessBlockPart.stateRoot,
                                receiptsRoot: uselessBlockPart.receiptsRoot,
                                miner: uselessBlockPart.miner,
                                difficulty: uselessBlockPart.difficulty,
                                totalDifficulty: uselessBlockPart.totalDifficulty,
                                extraData: uselessBlockPart.extraData,
                                size: uselessBlockPart.size,
                                gasLimit: tuple.currentGasLimit,
                                gasUsed: tuple.currentGasLimit / 2,
                                baseFeePerGas: Web3.InitialBaseFee,
                                timestamp: uselessBlockPart.timestamp,
                                transactions: uselessBlockPart.transactions,
                                uncles: uselessBlockPart.uncles)

            if tuple.is1559 {
                XCTAssertTrue(Web3.isEip1559Block(parent: parent, current: current),
                              "Should not fail, got parent: \(parent.gasLimit), current: \(current.gasLimit)")
            } else {
                XCTAssertFalse(Web3.isEip1559Block(parent: parent, current: current),
                               "Should fail, got parent: \(parent.gasLimit), current: \(current.gasLimit)")
            }
        }
    }

    /// testCalcBaseFee assumes all blocks are 1559-blocks
    func testCalcBaseFee() throws {
        // [0] - parentBaseFee
        // [1] - parentNumber
        // [2] - parentGasLimit
        // [3] - parentGasUsed
        // [4] - expectedBaseFee
        let headerArray: [(BigUInt, BigUInt, BigUInt, BigUInt, BigUInt)] = [
            (Web3.InitialBaseFee, 12_964_999, 20000000, 10000000, Web3.InitialBaseFee),     // parent is not London
            (Web3.InitialBaseFee, 12_965_000, 20000000, 10000000, Web3.InitialBaseFee),     // current == target
            (Web3.InitialBaseFee, 12_965_000, 20000000, 9000000, 987500000),                // current below target
            (Web3.InitialBaseFee, 12_965_000, 20000000, 11000000, 1012500000)              // current above target
        ]

        headerArray.forEach { (tuple: (parentBaseFee: BigUInt, parentNumber: BigUInt, parentGasLimit: BigUInt, parentGasUsed: BigUInt, expectedBaseFee: BigUInt)) in
            let parent = Block(number: tuple.parentNumber,
                               hash: uselessBlockPart.hash,
                               parentHash: uselessBlockPart.parentHash,
                               nonce: uselessBlockPart.nonce,
                               sha3Uncles: uselessBlockPart.sha3Uncles,
                               logsBloom: uselessBlockPart.logsBloom,
                               transactionsRoot: uselessBlockPart.transactionsRoot,
                               stateRoot: uselessBlockPart.stateRoot,
                               receiptsRoot: uselessBlockPart.receiptsRoot,
                               miner: uselessBlockPart.miner,
                               difficulty: uselessBlockPart.difficulty,
                               totalDifficulty: uselessBlockPart.totalDifficulty,
                               extraData: uselessBlockPart.extraData,
                               size: uselessBlockPart.size,
                               gasLimit: tuple.parentGasLimit,
                               gasUsed: tuple.parentGasUsed,
                               baseFeePerGas: Web3.InitialBaseFee,
                               timestamp: uselessBlockPart.timestamp,
                               transactions: uselessBlockPart.transactions,
                               uncles: uselessBlockPart.uncles)

            let calculatedBaseFee = Web3.calcBaseFee(parent)

            XCTAssertEqual(calculatedBaseFee, tuple.expectedBaseFee, "Base fee calculation fails: should be \(tuple.expectedBaseFee), got: \(String(describing: calculatedBaseFee))")
        }
    }
}
