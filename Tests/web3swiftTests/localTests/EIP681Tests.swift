//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import BigInt
import Web3Core

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
        case .ensAddress:
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
        case .ensAddress:
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
        case .ensAddress:
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
        case .ensAddress:
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
        let eip681Code = await Web3.EIP681CodeParser.parse("ethereum:\(testAddress)@1/transfer?address=somename.eth&uint256=1")
        XCTAssert(eip681Code != nil)
        guard let eip681Code = eip681Code else { return }
        switch eip681Code.targetAddress {
        case .ethereumAddress:
            fatalError("Returned target address cannot be EthereumAddress. It must be ENS address.")
        case .ensAddress(let address):
            XCTAssertEqual(address, testAddress)
        }

        guard eip681Code.parameters.count > 1 else {
            XCTFail("'eip681Code.parameters.count' must be at least 2.")
            return
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
        let eip681Code = await Web3.EIP681CodeParser.parse("ethereum:\(testAddress)@1/transfer?address=somename.eth&uint256=1".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        XCTAssert(eip681Code != nil)
        guard let eip681Code = eip681Code else { return }
        switch eip681Code.targetAddress {
        case .ethereumAddress:
            fatalError("Returned target address cannot be EthereumAddress. It must be ENS address.")
        case .ensAddress(let address):
            XCTAssertEqual(address, testAddress)
        }

        guard eip681Code.parameters.count > 1 else {
            XCTFail("'eip681Code.parameters.count' must be at least 2.")
            return
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
        case .ensAddress:
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
        case .ensAddress:
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
        case .ensAddress:
            fatalError("Returned target address cannot be ENS address. It must be EthereumAddress.")
        }

        XCTAssertEqual(eip681Code.functionName, "functionName123")
        XCTAssertEqual(eip681Code.function!.signature, "functionName123(int256[])")
        XCTAssertEqual(eip681Code.chainID, chainID)

        XCTAssertEqual(eip681Code.parameters[0].type, .array(type: .int(bits: 256), length: 0))
        let data = eip681Code.parameters[0].value as? [BigInt]
        XCTAssertEqual(data, [BigInt](arrayLiteral: 1, 2, 5000, 3, 4, 10000))
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
        case .ensAddress:
            fatalError("Returned target address cannot be ENS address. It must be EthereumAddress.")
        }

        XCTAssertEqual(eip681Code.functionName, "functionName123")
        XCTAssertEqual(eip681Code.function!.signature, "functionName123(int256[3])")
        XCTAssertEqual(eip681Code.chainID, chainID)

        XCTAssertEqual(eip681Code.parameters[0].type, .array(type: .int(bits: 256), length: 3))
        let data = eip681Code.parameters[0].value as? [BigInt]
        XCTAssertEqual(data, [BigInt](arrayLiteral: 1, 2, 5000))
    }

    func testParsingQueryParameterFixedLengthArray() async throws {
        /// Declared `int256[3]` with 2 values instead of expected 3.
        var eip681Code = await Web3.EIP681CodeParser.parse("ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc@2828/functionName123?int256[3]=[1,2]")
        XCTAssert(eip681Code != nil)
        XCTAssert(eip681Code?.parameters.count == 0)
        /// Declared `int256[3]` with 4 values instead of expected 3.
        eip681Code = await Web3.EIP681CodeParser.parse("ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc@2828/functionName123?int256[3]=[1,2,2,3]")
        XCTAssert(eip681Code != nil)
        XCTAssert(eip681Code?.parameters.count == 0)
    }

    func testParsingQueryParameterStringsArray() async throws {
        var eip681Code = await Web3.EIP681CodeParser.parse("ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc@2828/functionName123?string[]=[\"123\",\"2,5000\",\"wwweer2-=!\"]")
        XCTAssert(eip681Code != nil)
        guard eip681Code != nil else { return }

        XCTAssertEqual(eip681Code!.parameters[0].type, .array(type: .string, length: 0))
        var data = eip681Code!.parameters[0].value as? [String]
        XCTAssertEqual(data, ["123", "2,5000", "wwweer2-=!"])

        eip681Code = await Web3.EIP681CodeParser.parse("ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc@2828/functionName123?string[]=[123,2,5000,wwweer2-=!]")
        XCTAssert(eip681Code != nil)
        guard eip681Code != nil else { return }

        XCTAssertEqual(eip681Code!.parameters[0].type, .array(type: .string, length: 0))
        data = eip681Code!.parameters[0].value as? [String]
        XCTAssertEqual(data, ["123", "2", "5000", "wwweer2-=!"])
    }

    func testParsingQueryParameterArrayOfStringsArrays() async throws {
        var eip681Code = await Web3.EIP681CodeParser.parse("ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc@2828/functionName123?string[][]=[[\"123\",\"2,5000\",\"wwweer2-=!\"],[\"test1\",\"demo\"]]")
        XCTAssert(eip681Code != nil)
        guard eip681Code != nil else { return }

        XCTAssertEqual(eip681Code!.parameters[0].type, .array(type: .array(type: .string, length: 0), length: 0))
        var data = eip681Code!.parameters[0].value as? [[String]]
        XCTAssertEqual(data?[0], ["123", "2,5000", "wwweer2-=!"])
        XCTAssertEqual(data?[1], ["test1", "demo"])

        eip681Code = await Web3.EIP681CodeParser.parse("ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc@2828/functionName123?string[][]=[[123,2,5000,wwweer2-=!],[test1,demo]]")
        XCTAssert(eip681Code != nil)
        guard eip681Code != nil else { return }

        XCTAssertEqual(eip681Code!.parameters[0].type, .array(type: .array(type: .string, length: 0), length: 0))
        data = eip681Code!.parameters[0].value as? [[String]]
        XCTAssertEqual(data?[0], ["123", "2", "5000", "wwweer2-=!"])
        XCTAssertEqual(data?[1], ["test1", "demo"])
    }

    func testMakeEIP681Link() async throws {
        var eip681Link = Web3.EIP681Code(Web3.EIP681Code.TargetAddress.ethereumAddress(EthereumAddress("0x9aBbDB06A61cC686BD635484439549D45c2449cc")!))

        eip681Link.functionName = "setData"
        eip681Link.parameters = [Web3.EIP681Code.EIP681Parameter(type: .array(type: .bytes(length: 32), length: 0),
                                                                 value: [Data.fromHex("0x1234789565875498655487123478956587549865548712347895658754980000")!,
                                                                         Data.fromHex("0x1234789565875498655487123478956587549865548712347895658754986554")!]),
                                 Web3.EIP681Code.EIP681Parameter(type: .array(type: .dynamicBytes, length: 0),
                                                                 value: [Data.fromHex("0x12345607")!,
                                                                         Data.fromHex("0x8965abcdef")!]),
                                 Web3.EIP681Code.EIP681Parameter(type: .uint(bits: 256),
                                                                 value: 98986565),
                                 Web3.EIP681Code.EIP681Parameter(type: .int(bits: 256),
                                                                 value: 155445566),
                                 Web3.EIP681Code.EIP681Parameter(type: .address,
                                                                 value: EthereumAddress("0x9aBbDB06A61cC686BD635484439549D45c2449cc")!),
                                 Web3.EIP681Code.EIP681Parameter(type: .bytes(length: 5),
                                                                 value: "0x9aBbDB06A6"),
                                 Web3.EIP681Code.EIP681Parameter(type: .bytes(length: 3),
                                                                 value: Data.fromHex("0x9aBbDB")!),
                                 Web3.EIP681Code.EIP681Parameter(type: .dynamicBytes,
                                                                 value: Data.fromHex("0x11009aBbDB87879898656545")!),
                                 Web3.EIP681Code.EIP681Parameter(type: .string,
                                                                 value: "this is EIP681 query parameter string")]

        let unencodedResult =  "ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc/setData?bytes32[]=[0x1234789565875498655487123478956587549865548712347895658754980000,0x1234789565875498655487123478956587549865548712347895658754986554]&bytes[]=[0x12345607,0x8965abcdef]&uint256=98986565&int256=155445566&address=0x9aBbDB06A61cC686BD635484439549D45c2449cc&bytes5=0x9abbdb06a6&bytes3=0x9abbdb&bytes=0x11009abbdb87879898656545&string=this is EIP681 query parameter string"

        XCTAssertEqual(eip681Link.makeEIP681Link(), unencodedResult)
        let encodedOutputLink = eip681Link.makeEIP681Link(urlEncode: true)
        XCTAssertEqual(encodedOutputLink, unencodedResult.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        XCTAssertNotNil(encodedOutputLink)
        XCTAssertNotNil(URL(string: encodedOutputLink ?? ""))
    }
}
