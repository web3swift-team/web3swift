//
//  EventTests.swift
//
//
//  Created by liugang zhang on 2023/8/24.
//

import XCTest
import Web3Core
import BigInt

@testable import web3swift

class EventTests: XCTestCase {

    /// Solidity event allows up to 3 indexed field, this is just for test.
    let testEvent = """
    [{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"userOpHash","type":"bytes32"},{"indexed":true,"internalType":"address","name":"sender","type":"address"},{"indexed":true,"internalType":"string","name":"a","type":"string"},{"indexed":true,"internalType":"bool","name":"b","type":"bool"},{"indexed":true,"internalType":"bytes","name":"c","type":"bytes"},{"indexed":true,"internalType":"uint256","name":"d","type":"uint256"}],"name":"UserOperationEvent","type":"event"}]
    """

    func testEncodeTopicToJSON() throws {
        let encoder = JSONEncoder()
        let t1: [EventFilterParameters.Topic] = []
        let t2: [EventFilterParameters.Topic] = [.string(nil)]
        let t3: [EventFilterParameters.Topic] = [.strings([.string(nil), .string("1")])]
        let t4: [EventFilterParameters.Topic] = [.strings([nil, .string("1")])]
        XCTAssertNoThrow(try encoder.encode(t1))
        XCTAssertNoThrow(try encoder.encode(t2))
        XCTAssertNoThrow(try encoder.encode(t3))
        XCTAssertNoThrow(try encoder.encode(t4))

        let topics: [EventFilterParameters.Topic] = [
            .string("1"),
            .strings([
                .string("2"),
                .string("3"),
            ]
        )]
        let encoded = try encoder.encode(topics)
        let json = try JSONSerialization.jsonObject(with: encoded)
        XCTAssertEqual(json as? NSArray, ["1", ["2", "3"]])
    }

    func testEncodeLogs() throws {
        let contract = try EthereumContract(testEvent)
        let topic = contract.events["UserOperationEvent"]!.topic
        let logs = contract.events["UserOperationEvent"]!.encodeParameters(
            [
                "0x2c16c07e1c68d502e9c7ad05f0402b365671a0e6517cb807b2de4edd95657042",
                "0x581074D2d9e50913eB37665b07CAFa9bFFdd1640",
                "hello,world",
                true,
                "0x02c16c07e1c68d50",
                nil
            ]
        )
        XCTAssertEqual(logs.count, 6)

        XCTAssertTrue(logs[0] == topic.toHexString().addHexPrefix())
        XCTAssertTrue(logs[1] == "0x2c16c07e1c68d502e9c7ad05f0402b365671a0e6517cb807b2de4edd95657042")
        XCTAssertTrue(logs[2] == "0x000000000000000000000000581074d2d9e50913eb37665b07cafa9bffdd1640")
        XCTAssertTrue(logs[3] == "0xab036729af8b8f9b610af4e11b14fa30c348f40c2c230cce92ef6ef37726fee7")
        XCTAssertTrue(logs[4] == "0x0000000000000000000000000000000000000000000000000000000000000001")
        XCTAssertTrue(logs[5] == "0x56f5a6cba57d26b32db8dc756fda960dcd3687770a300575a5f8107591eff63f")
    }

    func testEncodeTopic() throws {
        XCTAssertTrue(ABI.Element.Event.encodeTopic(input: .init(name: "", type: .string, indexed: true), value: "hello,world") == "0xab036729af8b8f9b610af4e11b14fa30c348f40c2c230cce92ef6ef37726fee7")
        XCTAssertTrue(ABI.Element.Event.encodeTopic(input: .init(name: "", type: .address, indexed: true), value: "0x003e36550908907c2a2da960fd19a419b9a774b7") == "0x000000000000000000000000003e36550908907c2a2da960fd19a419b9a774b7")
        XCTAssertTrue(ABI.Element.Event.encodeTopic(input: .init(name: "", type: .address, indexed: true), value: EthereumAddress("0x003e36550908907c2a2da960fd19a419b9a774b7")!) == "0x000000000000000000000000003e36550908907c2a2da960fd19a419b9a774b7")
        XCTAssertTrue(ABI.Element.Event.encodeTopic(input: .init(name: "", type: .bool, indexed: true), value: true) == "0x0000000000000000000000000000000000000000000000000000000000000001")
        XCTAssertTrue(ABI.Element.Event.encodeTopic(input: .init(name: "", type: .bool, indexed: true), value: false) == "0x0000000000000000000000000000000000000000000000000000000000000000")
        XCTAssertTrue(ABI.Element.Event.encodeTopic(input: .init(name: "", type: .uint(bits: 256), indexed: true), value: BigUInt("dbe20a", radix: 16)!) == "0x0000000000000000000000000000000000000000000000000000000000dbe20a")
        XCTAssertTrue(ABI.Element.Event.encodeTopic(input: .init(name: "", type: .uint(bits: 256), indexed: true), value: "dbe20a") == "0x0000000000000000000000000000000000000000000000000000000000dbe20a")
        XCTAssertTrue(ABI.Element.Event.encodeTopic(input: .init(name: "", type: .int(bits: 32), indexed: true), value: 100) == "0x0000000000000000000000000000000000000000000000000000000000000064")
        XCTAssertTrue(ABI.Element.Event.encodeTopic(input: .init(name: "", type: .dynamicBytes, indexed: true), value: Data(hex: "6761766f66796f726b")) == "0xe0859ceea0a2fd2474deef2b2183f10f4c741ebba702e9a07d337522c0af55fb")
        XCTAssertTrue(ABI.Element.Event.encodeTopic(input: .init(name: "", type: .bytes(length: 32), indexed: true), value: Data(hex: "6761766f66796f726b")) == "0x00000000000000000000000000000000000000000000006761766f66796f726b")
        XCTAssertTrue(ABI.Element.Event.encodeTopic(input: .init(name: "", type: .bytes(length: 32), indexed: true), value: "0x6761766f66796f726b") == "0x00000000000000000000000000000000000000000000006761766f66796f726b")
    }
}

private func ==(lhs: EventFilterParameters.Topic?, rhs: String?) -> Bool {
    if let lhs = lhs, case .string(let string) = lhs {
        return string == rhs
    }
    if lhs == nil && rhs == nil {
        return true
    }
    return false
}
