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

    func testEIP712ParserWithCustomTypeArrays() throws {
        let problematicTypeExample = """
        {"types":{"EIP712Domain":[{"name":"name","type":"string"},{"name":"version","type":"string"},{"name":"chainId","type":"uint256"},{"name":"verifyingContract","type":"address"}],"OrderComponents":[{"name":"offerer","type":"address"},{"name":"zone","type":"address"},{"name":"offer","type":"OfferItem[]"},{"name":"consideration","type":"ConsiderationItem[]"},{"name":"orderType","type":"uint8"},{"name":"startTime","type":"uint256"},{"name":"endTime","type":"uint256"},{"name":"zoneHash","type":"bytes32"},{"name":"salt","type":"uint256"},{"name":"conduitKey","type":"bytes32"},{"name":"counter","type":"uint256"}],"OfferItem":[{"name":"itemType","type":"uint8"},{"name":"token","type":"address"},{"name":"identifierOrCriteria","type":"uint256"},{"name":"startAmount","type":"uint256"},{"name":"endAmount","type":"uint256"}],"ConsiderationItem":[{"name":"itemType","type":"uint8"},{"name":"token","type":"address"},{"name":"identifierOrCriteria","type":"uint256"},{"name":"startAmount","type":"uint256"},{"name":"endAmount","type":"uint256"},{"name":"recipient","type":"address"}]},"primaryType":"OrderComponents","domain":{"name":"Seaport","version":"1.5","chainId":"5","verifyingContract":"0x00000000000000ADc04C56Bf30aC9d3c0aAF14dC"},"message":{"offerer":"0xD0727E8a578DE9Dd19BcED635B1aa43576E638bC","offer":[{"itemType":"2","token":"0xE84a7676aAe742770A179dd7431073429a88c7B8","identifierOrCriteria":"44","startAmount":"1","endAmount":"1"}],"consideration":[{"itemType":"0","token":"0x0000000000000000000000000000000000000000","identifierOrCriteria":"0","startAmount":"950000000000000000","endAmount":"950000000000000000","recipient":"0xD0727E8a578DE9Dd19BcED635B1aa43576E638bC"},{"itemType":"0","token":"0x0000000000000000000000000000000000000000","identifierOrCriteria":"0","startAmount":"25000000000000000","endAmount":"25000000000000000","recipient":"0x0000a26b00c1F0DF003000390027140000fAa719"},{"itemType":"0","token":"0x0000000000000000000000000000000000000000","identifierOrCriteria":"0","startAmount":"25000000000000000","endAmount":"25000000000000000","recipient":"0xbDEf201FB5BE36579b6B66971d40A6e162b92B80"}],"startTime":"1698665491","endTime":"1701343891","orderType":"0","zone":"0x004C00500000aD104D7DBd00e3ae0A5C00560C00","zoneHash":"0x0000000000000000000000000000000000000000000000000000000000000000","salt":"24446860302761739304752683030156737591518664810215442929808784621098726351597","conduitKey":"0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000","totalOriginalConsiderationItems":"3","counter":"0"}}
        """
        XCTAssertNoThrow(try EIP712Parser.parse(problematicTypeExample))
    }

    func testEIP712SignHashWithCustomTypeArrays() throws {
        let problematicTypeExample = """
        {"types":{"EIP712Domain":[{"name":"name","type":"string"},{"name":"version","type":"string"},{"name":"chainId","type":"uint256"},{"name":"verifyingContract","type":"address"}],"OrderComponents":[{"name":"offerer","type":"address"},{"name":"zone","type":"address"},{"name":"offer","type":"OfferItem[]"},{"name":"consideration","type":"ConsiderationItem[]"},{"name":"orderType","type":"uint8"},{"name":"startTime","type":"uint256"},{"name":"endTime","type":"uint256"},{"name":"zoneHash","type":"bytes32"},{"name":"salt","type":"uint256"},{"name":"conduitKey","type":"bytes32"},{"name":"counter","type":"uint256"}],"OfferItem":[{"name":"itemType","type":"uint8"},{"name":"token","type":"address"},{"name":"identifierOrCriteria","type":"uint256"},{"name":"startAmount","type":"uint256"},{"name":"endAmount","type":"uint256"}],"ConsiderationItem":[{"name":"itemType","type":"uint8"},{"name":"token","type":"address"},{"name":"identifierOrCriteria","type":"uint256"},{"name":"startAmount","type":"uint256"},{"name":"endAmount","type":"uint256"},{"name":"recipient","type":"address"}]},"primaryType":"OrderComponents","domain":{"name":"Seaport","version":"1.5","chainId":"5","verifyingContract":"0x00000000000000ADc04C56Bf30aC9d3c0aAF14dC"},"message":{"offerer":"0xD0727E8a578DE9Dd19BcED635B1aa43576E638bC","offer":[{"itemType":"2","token":"0xE84a7676aAe742770A179dd7431073429a88c7B8","identifierOrCriteria":"44","startAmount":"1","endAmount":"1"}],"consideration":[{"itemType":"0","token":"0x0000000000000000000000000000000000000000","identifierOrCriteria":"0","startAmount":"950000000000000000","endAmount":"950000000000000000","recipient":"0xD0727E8a578DE9Dd19BcED635B1aa43576E638bC"},{"itemType":"0","token":"0x0000000000000000000000000000000000000000","identifierOrCriteria":"0","startAmount":"25000000000000000","endAmount":"25000000000000000","recipient":"0x0000a26b00c1F0DF003000390027140000fAa719"},{"itemType":"0","token":"0x0000000000000000000000000000000000000000","identifierOrCriteria":"0","startAmount":"25000000000000000","endAmount":"25000000000000000","recipient":"0xbDEf201FB5BE36579b6B66971d40A6e162b92B80"}],"startTime":"1698665491","endTime":"1701343891","orderType":"0","zone":"0x004C00500000aD104D7DBd00e3ae0A5C00560C00","zoneHash":"0x0000000000000000000000000000000000000000000000000000000000000000","salt":"24446860302761739304752683030156737591518664810215442929808784621098726351597","conduitKey":"0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000","totalOriginalConsiderationItems":"3","counter":"0"}}
        """
        let eip712Payload = try EIP712Parser.parse(problematicTypeExample)
        XCTAssertEqual(try eip712Payload.encodeType("OrderComponents"), "OrderComponents(address offerer,address zone,OfferItem[] offer,ConsiderationItem[] consideration,uint8 orderType,uint256 startTime,uint256 endTime,bytes32 zoneHash,uint256 salt,bytes32 conduitKey,uint256 counter)ConsiderationItem(uint8 itemType,address token,uint256 identifierOrCriteria,uint256 startAmount,uint256 endAmount,address recipient)OfferItem(uint8 itemType,address token,uint256 identifierOrCriteria,uint256 startAmount,uint256 endAmount)")
        XCTAssertEqual(try eip712Payload.encodeType("OfferItem"), "OfferItem(uint8 itemType,address token,uint256 identifierOrCriteria,uint256 startAmount,uint256 endAmount)")
        XCTAssertEqual(try eip712Payload.encodeType("ConsiderationItem"), "ConsiderationItem(uint8 itemType,address token,uint256 identifierOrCriteria,uint256 startAmount,uint256 endAmount,address recipient)")
        XCTAssertNoThrow(try eip712Payload.signHash())
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
        ///     encode(domainSeparator : 𝔹²⁵⁶, message : 𝕊) = "\x19\x01" ‖ domainSeparator ‖ structHash(message)
        /// ```
        ///
        /// The output of ``EIP712TypedData.signHash`` is exactly that.
        let (compressedSignature, _) = try SECP256K1.signForRecovery(hash: parsedEip712TypedData.signHash(), privateKey: privateKey)
        let unmarshalledSignature = Utilities.unmarshalSignature(signatureData: compressedSignature!)!
        XCTAssertEqual(unmarshalledSignature.v, 28)
        XCTAssertEqual(unmarshalledSignature.r.toHexString(), "4355c47d63924e8a72e509b65029052eb6c299d53a04e167c5775fd466751c9d")
        XCTAssertEqual(unmarshalledSignature.s.toHexString(), "07299936d304c153f6443dfa05f40ff007d72911b6f72307f996231605b91562")
    }

    func testEIP712SignedTypedDataV4() throws {
        // Payload includes recursive types, arrays and empty fields
        let rawPayload = """
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
                            "name":"wallets",
                            "type":"address[]"
                        }
                    ],
                    "Mail":[
                        {
                            "name":"from",
                            "type":"Person"
                        },
                        {
                            "name":"to",
                            "type":"Person[]"
                        },
                        {
                            "name":"contents",
                            "type":"string"
                        }
                    ],
                    "Group":[
                        {
                            "name":"name",
                            "type":"string"
                        },
                        {
                            "name":"members",
                            "type":"Person[]"
                        }
                    ]
                },
                "domain":{
                    "name":"Ether Mail",
                    "version":"1",
                    "chainId":1,
                    "verifyingContract":"0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"
                },
                "primaryType":"Mail",
                "message":{
                    "from":{
                        "name":"Cow",
                        "wallets":[
                            "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
                            "0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF"
                        ]
                    },
                    "to":[
                        {
                            "name":"Bob",
                            "wallets":[
                                "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
                                "0xB0BdaBea57B0BDABeA57b0bdABEA57b0BDabEa57",
                                "0xB0B0b0b0b0b0B000000000000000000000000000"
                            ]
                        }
                    ],
                    "contents":"Hello, Bob!"
                }
            }
            """
        let parsedEip712TypedData = try EIP712Parser.parse(rawPayload)
        XCTAssertEqual(try parsedEip712TypedData.encodeType("Group"),
                       "Group(string name,Person[] members)Person(string name,address[] wallets)")
        XCTAssertEqual(try parsedEip712TypedData.encodeType("Person"),
                       "Person(string name,address[] wallets)")
        XCTAssertEqual(try parsedEip712TypedData.typeHash("Person"),
                       "0xfabfe1ed996349fc6027709802be19d047da1aa5d6894ff5f6486d92db2e6860")

        XCTAssertEqual(try parsedEip712TypedData.encodeData("Person", data: parsedEip712TypedData.message["from"] as! [String : AnyObject]).toHexString(),
                       "fabfe1ed996349fc6027709802be19d047da1aa5d6894ff5f6486d92db2e68608c1d2bd5348394761719da11ec67eedae9502d137e8940fee8ecd6f641ee16488a8bfe642b9fc19c25ada5dadfd37487461dc81dd4b0778f262c163ed81b5e2a")
        XCTAssertEqual(try parsedEip712TypedData.structHash("Person", data: parsedEip712TypedData.message["from"] as! [String : AnyObject]).toHexString(),
                       "9b4846dd48b866f0ac54d61b9b21a9e746f921cefa4ee94c4c0a1c49c774f67f")

        XCTAssertEqual(try parsedEip712TypedData.encodeData("Person", data: (parsedEip712TypedData.message["to"] as! [[String : AnyObject]])[0]).toHexString(),
                       "fabfe1ed996349fc6027709802be19d047da1aa5d6894ff5f6486d92db2e686028cac318a86c8a0a6a9156c2dba2c8c2363677ba0514ef616592d81557e679b6d2734f4c86cc3bd9cabf04c3097589d3165d95e4648fc72d943ed161f651ec6d")
        XCTAssertEqual(try parsedEip712TypedData.structHash("Person", data: (parsedEip712TypedData.message["to"] as! [[String : AnyObject]])[0]).toHexString(),
                       "efa62530c7ae3a290f8a13a5fc20450bdb3a6af19d9d9d2542b5a94e631a9168")

        XCTAssertEqual(try parsedEip712TypedData.encodeType("Mail"),
                       "Mail(Person from,Person[] to,string contents)Person(string name,address[] wallets)")
        XCTAssertEqual(try parsedEip712TypedData.typeHash("Mail"),
                       "0x4bd8a9a2b93427bb184aca81e24beb30ffa3c747e2a33d4225ec08bf12e2e753")
        XCTAssertEqual(try parsedEip712TypedData.encodeData().toHexString(),
                       "4bd8a9a2b93427bb184aca81e24beb30ffa3c747e2a33d4225ec08bf12e2e7539b4846dd48b866f0ac54d61b9b21a9e746f921cefa4ee94c4c0a1c49c774f67fca322beec85be24e374d18d582a6f2997f75c54e7993ab5bc07404ce176ca7cdb5aadf3154a261abdd9086fc627b61efca26ae5702701d05cd2305f7c52a2fc8")
        XCTAssertEqual(try parsedEip712TypedData.structHash().toHexString(),
                       "eb4221181ff3f1a83ea7313993ca9218496e424604ba9492bb4052c03d5c3df8")
        XCTAssertEqual(try parsedEip712TypedData.structHash("EIP712Domain", data: parsedEip712TypedData.domain).toHexString(),
                       "f2cee375fa42b42143804025fc449deafd50cc031ca257e0b194a650a912090f")
        XCTAssertEqual(try parsedEip712TypedData.signHash().toHexString(),
                       "a85c2e2b118698e88db68a8105b794a8cc7cec074e89ef991cb4f5f533819cc2")

        let privateKey = Data.fromHex("cow".sha3(.keccak256).addHexPrefix())!
        let publicKey = Utilities.privateToPublic(privateKey)!
        let address = Utilities.publicToAddress(publicKey)!
        XCTAssertEqual(address, EthereumAddress("0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826"));
        let (compressedSignature, _) = try SECP256K1.signForRecovery(hash: parsedEip712TypedData.signHash(), privateKey: privateKey)
        XCTAssertEqual(compressedSignature!.toHexString(), "65cbd956f2fae28a601bebc9b906cea0191744bd4c4247bcd27cd08f8eb6b71c78efdf7a31dc9abee78f492292721f362d296cf86b4538e07b51303b67f749061b")
    }

    func testEIP712SignedTypedDataV4_differentPayload() throws {
        let rawPayload =
        """
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
                        "name":"mother",
                        "type":"Person"
                    },
                    {
                        "name":"father",
                        "type":"Person"
                    }
                ]
            },
            "domain":{
                "name":"Family Tree",
                "version":"1",
                "chainId":1,
                "verifyingContract":"0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"
            },
            "primaryType":"Person",
            "message":{
                "name":"Jon",
                "mother":{
                    "name":"Lyanna",
                    "father":{
                        "name":"Rickard"
                    }
                },
                "father":{
                    "name":"Rhaegar",
                    "father":{
                        "name":"Aeris II"
                    }
                }
            }
        }
        """

        let parsedEip712TypedData = try EIP712Parser.parse(rawPayload)

        XCTAssertEqual(try parsedEip712TypedData.encodeType("Person"), "Person(string name,Person mother,Person father)")
        XCTAssertEqual(try parsedEip712TypedData.typeHash("Person"), "0x7c5c8e90cb92c8da53b893b24962513be98afcf1b57b00327ae4cc14e3a64116")

        XCTAssertEqual(try parsedEip712TypedData.encodeData("Person", data: parsedEip712TypedData.message["mother"] as! [String : AnyObject]).toHexString(),
                       "7c5c8e90cb92c8da53b893b24962513be98afcf1b57b00327ae4cc14e3a64116afe4142a2b3e7b0503b44951e6030e0e2c5000ef83c61857e2e6003e7aef8570000000000000000000000000000000000000000000000000000000000000000088f14be0dd46a8ec608ccbff6d3923a8b4e95cdfc9648f0db6d92a99a264cb36")
        XCTAssertEqual(try parsedEip712TypedData.structHash("Person", data: parsedEip712TypedData.message["mother"] as! [String : AnyObject]).toHexString(),
                       "9ebcfbf94f349de50bcb1e3aa4f1eb38824457c99914fefda27dcf9f99f6178b")

        XCTAssertEqual(try parsedEip712TypedData.encodeData("Person", data: parsedEip712TypedData.message["father"] as! [String : AnyObject]).toHexString(),
                       "7c5c8e90cb92c8da53b893b24962513be98afcf1b57b00327ae4cc14e3a64116b2a7c7faba769181e578a391a6a6811a3e84080c6a3770a0bf8a856dfa79d333000000000000000000000000000000000000000000000000000000000000000002cc7460f2c9ff107904cff671ec6fee57ba3dd7decf999fe9fe056f3fd4d56e")
        XCTAssertEqual(try parsedEip712TypedData.structHash("Person", data: parsedEip712TypedData.message["father"] as! [String : AnyObject]).toHexString(),
                       "b852e5abfeff916a30cb940c4e24c43cfb5aeb0fa8318bdb10dd2ed15c8c70d8")

        XCTAssertEqual(try parsedEip712TypedData.encodeData(parsedEip712TypedData.primaryType, data: parsedEip712TypedData.message).toHexString(),
                       "7c5c8e90cb92c8da53b893b24962513be98afcf1b57b00327ae4cc14e3a64116e8d55aa98b6b411f04dbcf9b23f29247bb0e335a6bc5368220032fdcb9e5927f9ebcfbf94f349de50bcb1e3aa4f1eb38824457c99914fefda27dcf9f99f6178bb852e5abfeff916a30cb940c4e24c43cfb5aeb0fa8318bdb10dd2ed15c8c70d8")
        XCTAssertEqual(try parsedEip712TypedData.structHash(parsedEip712TypedData.primaryType, data: parsedEip712TypedData.message).toHexString(),
                       "fdc7b6d35bbd81f7fa78708604f57569a10edff2ca329c8011373f0667821a45")
        XCTAssertEqual(try parsedEip712TypedData.structHash("EIP712Domain", data: parsedEip712TypedData.domain).toHexString(),
                       "facb2c1888f63a780c84c216bd9a81b516fc501a19bae1fc81d82df590bbdc60")
        XCTAssertEqual(try parsedEip712TypedData.signHash().toHexString(),
                       "807773b9faa9879d4971b43856c4d60c2da15c6f8c062bd9d33afefb756de19c")

        let privateKey = Data.fromHex("dragon".sha3(.keccak256).addHexPrefix())!
        let publicKey = Utilities.privateToPublic(privateKey)!
        let address = Utilities.publicToAddress(publicKey)!
        XCTAssertEqual(address, EthereumAddress("0x065a687103c9f6467380bee800ecd70b17f6b72f"));
        let (compressedSignature, _) = try SECP256K1.signForRecovery(hash: parsedEip712TypedData.signHash(), privateKey: privateKey)
        XCTAssertEqual(compressedSignature!.toHexString(), "f2ec61e636ff7bb3ac8bc2a4cc2c8b8f635dd1b2ec8094c963128b358e79c85c5ca6dd637ed7e80f0436fe8fce39c0e5f2082c9517fe677cc2917dcd6c84ba881c")
    }

    /// This test makes sure that custom types are alphabetically ordered when encoded
    /// This test is built on thje following example: https://github.com/trustwallet/wallet-core/pull/2325/files
    /// Link to the GitHub issue https://github.com/trustwallet/wallet-core/issues/2323
    /// > According to the description of the issues it fixes (see the link above):
    /// > The type string is different from `metamask/eth-sig-util`
    /// > `type: OrderComponents(...)OfferItem(...)ConsiderationItem(...)`
    /// > `ConsiderationItem` should be in front of `OfferItem`
    ///
    /// The `InvalidOrderSignature` error is thrown when hash created for signing is invalid, thus, resulting in invalid signature.
    func testEIP712NoInvalidOrderSignature() throws {
        let rawPayload = """
        {
            "types": {
                "EIP712Domain": [
                    { "name": "name", "type": "string" },
                    { "name": "version", "type": "string" },
                    { "name": "chainId", "type": "uint256" },
                    { "name": "verifyingContract", "type": "address" }
                ],
                "OrderComponents": [
                    { "name": "offerer", "type": "address" },
                    { "name": "zone", "type": "address" },
                    { "name": "offer", "type": "OfferItem[]" },
                    { "name": "consideration", "type": "ConsiderationItem[]" },
                    { "name": "orderType", "type": "uint8" },
                    { "name": "startTime", "type": "uint256" },
                    { "name": "endTime", "type": "uint256" },
                    { "name": "zoneHash", "type": "bytes32" },
                    { "name": "salt", "type": "uint256" },
                    { "name": "conduitKey", "type": "bytes32" },
                    { "name": "counter", "type": "uint256" }
                ],
                "OfferItem": [
                    { "name": "itemType", "type": "uint8" },
                    { "name": "token", "type": "address" },
                    { "name": "identifierOrCriteria", "type": "uint256" },
                    { "name": "startAmount", "type": "uint256" },
                    { "name": "endAmount", "type": "uint256" }
                ],
                "ConsiderationItem": [
                    { "name": "itemType", "type": "uint8" },
                    { "name": "token", "type": "address" },
                    { "name": "identifierOrCriteria", "type": "uint256" },
                    { "name": "startAmount", "type": "uint256" },
                    { "name": "endAmount", "type": "uint256" },
                    { "name": "recipient", "type": "address" }
                ]
            },
            "primaryType": "OrderComponents",
            "domain": {
                "name": "Seaport",
                "version": "1.1",
                "chainId": "1",
                "verifyingContract": "0x00000000006c3852cbEf3e08E8dF289169EdE581"
            },
            "message": {
                "offerer": "0x7d8bf18C7cE84b3E175b339c4Ca93aEd1dD166F1",
                "offer": [
                    {
                        "itemType": "2",
                        "token": "0x3F53082981815Ed8142384EDB1311025cA750Ef1",
                        "identifierOrCriteria": "134",
                        "startAmount": "1",
                        "endAmount": "1"
                    }
                ],
                "orderType": "2",
                "consideration": [
                    {
                        "itemType": "0",
                        "token": "0x0000000000000000000000000000000000000000",
                        "identifierOrCriteria": "0",
                        "startAmount": "975000000000000000",
                        "endAmount": "975000000000000000",
                        "recipient": "0x7d8bf18C7cE84b3E175b339c4Ca93aEd1dD166F1"
                    },
                    {
                        "itemType": "0",
                        "token": "0x0000000000000000000000000000000000000000",
                        "identifierOrCriteria": "0",
                        "startAmount": "25000000000000000",
                        "endAmount": "25000000000000000",
                        "recipient": "0x8De9C5A032463C561423387a9648c5C7BCC5BC90"
                    }
                ],
                "startTime": "1655450129",
                "endTime": "1658042129",
                "zone": "0x004C00500000aD104D7DBd00e3ae0A5C00560C00",
                "zoneHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
                "salt": "795459960395409",
                "conduitKey": "0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000",
                "totalOriginalConsiderationItems": "2",
                "counter": "0"
            }
        }
        """

        let parsedPayload = try EIP712Parser.parse(rawPayload)
        try XCTAssertEqual(parsedPayload.signHash().toHexString(), "54140d99a864932cbc40fd8a2d1d1706c3923a79c183a3b151e929ac468064db")
    }

    /// A test to check payload encoding, specifically parsing and encoding of fields with "bytes" type.
    /// Given raw payload was failing with the following error:
    /// ```
    ///     EIP712Parser.
    ///     Type metadata 'EIP712TypeProperty(name: "data", type: "bytes", coreType: "bytes", isArray: false)'
    ///     and actual value
    ///     'Optional(0x000000000000000000000000e84a7676aae742770a179dd7431073429a88c7b8000000000000000000000000000000000000000000000000000000000000002c)'
    ///     type doesn't match.
    ///     Cannot cast value to Data.
    ///
    /// ```
    func testEIP712BytesEncoding() throws {
        let rawPayload = """
            {
            "message":{
                "takeAsset":{
                    "assetType":{
                        "assetClass":"0xaaaebeba",
                        "data":"0x"
                    },
                    "value":"2000000000000000000"
                },
                "data":"0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000d6ffd79b52a587a0a9941a61f4e6cb0d386d54580000000000000000000000000000000000000000000000000000000000000064",
                "dataType":"0x23d235ef",
                "maker":"0xd0727e8a578de9dd19bced635b1aa43576e638bc",
                "taker":"0x0000000000000000000000000000000000000000",
                "salt":"0x8f9761e56ed73b34d0cb184a2c5530d86c355c63c1cde8db1e0d2557d93f10d7",
                "end":1703058225,
                "makeAsset":{
                    "value":"1",
                    "assetType":{
                        "data":"0x000000000000000000000000e84a7676aae742770a179dd7431073429a88c7b8000000000000000000000000000000000000000000000000000000000000002c",
                        "assetClass":"0x73ad2146"
                    }
                },
                "start":0
            },
            "domain":{
                "verifyingContract":"0x02afbd43cad367fcb71305a2dfb9a3928218f0c1",
                "version":"2",
                "chainId":5,
                "name":"Exchange"
            },
            "primaryType":"Order",
            "types":{
                "Order":[
                    {
                        "type":"address",
                        "name":"maker"
                    },
                    {
                        "type":"Asset",
                        "name":"makeAsset"
                    },
                    {
                        "name":"taker",
                        "type":"address"
                    },
                    {
                        "name":"takeAsset",
                        "type":"Asset"
                    },
                    {
                        "name":"salt",
                        "type":"uint256"
                    },
                    {
                        "name":"start",
                        "type":"uint256"
                    },
                    {
                        "type":"uint256",
                        "name":"end"
                    },
                    {
                        "type":"bytes4",
                        "name":"dataType"
                    },
                    {
                        "type":"bytes",
                        "name":"data"
                    }
                ],
                "EIP712Domain":[
                    {
                        "name":"name",
                        "type":"string"
                    },
                    {
                        "type":"string",
                        "name":"version"
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
                "Asset":[
                    {
                        "name":"assetType",
                        "type":"AssetType"
                    },
                    {
                        "type":"uint256",
                        "name":"value"
                    }
                ],
                "AssetType":[
                    {
                        "type":"bytes4",
                        "name":"assetClass"
                    },
                    {
                        "name":"data",
                        "type":"bytes"
                    }
                ]
            }
            }
            """

        let parsedPayload = try EIP712Parser.parse(rawPayload)
        try XCTAssertEqual(parsedPayload.signHash().toHexString(), "95625b9843950aa6cdd50c703e2bf0bdaa5ddeef9842d5839a81d927b7159637")
    }
}
