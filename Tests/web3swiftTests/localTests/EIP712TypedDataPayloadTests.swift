//
//  EIP712TypedDataPayloadTests.swift
//
//  Created by JeneaVranceanu on 18.10.2023.
//

import Foundation
import XCTest
import web3swift
import Web3Core


/// Tests based primarily on the following example https://eips.ethereum.org/assets/eip-712/Example.js
class EIP712TypedDataPayloadTests: XCTestCase {
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

    func testEIP712CircularDependency() throws {
        let problematicTypeExample = """
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
             },
             {
                "name":"mail",
                "type":"Mail"
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
        XCTAssertThrowsError(try EIP712Parser.parse(problematicTypeExample)) { error in
            guard let error = error as? Web3Error else {
                XCTFail("Thrown error is not Web3Error.")
                return
            }

            if case let .inputError(desc) = error {
                XCTAssertTrue(desc.hasPrefix("Created EIP712TypedData has a circular dependency amongst it's types."))
            } else {
                XCTFail("A different Web3Error is thrown. Something changed?")
            }
        }
    }

    func testEIP712EncodeType() throws {
        let parsedEip712TypedData = try EIP712Parser.parse(testTypedDataPayload)
        try XCTAssertEqual(parsedEip712TypedData.encodeType("EIP712Domain"), "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
        try XCTAssertEqual(parsedEip712TypedData.encodeType("Person"), "Person(string name,address wallet)")
        try XCTAssertEqual(parsedEip712TypedData.encodeType("Mail"), "Mail(Person from,Person to,string contents)Person(string name,address wallet)")
    }

    func testEIP712TypeHash() throws {
        let parsedEip712TypedData = try EIP712Parser.parse(testTypedDataPayload)
        try XCTAssertEqual(parsedEip712TypedData.typeHash("EIP712Domain"), "0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f")
        try XCTAssertEqual(parsedEip712TypedData.typeHash("Person"), "0xb9d8c78acf9b987311de6c7b45bb6a9c8e1bf361fa7fd3467a2163f994c79500")
        try XCTAssertEqual(parsedEip712TypedData.typeHash("Mail"), "0xa0cedeb2dc280ba39b857546d74f5549c3a1d7bdc2dd96bf881f76108e23dac2")
    }
}
