//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import BigInt
import Core

@testable import web3swift

class EIP681Tests: XCTestCase {

    func testParsing() async throws {
        let testAddress = "0x5ffc014343cd971b7eb70732021e26c35b744cc4"
        let eip681Code = await Web3.EIP681CodeParser.parse("ethereum:\(testAddress)?value=2.014e18")
        XCTAssert(eip681Code != nil)
        guard let eip681Code = eip681Code else { return }
        switch eip681Code.targetAddress {
        case .ethereumAddress(let address):
            XCTAssertEqual(address.address.lowercased(), testAddress)
        case .ensAddress(_):
            fatalError("Returned target address cannot be ENS address. It must be EthereumAddress.")
        }

        XCTAssertEqual(eip681Code.amount, BigUInt(2014000000000000000))
    }

    func testParsingWithEncoding() async throws {
        let testAddress = "0x5ffc014343cd971b7eb70732021e26c35b744cc4"
        let eip681Code = await Web3.EIP681CodeParser.parse("ethereum:\(testAddress)?value=2.014e18".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        XCTAssert(eip681Code != nil)
        guard let eip681Code = eip681Code else { return }
        switch eip681Code.targetAddress {
        case .ethereumAddress(let address):
            XCTAssertEqual(address.address.lowercased(), testAddress)
        case .ensAddress(_):
            fatalError("Returned target address cannot be ENS address. It must be EthereumAddress.")
        }
        XCTAssertEqual(eip681Code.amount, BigUInt(2014000000000000000))
    }

    func testParsing2() async throws {
        let testAddress = "0x8932404A197D84Ec3Ea55971AADE11cdA1dddff1"
        let eip681Code = await Web3.EIP681CodeParser.parse("ethereum:\(testAddress)/transfer?address=0x6891dC3962e710f0ff711B9c6acc26133Fd35Cb4&uint256=1")
        XCTAssert(eip681Code != nil)
        guard let eip681Code = eip681Code else { return }
        switch eip681Code.targetAddress {
        case .ethereumAddress(let address):
            XCTAssertEqual(address.address, testAddress)
        case .ensAddress(_):
            fatalError("Returned target address cannot be ENS address. It must be EthereumAddress.")
        }

        XCTAssertEqual(eip681Code.functionName, "transfer")
        XCTAssertEqual(eip681Code.parameters[0].type, .address)
        XCTAssertEqual(eip681Code.parameters[1].type, .uint(bits: 256))
        XCTAssertEqual(eip681Code.parameters[0].value as? EthereumAddress,
                       EthereumAddress("0x6891dC3962e710f0ff711B9c6acc26133Fd35Cb4"))
        XCTAssertEqual(eip681Code.parameters[1].value as? BigUInt, BigUInt(1))
    }

    func testParsing2WithEncoding() async throws {
        let testAddress = "0x8932404A197D84Ec3Ea55971AADE11cdA1dddff1"
        let eip681Code = await Web3.EIP681CodeParser.parse("ethereum:\(testAddress)/transfer?address=0x6891dC3962e710f0ff711B9c6acc26133Fd35Cb4&uint256=1"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        XCTAssert(eip681Code != nil)
        guard let eip681Code = eip681Code else { return }
        switch eip681Code.targetAddress {
        case .ethereumAddress(let address):
            XCTAssertEqual(address.address, testAddress)
        case .ensAddress(_):
            fatalError("Returned target address cannot be ENS address. It must be EthereumAddress.")
        }

        XCTAssertEqual(eip681Code.functionName, "transfer")
        XCTAssertEqual(eip681Code.parameters[0].type, .address)
        XCTAssertEqual(eip681Code.parameters[1].type, .uint(bits: 256))
        XCTAssertEqual(eip681Code.parameters[0].value as? EthereumAddress,
                       EthereumAddress("0x6891dC3962e710f0ff711B9c6acc26133Fd35Cb4"))
        XCTAssertEqual(eip681Code.parameters[1].value as? BigUInt, BigUInt(1))
    }

    func testENSParsing() async throws {
        let testAddress = "somename.eth"
        let eip681Code = await Web3.EIP681CodeParser.parse("ethereum:\(testAddress)/transfer?address=somename.eth&uint256=1")
        XCTAssert(eip681Code != nil)
        guard let eip681Code = eip681Code else { return }
        switch eip681Code.targetAddress {
        case .ethereumAddress(_):
            fatalError("Returned target address cannot be EthereumAddress. It must be ENS address.")
        case .ensAddress(let address):
            XCTAssertEqual(address, testAddress)
        }

        XCTAssertEqual(eip681Code.functionName, "transfer")
        XCTAssertEqual(eip681Code.parameters[0].type, .address)
        /// `eip681Code.parameters[0].value` is not checked as it's fetched from remote and is unknown.
        /// `eip681Code.parameters[0].value` must contain some `EthereumAddress`
        // DO NOT UNCOMMENT, unless you know the exact returned value beforehand.
        // XCTAssertEqual(eip681Code.parameters[0].value as? String, EthereumAddress(...))
        XCTAssertEqual(eip681Code.parameters[1].type, .uint(bits: 256))
        XCTAssertEqual(eip681Code.parameters[1].value as? BigUInt, BigUInt(1))
    }

    func testENSParsingWithEncoding() async throws {
        let testAddress = "somename.eth"
        let eip681Code = await Web3.EIP681CodeParser.parse("ethereum:\(testAddress)/transfer?address=somename.eth&uint256=1".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        XCTAssert(eip681Code != nil)
        guard let eip681Code = eip681Code else { return }
        switch eip681Code.targetAddress {
        case .ethereumAddress(_):
            fatalError("Returned target address cannot be EthereumAddress. It must be ENS address.")
        case .ensAddress(let address):
            XCTAssertEqual(address, testAddress)
        }

        XCTAssertEqual(eip681Code.functionName, "transfer")
        XCTAssertEqual(eip681Code.parameters[0].type, .address)
        /// `eip681Code.parameters[0].value` is not checked as it's fetched from remote and is unknown.
        /// `eip681Code.parameters[0].value` must contain some `EthereumAddress`
        // DO NOT UNCOMMENT, unless you know the exact returned value beforehand.
        // XCTAssertEqual(eip681Code.parameters[0].value as? String, EthereumAddress(...))
        XCTAssertEqual(eip681Code.parameters[1].type, .uint(bits: 256))
        XCTAssertEqual(eip681Code.parameters[1].value as? BigUInt, BigUInt(1))
    }

    func testParsingOfArrayOfBytesAsParameter() async throws {
        let testAddress = "0x9aBbDB06A61cC686BD635484439549D45c2449cc"
        let chainID = BigUInt(2828)
        let eip681Code = await Web3.EIP681CodeParser.parse("ethereum:\(testAddress)@\(chainID.description)/setData?bytes32[]=[0x4b80742de2bf82acb3630000005e9F5BB83481d5627aA8c48527C174579bC428,0xdf30dba06db6a30e65354d9a64c609861f089545ca58c6b4dbe31a5f338cb0e3,0xdf30dba06db6a30e65354d9a64c6098600000000000000000000000000000004]&bytes[]=[0x0000000000000000000000000000000000000000000000000000000000000038,0x0000000000000000000000000000000000000000000000000000000000000004,0x005e9F5BB83481d5627aA8c48527C174579bC428]")
        XCTAssert(eip681Code != nil)
        guard let eip681Code = eip681Code else { return }
        switch eip681Code.targetAddress {
        case .ethereumAddress(let address):
            XCTAssertEqual(address.address, testAddress)
        case .ensAddress(_):
            fatalError("Returned target address cannot be ENS address. It must be EthereumAddress.")
        }

        XCTAssertEqual(eip681Code.functionName, "setData")
        XCTAssertEqual(eip681Code.function!.signature, "setData(bytes32[],bytes[])")
        XCTAssertEqual(eip681Code.chainID, chainID)
        XCTAssertEqual(eip681Code.parameters[0].type, .array(type: .bytes(length: 32), length: 0))

        var data = eip681Code.parameters[0].value as? [Data]
        XCTAssertEqual(data?[0], Data.fromHex("0x4b80742de2bf82acb3630000005e9F5BB83481d5627aA8c48527C174579bC428")!)
        XCTAssertEqual(data?[1], Data.fromHex("0xdf30dba06db6a30e65354d9a64c609861f089545ca58c6b4dbe31a5f338cb0e3")!)
        XCTAssertEqual(data?[2], Data.fromHex("0xdf30dba06db6a30e65354d9a64c6098600000000000000000000000000000004")!)

        XCTAssertEqual(eip681Code.parameters[1].type, .array(type: .dynamicBytes, length: 0))
        data = eip681Code.parameters[1].value as? [Data]
        XCTAssertEqual(data?[0], Data.fromHex("0x0000000000000000000000000000000000000000000000000000000000000038")!)
        XCTAssertEqual(data?[1], Data.fromHex("0x0000000000000000000000000000000000000000000000000000000000000004")!)
        XCTAssertEqual(data?[2], Data.fromHex("0x005e9F5BB83481d5627aA8c48527C174579bC428")!)
    }

    func testParsingOfArrayOfBytesAsParameterWithEncoding() async throws {
        let testAddress = "0x9aBbDB06A61cC686BD635484439549D45c2449cc"
        let chainID = BigUInt(2828)
        let eip681Code = await Web3.EIP681CodeParser.parse("ethereum:\(testAddress)@\(chainID.description)/setData?bytes32[]=[0x4b80742de2bf82acb3630000005e9F5BB83481d5627aA8c48527C174579bC428,0xdf30dba06db6a30e65354d9a64c609861f089545ca58c6b4dbe31a5f338cb0e3,0xdf30dba06db6a30e65354d9a64c6098600000000000000000000000000000004]&bytes[]=[0x0000000000000000000000000000000000000000000000000000000000000038,0x0000000000000000000000000000000000000000000000000000000000000004,0x005e9F5BB83481d5627aA8c48527C174579bC428]".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        XCTAssert(eip681Code != nil)
        guard let eip681Code = eip681Code else { return }
        switch eip681Code.targetAddress {
        case .ethereumAddress(let address):
            XCTAssertEqual(address.address, testAddress)
        case .ensAddress(_):
            fatalError("Returned target address cannot be ENS address. It must be EthereumAddress.")
        }

        XCTAssertEqual(eip681Code.functionName, "setData")
        XCTAssertEqual(eip681Code.function!.signature, "setData(bytes32[],bytes[])")
        XCTAssertEqual(eip681Code.chainID, chainID)

        XCTAssertEqual(eip681Code.parameters[0].type, .array(type: .bytes(length: 32), length: 0))
        var data = eip681Code.parameters[0].value as? [Data]
        XCTAssertEqual(data?[0], Data.fromHex("0x4b80742de2bf82acb3630000005e9F5BB83481d5627aA8c48527C174579bC428")!)
        XCTAssertEqual(data?[1], Data.fromHex("0xdf30dba06db6a30e65354d9a64c609861f089545ca58c6b4dbe31a5f338cb0e3")!)
        XCTAssertEqual(data?[2], Data.fromHex("0xdf30dba06db6a30e65354d9a64c6098600000000000000000000000000000004")!)

        XCTAssertEqual(eip681Code.parameters[1].type, .array(type: .dynamicBytes, length: 0))
        data = eip681Code.parameters[1].value as? [Data]
        XCTAssertEqual(data?[0], Data.fromHex("0x0000000000000000000000000000000000000000000000000000000000000038")!)
        XCTAssertEqual(data?[1], Data.fromHex("0x0000000000000000000000000000000000000000000000000000000000000004")!)
        XCTAssertEqual(data?[2], Data.fromHex("0x005e9F5BB83481d5627aA8c48527C174579bC428")!)
    }

    func testParsingOfArrayOfIntAsParameter() async throws {
        let testAddress = "0x9aBbDB06A61cC686BD635484439549D45c2449cc"
        let chainID = BigUInt(2828)
        let eip681Code = await Web3.EIP681CodeParser.parse("ethereum:\(testAddress)@\(chainID.description)/functionName123?int256[]=[1,2,5000,3,4,10000]")
        XCTAssert(eip681Code != nil)
        guard let eip681Code = eip681Code else { return }
        switch eip681Code.targetAddress {
        case .ethereumAddress(let address):
            XCTAssertEqual(address.address, testAddress)
        case .ensAddress(_):
            fatalError("Returned target address cannot be ENS address. It must be EthereumAddress.")
        }

        XCTAssertEqual(eip681Code.functionName, "functionName123")
        XCTAssertEqual(eip681Code.function!.signature, "functionName123(int256[])")
        XCTAssertEqual(eip681Code.chainID, chainID)

        XCTAssertEqual(eip681Code.parameters[0].type, .array(type: .int(bits: 256), length: 0))
        let data = eip681Code.parameters[0].value as? [BigInt]
        XCTAssertEqual(data, Array<BigInt>(arrayLiteral: 1, 2, 5000, 3, 4, 10000))
    }

    func testParsingOfArrayOfIntOfFixedLengthAsParameter() async throws {
        let testAddress = "0x9aBbDB06A61cC686BD635484439549D45c2449cc"
        let chainID = BigUInt(2828)
        let eip681Code = await Web3.EIP681CodeParser.parse("ethereum:\(testAddress)@\(chainID.description)/functionName123?int256[3]=[1,2,5000]")
        XCTAssert(eip681Code != nil)
        guard let eip681Code = eip681Code else { return }
        switch eip681Code.targetAddress {
        case .ethereumAddress(let address):
            XCTAssertEqual(address.address, testAddress)
        case .ensAddress(_):
            fatalError("Returned target address cannot be ENS address. It must be EthereumAddress.")
        }

        XCTAssertEqual(eip681Code.functionName, "functionName123")
        XCTAssertEqual(eip681Code.function!.signature, "functionName123(int256[3])")
        XCTAssertEqual(eip681Code.chainID, chainID)

        XCTAssertEqual(eip681Code.parameters[0].type, .array(type: .int(bits: 256), length: 3))
        let data = eip681Code.parameters[0].value as? [BigInt]
        XCTAssertEqual(data, Array<BigInt>(arrayLiteral: 1, 2, 5000))
    }

    func testParsingQueryParameterStringsArray() async throws {
        var eip681Code = await Web3.EIP681CodeParser.parse("ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc@2828/functionName123?string[]=[\"123\",\"2,5000\",\"wwweer2-=!\"]")
        XCTAssert(eip681Code != nil)
        guard eip681Code != nil else { return }

        XCTAssertEqual(eip681Code!.parameters[0].type, .array(type: .string, length: 0))
        var data = eip681Code!.parameters[0].value as? [String]
        XCTAssertEqual(data, ["123","2,5000","wwweer2-=!"])

        eip681Code = await Web3.EIP681CodeParser.parse("ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc@2828/functionName123?string[]=[123,2,5000,wwweer2-=!]")
        XCTAssert(eip681Code != nil)
        guard eip681Code != nil else { return }

        XCTAssertEqual(eip681Code!.parameters[0].type, .array(type: .string, length: 0))
        data = eip681Code!.parameters[0].value as? [String]
        XCTAssertEqual(data, ["123","2","5000","wwweer2-=!"])
    }

    func testParsingQueryParameterArrayOfStringsArrays() async throws {
        var eip681Code = await Web3.EIP681CodeParser.parse("ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc@2828/functionName123?string[][]=[[\"123\",\"2,5000\",\"wwweer2-=!\"],[\"test1\",\"demo\"]]")
        XCTAssert(eip681Code != nil)
        guard eip681Code != nil else { return }

        XCTAssertEqual(eip681Code!.parameters[0].type, .array(type: .array(type: .string, length: 0), length: 0))
        var data = eip681Code!.parameters[0].value as? [[String]]
        XCTAssertEqual(data?[0], ["123","2,5000","wwweer2-=!"])
        XCTAssertEqual(data?[1], ["test1","demo"])

        eip681Code = await Web3.EIP681CodeParser.parse("ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc@2828/functionName123?string[][]=[[123,2,5000,wwweer2-=!],[test1,demo]]")
        XCTAssert(eip681Code != nil)
        guard eip681Code != nil else { return }

        XCTAssertEqual(eip681Code!.parameters[0].type, .array(type: .array(type: .string, length: 0), length: 0))
        data = eip681Code!.parameters[0].value as? [[String]]
        XCTAssertEqual(data?[0], ["123","2","5000","wwweer2-=!"])
        XCTAssertEqual(data?[1], ["test1","demo"])
    }

    func testMakeEIP681Link() async throws {
        var eip681Link = Web3.EIP681Code(Web3.EIP681Code.TargetAddress.ethereumAddress(EthereumAddress("0x9aBbDB06A61cC686BD635484439549D45c2449cc")!))

        eip681Link.functionName = "setData"
        eip681Link.parameters = [Web3.EIP681Code.EIP681Parameter(type: .array(type: .bytes(length: 32), length: 0),
                                                                 value: [Data.fromHex("0x1234789565875498655487123478956587549865548712347895658754980000")!,
                                                                         Data.fromHex("0x1234789565875498655487123478956587549865548712347895658754986554")!] as AnyObject),
                                 Web3.EIP681Code.EIP681Parameter(type: .array(type: .dynamicBytes, length: 0),
                                                                 value: [Data.fromHex("0x12345607")!,
                                                                         Data.fromHex("0x8965abcdef")!] as AnyObject),
                                 Web3.EIP681Code.EIP681Parameter(type: .uint(bits: 256),
                                                                 value: 98986565 as AnyObject),
                                 Web3.EIP681Code.EIP681Parameter(type: .int(bits: 256),
                                                                 value: 155445566 as AnyObject),
                                 Web3.EIP681Code.EIP681Parameter(type: .address,
                                                                 value: EthereumAddress("0x9aBbDB06A61cC686BD635484439549D45c2449cc")! as AnyObject),
                                 Web3.EIP681Code.EIP681Parameter(type: .bytes(length: 5),
                                                                 value: "0x9aBbDB06A6" as AnyObject),
                                 Web3.EIP681Code.EIP681Parameter(type: .bytes(length: 3),
                                                                 value: Data.fromHex("0x9aBbDB")! as AnyObject),
                                 Web3.EIP681Code.EIP681Parameter(type: .dynamicBytes,
                                                                 value: Data.fromHex("0x11009aBbDB87879898656545")! as AnyObject),
                                 Web3.EIP681Code.EIP681Parameter(type: .string,
                                                                 value: "this is EIP681 query parameter string" as AnyObject)]

        let unencodedResult =  "ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc/setData?bytes32[]=[0x1234789565875498655487123478956587549865548712347895658754980000,0x1234789565875498655487123478956587549865548712347895658754986554]&bytes[]=[0x12345607,0x8965abcdef]&uint256=98986565&int256=155445566&address=0x9aBbDB06A61cC686BD635484439549D45c2449cc&bytes5=0x9abbdb06a6&bytes3=0x9abbdb&bytes=0x11009abbdb87879898656545&string=this is EIP681 query parameter string"

        XCTAssertEqual(eip681Link.makeEIP681Link(), unencodedResult)
        let encodedOutputLink = eip681Link.makeEIP681Link(urlEncode: true)
        XCTAssertEqual(encodedOutputLink, unencodedResult.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        XCTAssertNotNil(encodedOutputLink)
        XCTAssertNotNil(URL(string: encodedOutputLink ?? ""))
    }


    func testEIP681ParsingArraysWithWhitespacesIn() async throws {
        /// This link is constructed in a way that it holds whitespace characters in query parameters in places where
        /// no such characters should be placed. But it must be decoded correctly.
        let rawLink = "ethereum:0xAfbd9b509d98a69F8de31932c97CD35bb809CC50@2828/setData?bytes32[]=[0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47 , 0x4b80742de2bf82acb3630000ba99930e9e0bfd77cdc70f9b9656cecc2869e31a  ,      0x4b80742de2bf82acb363000090c650d2c6c5b796c6342118867cbf91f51d8135 , 0xdf30dba06db6a30e65354d9a64c609861f089545ca58c6b4dbe31a5f338cb0e3  ,    0xdf30dba06db6a30e65354d9a64c6098600000000000000000000000000000000 , 0xdf30dba06db6a30e65354d9a64c6098600000000000000000000000000000001     , 0xdf30dba06db6a30e65354d9a64c6098600000000000000000000000000000002 , 0x4b80742de2bf82acb3630000254bfe7e25184f72df435b5a9da39db6089dcaf5 , 0x5ef83ad9559033e6e941db7d7c495acdce616347d28e90c7ce47cbfcfcad3bc5]&bytes[]=[0x90c650d2c6c5b796c6342118867cbf91f51d8135 , 0x0000000000000000000000000000000000000000000000000000000000003fbf , 0x0000000000000000000000000000000000000000000000000000000000000008 , 0x0000000000000000000000000000000000000000000000000000000000000003 , 0xba99930e9e0bfd77cdc70f9b9656cecc2869e31a , 0x90c650d2c6c5b796c6342118867cbf91f51d8135 , 0x254bfe7e25184f72df435b5a9da39db6089dcaf5 , 0x0000000000000000000000000000000000000000000000000000000000003fbf , 0x6f357c6a0f079fb3a680e3b3ef2f154772df5f6d345bc052ad733a69bba326f363b6cc30697066733a2f2f516d5042485a4c45686d624c57594e374575505a334b437a735663595a53797544596a59506a7a523342706b6934]"
        let eip681Code = await Web3.EIP681CodeParser.parse(rawLink)
        XCTAssert(eip681Code != nil)
        guard let eip681Code = eip681Code else { return }

        let keys = eip681Code.parameters[0].value as? [Data]
        let values = eip681Code.parameters[1].value as? [Data]
        XCTAssertNotNil(keys)
        XCTAssertNotNil(values)

        guard let keys = keys,
              let values = values else { return }

        XCTAssertEqual(keys[0].toHexString().addHexPrefix(),"0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47")
        XCTAssertEqual(keys[1].toHexString().addHexPrefix(),"0x4b80742de2bf82acb3630000ba99930e9e0bfd77cdc70f9b9656cecc2869e31a")
        XCTAssertEqual(keys[2].toHexString().addHexPrefix(),"0x4b80742de2bf82acb363000090c650d2c6c5b796c6342118867cbf91f51d8135")
        XCTAssertEqual(keys[3].toHexString().addHexPrefix(),"0xdf30dba06db6a30e65354d9a64c609861f089545ca58c6b4dbe31a5f338cb0e3")
        XCTAssertEqual(keys[4].toHexString().addHexPrefix(), "0xdf30dba06db6a30e65354d9a64c6098600000000000000000000000000000000")
        XCTAssertEqual(keys[5].toHexString().addHexPrefix(), "0xdf30dba06db6a30e65354d9a64c6098600000000000000000000000000000001")
        XCTAssertEqual(keys[6].toHexString().addHexPrefix(), "0xdf30dba06db6a30e65354d9a64c6098600000000000000000000000000000002")
        XCTAssertEqual(keys[7].toHexString().addHexPrefix(), "0x4b80742de2bf82acb3630000254bfe7e25184f72df435b5a9da39db6089dcaf5")
        XCTAssertEqual(keys[8].toHexString().addHexPrefix(), "0x5ef83ad9559033e6e941db7d7c495acdce616347d28e90c7ce47cbfcfcad3bc5")

        XCTAssertEqual(values[0].toHexString().addHexPrefix(), "0x90c650d2c6c5b796c6342118867cbf91f51d8135")
        XCTAssertEqual(values[1].toHexString().addHexPrefix(), "0x0000000000000000000000000000000000000000000000000000000000003fbf")
        XCTAssertEqual(values[2].toHexString().addHexPrefix(), "0x0000000000000000000000000000000000000000000000000000000000000008")
        XCTAssertEqual(values[3].toHexString().addHexPrefix(), "0x0000000000000000000000000000000000000000000000000000000000000003")
        XCTAssertEqual(values[4].toHexString().addHexPrefix(), "0xba99930e9e0bfd77cdc70f9b9656cecc2869e31a")
        XCTAssertEqual(values[5].toHexString().addHexPrefix(), "0x90c650d2c6c5b796c6342118867cbf91f51d8135")
        XCTAssertEqual(values[6].toHexString().addHexPrefix(), "0x254bfe7e25184f72df435b5a9da39db6089dcaf5")
        XCTAssertEqual(values[7].toHexString().addHexPrefix(), "0x0000000000000000000000000000000000000000000000000000000000003fbf")
        XCTAssertEqual(values[8].toHexString().addHexPrefix(), "0x6f357c6a0f079fb3a680e3b3ef2f154772df5f6d345bc052ad733a69bba326f363b6cc30697066733a2f2f516d5042485a4c45686d624c57594e374575505a334b437a735663595a53797544596a59506a7a523342706b6934")
    }

    /// Query string has a variable of type `int256[3]` that expects 3 elements set as value but instead it gets 4.
    /// Parsing must fail for the following reasons:
    ///  - we assume that function in the link expects a certian set of arguments of certain types without which calling it woulf fail;
    ///  - if arguments of expected types are provided but values for them are invalid - function call will fail as well;
    ///  - if parsing of at least one argument has failed - function call will fail as well;
    /// If we are parsing EIP681 that has a function call encoded in it the link must be completely valid.
    /// It's not possible to guarantee the expected behaviour during execution of this transaction call if at least on of the query
    /// key-value pairs is invalid.
    func testWrongArraySize() async throws {
        let wrongEip681Link = "ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc@2828/functionName123?int256[3]=[1,2,2,3]"
        let eip681Code = await Web3.EIP681CodeParser.parse(wrongEip681Link)
        XCTAssertNil(eip681Code)
    }
}
