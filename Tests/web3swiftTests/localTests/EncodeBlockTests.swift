//
//  EncodeBlockTests.swift
//  
//
//  Created by liugang zhang on 2023/2/7.
//

import XCTest
import Web3Core

@testable import web3swift

class EncodeBlockTests: XCTestCase {

    let jsonString = """
{
    "baseFeePerGas": "0x22f0230dca",
    "difficulty": "0x19",
    "extraData": "0xd682030383626f7288676f312e31392e35856c696e75780000000000000000002b1b4555e1f481ece3af85f088806c316794e6099a921fdf33c17c18201a008261e04c699f2ebcd807e5e411cc50ba03736b88976b0819f1ad9b7c2d8132882f00",
    "gasLimit": "0x1c9c380",
    "gasUsed": "0xa762f7",
    "hash": "0xd134bf0b5be7d738a8325e66489ac0187ae285ecacbcc7381c03904f28daed91",
    "logsBloom": "0x45a05090040c2503045e0421ec748000600693c2260016205046633008c3110006c4115192105918513315d009c0090fca88c9000a523805a2891786422739c3811d0a0012024838026200a9a16eaee0b238a6a19f8400f90713165990096290110a1041c21681108db06e0018041d01e800234561165309b9a722b0980e08fa3e71a1c248b8734212e1080415662b2201c52c8106f24008465a8374201820412f7e1e4615354313426d21301014170c625484c532a878cc0142ad32a22848554804b6035c1e15011611ca02aaa25110465105c44849e11060b89788318c6826c451c9a08103d0080524d10a9d658160e198034f00aa8059962018420b1468a9",
    "miner": "0x0000000000000000000000000000000000000000",
    "mixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "nonce": "0x0000000000000000",
    "number": "0x250c05e",
    "parentHash": "0x2dc4ea2a6b9f85ba333f590fdf77623a92576f6b4cc517c66d37993c6d7a2438",
    "receiptsRoot": "0x0d8aedf6938b256216c033a8cdbed0a6095077f9060e3a8a1c92089d5cd1cba9",
    "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
    "size": "0xabf8",
    "stateRoot": "0xa3994967e8337e70ea319729f35b0092be1f72b5c288fbfe74884a37442fc67e",
    "timestamp": "0x63dc7aff",
    "totalDifficulty": "0x256bbb88",
    "transactions": [
      "0xab9e112582a2d607043cd069dd4340a047cf236cac8b3cfc0b292edd69a5e2c1",
      "0x0713a7b61c7e5b3c29e6592263cb500cc1a831c8aae684ad3238525bd056ebcf",
      "0xeb044ea99147498ed235136b32b9736d0b2255f108175b3342565c80b9542133",
      "0x513d41cd768f86322f83be9c54bb7166a0f756383b583352455b789c02e4b7f5",
      "0xc186a989b313bd5db5837340dee22c8186da45eaefebda22e73819220dbb8567"
    ],
    "transactionsRoot": "0x4e57c4a56efcafa34fbded6a40289436ec95209e2ab242f8a572d27eb612c5a5",
    "uncles": [
        "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
        "0xa3994967e8337e70ea319729f35b0092be1f72b5c288fbfe74884a37442fc67e"
    ]
}
"""

    func testData() throws {
        let receiptsRoot = "0x0d8aedf6938b256216c033a8cdbed0a6095077f9060e3a8a1c92089d5cd1cba9"
        XCTAssertEqual(Data(from: receiptsRoot)?.hexString, receiptsRoot)

        let nonce = "0x0000000000000000"
        XCTAssertEqual(Data(from: nonce)?.hexString, nonce)
    }

    func testDate() throws {
        let timestamp = "0x63dc7aff"
        let date = Date(from: timestamp)
        XCTAssertEqual(date?.hexString, timestamp)

        XCTAssertEqual(Date(timeIntervalSince1970: 32).hexString, "0x20")
        XCTAssertEqual(Date(from: "0x20")?.timeIntervalSince1970, 32)
        XCTAssertEqual(Date(from: "20")?.timeIntervalSince1970, 32)
    }

    func testBlockEncode() throws {
        let jsonData = jsonString.data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: jsonData) as! [String: Any]
        let block = try JSONDecoder().decode(Block.self, from: jsonData)

        let encoded = try JSONEncoder().encode(block)
        let encodedJson = try JSONSerialization.jsonObject(with: encoded) as! [String: Any]

        XCTAssertEqual(encodedJson["baseFeePerGas"] as? String, json["baseFeePerGas"] as? String)
        XCTAssertEqual(encodedJson["difficulty"] as? String, json["difficulty"] as? String)
        XCTAssertEqual(encodedJson["extraData"] as? String, json["extraData"] as? String)
        XCTAssertEqual(encodedJson["gasLimit"] as? String, json["gasLimit"] as? String)
        XCTAssertEqual(encodedJson["gasUsed"] as? String, json["gasUsed"] as? String)
        XCTAssertEqual(encodedJson["hash"] as? String, json["hash"] as? String)
        XCTAssertEqual(encodedJson["logsBloom"] as? String, json["logsBloom"] as? String)
        XCTAssertEqual(encodedJson["miner"] as? String, json["miner"] as? String)
        XCTAssertEqual(encodedJson["nonce"] as? String, json["nonce"] as? String)
        XCTAssertEqual(encodedJson["number"] as? String, json["number"] as? String)
        XCTAssertEqual(encodedJson["parentHash"] as? String, json["parentHash"] as? String)
        XCTAssertEqual(encodedJson["receiptsRoot"] as? String, json["receiptsRoot"] as? String)
        XCTAssertEqual(encodedJson["sha3Uncles"] as? String, json["sha3Uncles"] as? String)
        XCTAssertEqual(encodedJson["size"] as? String, json["size"] as? String)
        XCTAssertEqual(encodedJson["stateRoot"] as? String, json["stateRoot"] as? String)
        XCTAssertEqual(encodedJson["totalDifficulty"] as? String, json["totalDifficulty"] as? String)
        XCTAssertEqual(encodedJson["transactionsRoot"] as? String, json["transactionsRoot"] as? String)
        XCTAssertEqual(encodedJson["transactions"] as? Array<String>, json["transactions"] as? Array<String>)
        XCTAssertEqual(encodedJson["uncles"] as? Array<String>, json["uncles"] as? Array<String>)

        // TODO: add another test for `CodableTransaction`
        XCTAssertEqual(encodedJson["transactions"] as? Array<String>, json["transactions"] as? Array<String>)
    }

    func testInvalidTransactionInBlock() throws {
        let string = """
    [
      "0xab9e112582a2d607043cd069dd4340a047cf236cac8b3cfc0b292edd69a5e2c1",
      [
          123
      ]
    ]
"""
        let jsonData = string.data(using: .utf8)!
        let transactions = try JSONDecoder().decode([TransactionInBlock].self, from: jsonData)

        let encoded = try JSONEncoder().encode(transactions)
        let encodedJson = try JSONSerialization.jsonObject(with: encoded) as! [Any]

        print(String(data: encoded, encoding: .utf8)!)

        XCTAssertEqual(encodedJson[0] as? String, "0xab9e112582a2d607043cd069dd4340a047cf236cac8b3cfc0b292edd69a5e2c1")
        XCTAssertTrue(encodedJson[1] is NSNull)
    }
}
