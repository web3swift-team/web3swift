import XCTest
import BigInt

@testable
import web3swift

class EIP1559Tests: XCTestCase {

    /// testBlockGasLimits tests the gasLimit checks for blocks both across
    /// the EIP-1559 boundary and post-1559 blocks
    func testBlockGasLimits() throws {
        let uselessBlockPart = (
            number: BigUInt(3),

            hash: Data(from: "0xef95f2f1ed3ca60b048b4bf67cde2195961e0bba6f70bcbea9a2c4e133e34b46")!, // "hash":
            parentHash: Data(from: "0x2302e1c0b972d00932deb5dab9eb2982f570597d9d42504c05d9c2147eaf9c88")!, // "parentHash":
//            baseFeePerGas: 58713056622, // baseFeePerGas":
            nonce: Data(from: "0xfb6e1a62d119228b"), // "nonce":
            sha3Uncles: Data(from: "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347")!, // "sha3Uncles":
            receiptsRoot: Data(from: "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347")!, // "receiptsRoot":
            logsBloom: EthereumBloomFilter(Data(from: "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")!), // "logsBloom":
            transactionsRoot: Data(from: "0x3a1b03875115b79539e5bd33fb00d8f7b7cd61929d5a3c574f507b8acf415bee")!, // "transactionsRoot":
            stateRoot: Data(from: "0xf1133199d44695dfa8fd1bcfe424d82854b5cebef75bddd7e40ea94cda515bcb")!, // "stateRoot":
            miner: EthereumAddress( Data(from: "0x8888f1f195afa192cfee860698584c030f4c9db1")!)!, // "miner":
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

        // [0] - parentGasLimit
        // [1] - parentNumber
        // [2] - currentGasLimit
        // [3] - Should fail or not
        let headerArray: [(BigUInt, BigUInt, BigUInt, Bool) ] = [
            // Transitions from non-london to london
            (10000000, 4, 20000000, true),  // No change
            (10000000, 4, 20019530, true),  // Upper limit
            (10000000, 4, 20019531, false), // Upper +1
            (10000000, 4, 19980470, true),  // Lower limit
            (10000000, 4, 19980469, false), // Lower limit -1

            // London to London
            (20000000, 5, 20000000, true),
            (20000000, 5, 20019530, true),  // Upper limit
            (20000000, 5, 20019531, false), // Upper limit +1
            (20000000, 5, 19980470, true),  // Lower limit
            (20000000, 5, 19980469, false), // Lower limit -1
            (40000000, 5, 40039061, true),  // Upper limit
            (40000000, 5, 40039062, false), // Upper limit +1
            (40000000, 5, 39960939, true),  // lower limit
            (40000000, 5, 39960938, false), // Lower limit -1
        ] 

        try headerArray.forEach { ( touple: (parentGasLimit: BigUInt, parentNumber: BigUInt, currentGasLimit: BigUInt, isOk: Bool)) in
            let parent = Block(number: touple.parentGasLimit,
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
                               gasLimit: touple.parentGasLimit,
                               gasUsed: touple.parentGasLimit / 2,
                               baseFeePerGas: Web3.InitialBaseFee,
                               timestamp: uselessBlockPart.timestamp,
                               transactions: uselessBlockPart.transactions,
                               uncles: uselessBlockPart.uncles)

            let current = Block(number: touple.parentGasLimit + 1,
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
                                gasLimit: touple.currentGasLimit,
                                gasUsed: touple.currentGasLimit / 2,
                                baseFeePerGas: Web3.InitialBaseFee,
                                timestamp: uselessBlockPart.timestamp,
                                transactions: uselessBlockPart.transactions,
                                uncles: uselessBlockPart.uncles)

            let web3 = Web3()

            if touple.isOk {
                XCTAssertNoThrow(_ = try web3.verifyEip1559Block(chain: .London, parent: parent, current: current), "Shoult not fail, got parent: \(parent.gasLimit), current: \(current.gasLimit)")
            } else {
                XCTAssertThrowsError(_ = try web3.verifyEip1559Block(chain: .London, parent: parent, current: current), "Should fail, got parent: \(parent.gasLimit), current: \(current.gasLimit)")
            }
        }
    }

    /// testCalcBaseFee assumes all blocks are 1559-blocks
    func testCalcBaseFee() throws {

    }



}

/*
// TestCalcBaseFee assumes all blocks are 1559-blocks
func TestCalcBaseFee(t *testing.T) {
    tests := []struct {
        parentBaseFee   int64
        parentGasLimit  uint64
        parentGasUsed   uint64
        expectedBaseFee int64
    }{
        {params.InitialBaseFee, 20000000, 10000000, params.InitialBaseFee}, // usage == target
        {params.InitialBaseFee, 20000000, 9000000, 987500000},              // usage below target
        {params.InitialBaseFee, 20000000, 11000000, 1012500000},            // usage above target
    }
    for i, test := range tests {
        parent := &types.Header{
            Number:   common.Big32,
            GasLimit: test.parentGasLimit,
            GasUsed:  test.parentGasUsed,
            BaseFee:  big.NewInt(test.parentBaseFee),
        }
        if have, want := CalcBaseFee(config(), parent), big.NewInt(test.expectedBaseFee); have.Cmp(want) != 0 {
            t.Errorf("test %d: have %d  want %d, ", i, have, want)
        }
    }
}

*/
