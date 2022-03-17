import XCTest
import BigInt

@testable
import web3swift

class EIP1559Tests: XCTestCase {

    func testBlockGasLimits() throws {
        let uselessBlockPart = [
            // "number": 3,

            "hash": Data(from: "0xef95f2f1ed3ca60b048b4bf67cde2195961e0bba6f70bcbea9a2c4e133e34b46"),
            "parentHash": Data(from: "0x2302e1c0b972d00932deb5dab9eb2982f570597d9d42504c05d9c2147eaf9c88"),
//            "baseFeePerGas": 58713056622,
            "nonce": "0xfb6e1a62d119228b",
            "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
            "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
            "transactionsRoot": "0x3a1b03875115b79539e5bd33fb00d8f7b7cd61929d5a3c574f507b8acf415bee",
            "stateRoot": "0xf1133199d44695dfa8fd1bcfe424d82854b5cebef75bddd7e40ea94cda515bcb",
            "miner": "0x8888f1f195afa192cfee860698584c030f4c9db1",
            "difficulty": "21345678965432",
            "totalDifficulty": "324567845321",
            "size": 616,
            "extraData": "0x",
            // "gasLimit": 3141592,
            "gasUsed": 21662,
            "timestamp": 1429287689,
            "transactions": [
                "0x9fc76417374aa880d4449a1f7f31ec597f00b1f6f3dd2d66f4c9c6c445836d8b"
            ],
            "uncles": []
        ]
        /*
        web3.eth.getBlock(3150).then(console.log);
        > {
            "number": 3,
            "hash": "0xef95f2f1ed3ca60b048b4bf67cde2195961e0bba6f70bcbea9a2c4e133e34b46",
            "parentHash": "0x2302e1c0b972d00932deb5dab9eb2982f570597d9d42504c05d9c2147eaf9c88",
            "baseFeePerGas": 58713056622,
            "nonce": "0xfb6e1a62d119228b",
            "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
            "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
            "transactionsRoot": "0x3a1b03875115b79539e5bd33fb00d8f7b7cd61929d5a3c574f507b8acf415bee",
            "stateRoot": "0xf1133199d44695dfa8fd1bcfe424d82854b5cebef75bddd7e40ea94cda515bcb",
            "miner": "0x8888f1f195afa192cfee860698584c030f4c9db1",
            "difficulty": "21345678965432",
            "totalDifficulty": "324567845321",
            "size": 616,
            "extraData": "0x",
            "gasLimit": 3141592,
            "gasUsed": 21662,
            "timestamp": 1429287689,
            "transactions": [
                "0x9fc76417374aa880d4449a1f7f31ec597f00b1f6f3dd2d66f4c9c6c445836d8b"
            ],
            "uncles": []
        }
        */

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

        headerArray.forEach { ( touple: (parentGasLimit: Int, parentNumber: Int, currentGasLimit: Int, isOk: Bool)) in
            let parent = Block(number: touple.parentGasLimit , hash: , parentHash: <#T##Data#>, nonce: <#T##Data?#>, sha3Uncles: <#T##Data#>, logsBloom: <#T##EthereumBloomFilter?#>, transactionsRoot: <#T##Data#>, stateRoot: <#T##Data#>, receiptsRoot: <#T##Data#>, miner: <#T##EthereumAddress?#>, difficulty: <#T##BigUInt#>, totalDifficulty: <#T##BigUInt#>, extraData: <#T##Data#>, size: <#T##BigUInt#>, gasLimit: <#T##BigUInt#>, gasUsed: <#T##BigUInt#>, baseFeePerGas: <#T##BigUInt#>, timestamp: <#T##Date#>, transactions: <#T##[TransactionInBlock]#>, uncles: <#T##[Data]#>)

            let current = Block()

            let web3 = Web3()

            web3.verifyEip1559Block()
        }

    }

    func testCalcBaseFee() throws {

    }



}

/*
// TestBlockGasLimits tests the gasLimit checks for blocks both across
// the EIP-1559 boundary and post-1559 blocks
func TestBlockGasLimits(t *testing.T) {
    initial := new(big.Int).SetUint64(params.InitialBaseFee)

    for i, tc := range []struct {
        pGasLimit uint64
        pNum      int64
        gasLimit  uint64
        ok        bool
    }{
        // Transitions from non-london to london
        {10000000, 4, 20000000, true},  // No change
        {10000000, 4, 20019530, true},  // Upper limit
        {10000000, 4, 20019531, false}, // Upper +1
        {10000000, 4, 19980470, true},  // Lower limit
        {10000000, 4, 19980469, false}, // Lower limit -1
        // London to London
        {20000000, 5, 20000000, true},
        {20000000, 5, 20019530, true},  // Upper limit
        {20000000, 5, 20019531, false}, // Upper limit +1
        {20000000, 5, 19980470, true},  // Lower limit
        {20000000, 5, 19980469, false}, // Lower limit -1
        {40000000, 5, 40039061, true},  // Upper limit
        {40000000, 5, 40039062, false}, // Upper limit +1
        {40000000, 5, 39960939, true},  // lower limit
        {40000000, 5, 39960938, false}, // Lower limit -1
    } {
        parent := &types.Header{
            GasUsed:  tc.pGasLimit / 2,
            GasLimit: tc.pGasLimit,
            BaseFee:  initial,
            Number:   big.NewInt(tc.pNum),
        }
        header := &types.Header{
            GasUsed:  tc.gasLimit / 2,
            GasLimit: tc.gasLimit,
            BaseFee:  initial,
            Number:   big.NewInt(tc.pNum + 1),
        }
        err := VerifyEip1559Header(config(), parent, header)
        if tc.ok && err != nil {
            t.Errorf("test %d: Expected valid header: %s", i, err)
        }
        if !tc.ok && err == nil {
            t.Errorf("test %d: Expected invalid header", i)
        }
    }
}

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
