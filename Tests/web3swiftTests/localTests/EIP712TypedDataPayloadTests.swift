//
//  EIP712TypedDataPayloadTests.swift
//
//  Created by JeneaVranceanu on 18.10.2023.
//

import Foundation
import XCTest
import web3swift
@testable import Web3Core

// TODO: take more tests from https://github.com/Mrtenz/eip-712/blob/master/src/eip-712.test.ts

/// Tests based primarily on the following example https://eips.ethereum.org/assets/eip-712/Example.js
class EIP712TypedDataPayloadTests: XCTestCase {
    func testEIP712Parser() throws {
        let parsedEip712TypedData = try EIP712Parser.parse(EIP712TestData.testTypedDataPayload)

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
        let parsedEip712TypedData = try EIP712Parser.parse(EIP712TestData.testTypedDataPayload)
        try XCTAssertEqual(parsedEip712TypedData.encodeType("EIP712Domain"), "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
        try XCTAssertEqual(parsedEip712TypedData.encodeType("Person"), "Person(string name,address wallet)")
        try XCTAssertEqual(parsedEip712TypedData.encodeType("Mail"), "Mail(Person from,Person to,string contents)Person(string name,address wallet)")
    }

    func testEIP712TypeHash() throws {
        let parsedEip712TypedData = try EIP712Parser.parse(EIP712TestData.testTypedDataPayload)
        try XCTAssertEqual(parsedEip712TypedData.typeHash("EIP712Domain"), "0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f")
        try XCTAssertEqual(parsedEip712TypedData.typeHash("Person"), "0xb9d8c78acf9b987311de6c7b45bb6a9c8e1bf361fa7fd3467a2163f994c79500")
        try XCTAssertEqual(parsedEip712TypedData.typeHash("Mail"), "0xa0cedeb2dc280ba39b857546d74f5549c3a1d7bdc2dd96bf881f76108e23dac2")
    }

    func testEIP712EncodeData() throws {
        let parsedEip712TypedData = try EIP712Parser.parse(EIP712TestData.testTypedDataPayload)
        let encodedMessage = "a0cedeb2dc280ba39b857546d74f5549c3a1d7bdc2dd96bf881f76108e23dac2fc71e5fa27ff56c350aa531bc129ebdf613b772b6604664f5d8dbe21b85eb0c8cd54f074a4af31b4411ff6a60c9719dbd559c221c8ac3492d9d872b041d703d1b5aadf3154a261abdd9086fc627b61efca26ae5702701d05cd2305f7c52a2fc8"
        XCTAssertEqual(try parsedEip712TypedData.encodeData().toHexString(), encodedMessage)
        XCTAssertEqual(try parsedEip712TypedData.encodeData(parsedEip712TypedData.primaryType, data: parsedEip712TypedData.message).toHexString(), encodedMessage)

        XCTAssertEqual(try parsedEip712TypedData.encodeData("EIP712Domain", data: parsedEip712TypedData.domain).toHexString(),
                       "8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400fc70ef06638535b4881fafcac8287e210e3769ff1a8e91f1b95d6246e61e4d3c6c89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc60000000000000000000000000000000000000000000000000000000000000001000000000000000000000000cccccccccccccccccccccccccccccccccccccccc")

        XCTAssertEqual(try parsedEip712TypedData.encodeData("Person", data: parsedEip712TypedData.message["from"] as! [String : AnyObject]).toHexString(),
                       "b9d8c78acf9b987311de6c7b45bb6a9c8e1bf361fa7fd3467a2163f994c795008c1d2bd5348394761719da11ec67eedae9502d137e8940fee8ecd6f641ee1648000000000000000000000000cd2a3d9f938e13cd947ec05abc7fe734df8dd826")

        XCTAssertEqual(try parsedEip712TypedData.encodeData("Person",
                                                            data: ["wallet" : "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
                                                                   "name" : "Cow"] as [String : AnyObject]).toHexString(),
                       "b9d8c78acf9b987311de6c7b45bb6a9c8e1bf361fa7fd3467a2163f994c795008c1d2bd5348394761719da11ec67eedae9502d137e8940fee8ecd6f641ee1648000000000000000000000000cd2a3d9f938e13cd947ec05abc7fe734df8dd826")
    }

    func testEIP712StructHash() throws {
        let parsedEip712TypedData = try EIP712Parser.parse(EIP712TestData.testTypedDataPayload)
        XCTAssertEqual(try parsedEip712TypedData.structHash().toHexString(), "c52c0ee5d84264471806290a3f2c4cecfc5490626bf912d01f240d7a274b371e")
        XCTAssertEqual(try parsedEip712TypedData.structHash("EIP712Domain", data: parsedEip712TypedData.domain).toHexString(),
                       "f2cee375fa42b42143804025fc449deafd50cc031ca257e0b194a650a912090f")
    }

    func testEIP712SignHash() throws {
        let parsedEip712TypedData = try EIP712Parser.parse(EIP712TestData.testTypedDataPayload)
        XCTAssertEqual(try parsedEip712TypedData.signHash().toHexString(), "be609aee343fb3c4b28e1df9e632fca64fcfaede20f02e86244efddf30957bd2")
    }

    func testEIP712Signing() throws {
        let parsedEip712TypedData = try EIP712Parser.parse(EIP712TestData.testTypedDataPayload)
        let privateKey = Data.fromHex("cow".sha3(.keccak256).addHexPrefix())!
        let publicKey = Utilities.privateToPublic(privateKey)!
        let address = Utilities.publicToAddress(publicKey)!
        XCTAssertEqual(address, EthereumAddress("0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826"));

        /// This signing doesn't use `"\u{19}Ethereum Signed Message:\n"`. As per EIP712 standard
        /// the following format is used instead:
        /// ```
        ///     encode(domainSeparator : 𝔹²⁵⁶, message : 𝕊) = "\x19\x01" ‖ domainSeparator ‖ hashStruct(message)
        /// ```
        ///
        /// The output of ``EIP712TypedData.signHash`` is exactly that.
        let (compressedSignature, _) = try SECP256K1.signForRecovery(hash: parsedEip712TypedData.signHash(), privateKey: privateKey)
        let unmarshalledSignature = Utilities.unmarshalSignature(signatureData: compressedSignature!)!
        XCTAssertEqual(unmarshalledSignature.v, 28)
        XCTAssertEqual(unmarshalledSignature.r.toHexString(), "4355c47d63924e8a72e509b65029052eb6c299d53a04e167c5775fd466751c9d")
        XCTAssertEqual(unmarshalledSignature.s.toHexString(), "07299936d304c153f6443dfa05f40ff007d72911b6f72307f996231605b91562")
    }
}
