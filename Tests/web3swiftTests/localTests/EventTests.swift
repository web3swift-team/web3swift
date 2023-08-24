//
//  EventTests.swift
//  
//
//  Created by liugang zhang on 2023/8/24.
//

import XCTest
import Web3Core

@testable import web3swift

class EventTests: XCTestCase {
    func testEncodeTopc() throws {
        let encoder = JSONEncoder()
        let t1: [EventFilterParameters.Topic] = []
        let t2: [EventFilterParameters.Topic] = [.string(nil)]
        let t3: [EventFilterParameters.Topic] = [.strings([.string(nil), .string("1")])]
        XCTAssertNoThrow(try encoder.encode(t1))
        XCTAssertNoThrow(try encoder.encode(t2))
        XCTAssertNoThrow(try encoder.encode(t3))

        let t4: [EventFilterParameters.Topic] = [
            .string("1"),
            .strings([
                .string("2"),
                .string("3"),
            ]
        )]
        let encoded = try encoder.encode(t4)
        let json = try JSONSerialization.jsonObject(with: encoded)
        XCTAssertEqual(json as? NSArray, ["1", ["2", "3"]])
    }

    func testEncodeLogs() throws {
        let contract = try EthereumContract(TestEvent)
        let logs = contract.events["UserOperationEvent"]?.encodeParameters(
            [
                "0x2c16c07e1c68d502e9c7ad05f0402b365671a0e6517cb807b2de4edd95657042",
                "0x581074D2d9e50913eB37665b07CAFa9bFFdd1640",
                "hello,world",
                true,
                "0x02c16c07e1c68d50",
                nil
            ]
        )

        XCTAssert(logs?.count == 7)
    }

    let TestEvent = """
    [{
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "bytes32",
              "name": "userOpHash",
              "type": "bytes32"
            },
            {
              "indexed": true,
              "internalType": "address",
              "name": "sender",
              "type": "address"
            },
            {
              "indexed": true,
              "internalType": "string",
              "name": "a",
              "type": "string"
            },
            {
              "indexed": true,
              "internalType": "bool",
              "name": "b",
              "type": "bool"
            },
            {
              "indexed": true,
              "internalType": "bytes",
              "name": "c",
              "type": "bytes"
            },
            {
              "indexed": true,
              "internalType": "uint256",
              "name": "d",
              "type": "uint256"
            },
          ],
          "name": "UserOperationEvent",
          "type": "event"
        }
    ]
    """
}
