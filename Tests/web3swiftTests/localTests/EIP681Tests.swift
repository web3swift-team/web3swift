//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import BigInt

@testable import web3swift

class EIP681Tests: LocalTestCase {

    func testParsing() throws {
        let testAddress = "0x5ffc014343cd971b7eb70732021e26c35b744cc4"
        let eip681Code = Web3.EIP681CodeParser.parse("ethereum:\(testAddress)?value=2.014e18")
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

    func testParsingWithEncoding() throws {
        let testAddress = "0x5ffc014343cd971b7eb70732021e26c35b744cc4"
        let eip681Code = Web3.EIP681CodeParser.parse("ethereum:\(testAddress)?value=2.014e18".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
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

    func testParsing2() throws {
        let testAddress = "0x8932404A197D84Ec3Ea55971AADE11cdA1dddff1"
        let eip681Code = Web3.EIP681CodeParser.parse("ethereum:\(testAddress)/transfer?address=0x6891dC3962e710f0ff711B9c6acc26133Fd35Cb4&uint256=1")
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

    func testParsing2WithEncoding() throws {
        let testAddress = "0x8932404A197D84Ec3Ea55971AADE11cdA1dddff1"
        let eip681Code = Web3.EIP681CodeParser.parse("ethereum:\(testAddress)/transfer?address=0x6891dC3962e710f0ff711B9c6acc26133Fd35Cb4&uint256=1"
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

    func testENSParsing() throws {
        let testAddress = "somename.eth"
        let eip681Code = Web3.EIP681CodeParser.parse("ethereum:\(testAddress)/transfer?address=somename.eth&uint256=1")
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

    func testENSParsingWithEncoding() throws {
        let testAddress = "somename.eth"
        let eip681Code = Web3.EIP681CodeParser.parse("ethereum:\(testAddress)/transfer?address=somename.eth&uint256=1".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
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

    func testParsingOfArrayOfBytesAsParameter() throws {
        let testAddress = "0x9aBbDB06A61cC686BD635484439549D45c2449cc"
        let chainID = BigUInt(2828)
        let eip681Code = Web3.EIP681CodeParser.parse("ethereum:\(testAddress)@\(chainID.description)/setData?bytes32[]=[0x4b80742de2bf82acb3630000005e9F5BB83481d5627aA8c48527C174579bC428,0xdf30dba06db6a30e65354d9a64c609861f089545ca58c6b4dbe31a5f338cb0e3,0xdf30dba06db6a30e65354d9a64c6098600000000000000000000000000000004]&bytes[]=[0x0000000000000000000000000000000000000000000000000000000000000038,0x0000000000000000000000000000000000000000000000000000000000000004,0x005e9F5BB83481d5627aA8c48527C174579bC428]")
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

    func testParsingOfArrayOfBytesAsParameterWithEncoding() throws {
        let testAddress = "0x9aBbDB06A61cC686BD635484439549D45c2449cc"
        let chainID = BigUInt(2828)
        let eip681Code = Web3.EIP681CodeParser.parse("ethereum:\(testAddress)@\(chainID.description)/setData?bytes32[]=[0x4b80742de2bf82acb3630000005e9F5BB83481d5627aA8c48527C174579bC428,0xdf30dba06db6a30e65354d9a64c609861f089545ca58c6b4dbe31a5f338cb0e3,0xdf30dba06db6a30e65354d9a64c6098600000000000000000000000000000004]&bytes[]=[0x0000000000000000000000000000000000000000000000000000000000000038,0x0000000000000000000000000000000000000000000000000000000000000004,0x005e9F5BB83481d5627aA8c48527C174579bC428]".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
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

    func testParsingOfArrayOfIntAsParameter() throws {
        let testAddress = "0x9aBbDB06A61cC686BD635484439549D45c2449cc"
        let chainID = BigUInt(2828)
        let eip681Code = Web3.EIP681CodeParser.parse("ethereum:\(testAddress)@\(chainID.description)/functionName123?int256[]=[1,2,5000,3,4,10000]")
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

    func testParsingOfArrayOfIntOfFixedLengthAsParameter() throws {
        let testAddress = "0x9aBbDB06A61cC686BD635484439549D45c2449cc"
        let chainID = BigUInt(2828)
        let eip681Code = Web3.EIP681CodeParser.parse("ethereum:\(testAddress)@\(chainID.description)/functionName123?int256[3]=[1,2,5000]")
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

    func testParsingQueryParameterFixedLengthArray() throws {
        /// Declared `int256[3]` with 2 values instead of expected 3.
        var eip681Code = Web3.EIP681CodeParser.parse("ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc@2828/functionName123?int256[3]=[1,2]")
        XCTAssert(eip681Code != nil)
        XCTAssert(eip681Code?.parameters.count == 0)
        /// Declared `int256[3]` with 4 values instead of expected 3.
        eip681Code = Web3.EIP681CodeParser.parse("ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc@2828/functionName123?int256[3]=[1,2,2,3]")
        XCTAssert(eip681Code != nil)
        XCTAssert(eip681Code?.parameters.count == 0)
    }

    func testParsingQueryParameterStringsArray() throws {
        var eip681Code = Web3.EIP681CodeParser.parse("ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc@2828/functionName123?string[]=[\"123\",\"2,5000\",\"wwweer2-=!\"]")
        XCTAssert(eip681Code != nil)
        guard eip681Code != nil else { return }

        XCTAssertEqual(eip681Code!.parameters[0].type, .array(type: .string, length: 0))
        var data = eip681Code!.parameters[0].value as? [String]
        XCTAssertEqual(data, ["123","2,5000","wwweer2-=!"])

        eip681Code = Web3.EIP681CodeParser.parse("ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc@2828/functionName123?string[]=[123,2,5000,wwweer2-=!]")
        XCTAssert(eip681Code != nil)
        guard eip681Code != nil else { return }

        XCTAssertEqual(eip681Code!.parameters[0].type, .array(type: .string, length: 0))
        data = eip681Code!.parameters[0].value as? [String]
        XCTAssertEqual(data, ["123","2","5000","wwweer2-=!"])
    }

    func testParsingQueryParameterArrayOfStringsArrays() throws {
        var eip681Code = Web3.EIP681CodeParser.parse("ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc@2828/functionName123?string[][]=[[\"123\",\"2,5000\",\"wwweer2-=!\"],[\"test1\",\"demo\"]]")
        XCTAssert(eip681Code != nil)
        guard eip681Code != nil else { return }

        XCTAssertEqual(eip681Code!.parameters[0].type, .array(type: .array(type: .string, length: 0), length: 0))
        var data = eip681Code!.parameters[0].value as? [[String]]
        XCTAssertEqual(data?[0], ["123","2,5000","wwweer2-=!"])
        XCTAssertEqual(data?[1], ["test1","demo"])

        eip681Code = Web3.EIP681CodeParser.parse("ethereum:0x9aBbDB06A61cC686BD635484439549D45c2449cc@2828/functionName123?string[][]=[[123,2,5000,wwweer2-=!],[test1,demo]]")
        XCTAssert(eip681Code != nil)
        guard eip681Code != nil else { return }

        XCTAssertEqual(eip681Code!.parameters[0].type, .array(type: .array(type: .string, length: 0), length: 0))
        data = eip681Code!.parameters[0].value as? [[String]]
        XCTAssertEqual(data?[0], ["123","2","5000","wwweer2-=!"])
        XCTAssertEqual(data?[1], ["test1","demo"])
    }
}
