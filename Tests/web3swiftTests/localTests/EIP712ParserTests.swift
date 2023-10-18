//
//  EIP712ParserTests.swift
//
//
//  Created by JeneaVranceanu on 18.10.2023.
//

import Foundation
import XCTest
import web3swift
import Web3Core

class EIP712ParserTests: XCTestCase {
    let testTypedDataPayload = """
    {
    "types":{
      "EIP712Domain":[
         {
            "name":"name",
            "type":"string"
         },
         {
            "name":"version",
            "type":"string"
         },
         {
            "name":"chainId",
            "type":"uint256"
         },
         {
            "name":"verifyingContract",
            "type":"address"
         }
      ],
      "Person":[
         {
            "name":"name",
            "type":"string"
         },
         {
            "name":"wallet",
            "type":"address"
         }
      ],
      "Mail":[
         {
            "name":"from",
            "type":"Person"
         },
         {
            "name":"to",
            "type":"Person"
         },
         {
            "name":"contents",
            "type":"string"
         }
      ]
    },
    "primaryType":"Mail",
    "domain":{
      "name":"Ether Mail",
      "version":"1",
      "chainId":1,
      "verifyingContract":"0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"
    },
    "message":{
      "from":{
         "name":"Cow",
         "wallet":"0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"
      },
      "to":{
         "name":"Bob",
         "wallet":"0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB"
      },
      "contents":"Hello, Bob!"
    }
    }
    """

    func testEIP712Parser() throws {
        let parsedEip712TypedData = try EIP712Parser.parse(testTypedDataPayload)

        XCTAssertEqual(parsedEip712TypedData.types.count, 3)
        let eip712Domain = parsedEip712TypedData.types["EIP712Domain"]
        XCTAssertNotNil(eip712Domain)
        let person = parsedEip712TypedData.types["Person"]
        XCTAssertNotNil(person)
        let mail = parsedEip712TypedData.types["Mail"]
        XCTAssertNotNil(mail)


        XCTAssertNotNil(eip712Domain?.first { $0.name == "name" && $0.type == "string"})
        XCTAssertNotNil(eip712Domain?.first { $0.name == "version" && $0.type == "string"})
        XCTAssertNotNil(eip712Domain?.first { $0.name == "chainId" && $0.type == "uint256"})
        XCTAssertNotNil(eip712Domain?.first { $0.name == "verifyingContract" && $0.type == "address"})


        XCTAssertNotNil(person?.first { $0.name == "name" && $0.type == "string"})
        XCTAssertNotNil(person?.first { $0.name == "wallet" && $0.type == "address"})

        XCTAssertNotNil(mail?.first { $0.name == "from" && $0.type == "Person"})
        XCTAssertNotNil(mail?.first { $0.name == "to" && $0.type == "Person"})
        XCTAssertNotNil(mail?.first { $0.name == "contents" && $0.type == "string"})

        XCTAssertEqual(parsedEip712TypedData.primaryType, "Mail")

        XCTAssertEqual(parsedEip712TypedData.domain.count, 4)
        XCTAssertEqual(parsedEip712TypedData.domain["name"] as? String, "Ether Mail")
        XCTAssertEqual(parsedEip712TypedData.domain["version"] as? String, "1")
        XCTAssertEqual(parsedEip712TypedData.domain["chainId"] as? Int, 1)
        XCTAssertEqual(parsedEip712TypedData.domain["verifyingContract"] as? String, "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC")


        XCTAssertEqual(parsedEip712TypedData.message.count, 3)
        XCTAssertEqual(parsedEip712TypedData.message["from"] as? [String : String],
                       ["name" : "Cow",
                        "wallet" : "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"])
        XCTAssertEqual(parsedEip712TypedData.message["to"] as? [String : String],
                       ["name" : "Bob",
                        "wallet" : "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB"])
        XCTAssertEqual(parsedEip712TypedData.message["contents"] as? String, "Hello, Bob!")
    }
}
