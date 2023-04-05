//
//  ABIEncoderTest.swift
//  Tests
//
//  Created by JeneaVranceanu on 28/03/2022.
//  Copyright © 2022 web3swift. All rights reserved.
//

import Foundation
import Web3Core
import XCTest
import BigInt
@testable import web3swift

class ABIEncoderTest: XCTestCase {

    func testEncodeInt() {
        XCTAssertEqual(ABIEncoder.encodeSingleType(type: .int(bits: 32), value: -10 as AnyObject)?.toHexString(), "fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6")
        XCTAssertEqual(ABIEncoder.encodeSingleType(type: .int(bits: 32), value: 10 as AnyObject)?.toHexString(), "000000000000000000000000000000000000000000000000000000000000000a")
    }

    func testEncodeUInt() {
        XCTAssertEqual(ABIEncoder.encodeSingleType(type: .uint(bits: 32), value: -10 as AnyObject), nil)
        XCTAssertEqual(ABIEncoder.encodeSingleType(type: .uint(bits: 32), value: 10 as AnyObject)?.toHexString(), "000000000000000000000000000000000000000000000000000000000000000a")
    }

    func testSoliditySha3() throws {
        var hex = try ABIEncoder.soliditySha3(true).toHexString().addHexPrefix()
        assert(hex == "0x5fe7f977e71dba2ea1a68e21057beebb9be2ac30c6410aa38d4f3fbe41dcffd2")
        hex = try ABIEncoder.soliditySha3(-10).toHexString().addHexPrefix()
        assert(hex == "0xd6fb717f7e270a360f5093ce6a7a3752183e89c9a9afe5c0cb54b458a304d3d5")
        hex = try ABIEncoder.soliditySha3(Data.fromHex("0xfff23243")!).toHexString().addHexPrefix()
        assert(hex == "0x0ee4597224d3499c72aa0c309b0d0cb80ff3c2439a548c53edb479abfd6927ba")
        hex = try ABIEncoder.soliditySha3(UInt(234564535)).toHexString().addHexPrefix()
        assert(hex == "0xb2daf574dc6ceac97e984c8a3ffce3c1ec19e81cc6b18aeea67b3ac2666f4e97")

        hex = try ABIEncoder.soliditySha3([UInt(234564535), Data.fromHex("0xfff23243")!, true, -10]).toHexString().addHexPrefix()
        assert(hex == "0x3e27a893dc40ef8a7f0841d96639de2f58a132be5ae466d40087a2cfa83b7179")

        hex = try ABIEncoder.soliditySha3("Hello!%").toHexString().addHexPrefix()
        assert(hex == "0x661136a4267dba9ccdf6bfddb7c00e714de936674c4bdb065a531cf1cb15c7fc")

        // This is not JS. '234' (with single or double quotes) will be a String, not any kind of number.
        // From Web3JS docs:> web3.utils.soliditySha3('234'); // auto detects: uint256

        hex = try ABIEncoder.soliditySha3(0xea).toHexString().addHexPrefix()
        assert(hex == "0x61c831beab28d67d1bb40b5ae1a11e2757fa842f031a2d0bc94a7867bc5d26c2")

        hex = try ABIEncoder.soliditySha3(234).toHexString().addHexPrefix()
        assert(hex == "0x61c831beab28d67d1bb40b5ae1a11e2757fa842f031a2d0bc94a7867bc5d26c2")

        hex = try ABIEncoder.soliditySha3(UInt64(234)).toHexString().addHexPrefix()
        assert(hex == "0x6e48b7f8b342032bfa46a07cf85358feee0efe560d6caa87d342f24cdcd07b0c")

        hex = try ABIEncoder.soliditySha3(UInt(234)).toHexString().addHexPrefix()
        assert(hex == "0x61c831beab28d67d1bb40b5ae1a11e2757fa842f031a2d0bc94a7867bc5d26c2")

        hex = try ABIEncoder.soliditySha3("0x407D73d8a49eeb85D32Cf465507dd71d507100c1").toHexString().addHexPrefix()
        assert(hex == "0x4e8ebbefa452077428f93c9520d3edd60594ff452a29ac7d2ccc11d47f3ab95b")

        hex = try ABIEncoder.soliditySha3(Data.fromHex("0x407D73d8a49eeb85D32Cf465507dd71d507100c1")!).toHexString().addHexPrefix()
        assert(hex == "0x4e8ebbefa452077428f93c9520d3edd60594ff452a29ac7d2ccc11d47f3ab95b")

        hex = try ABIEncoder.soliditySha3(EthereumAddress("0x407D73d8a49eeb85D32Cf465507dd71d507100c1")!).toHexString().addHexPrefix()
        assert(hex == "0x4e8ebbefa452077428f93c9520d3edd60594ff452a29ac7d2ccc11d47f3ab95b")

        hex = try ABIEncoder.soliditySha3("Hello!%").toHexString().addHexPrefix()
        assert(hex == "0x661136a4267dba9ccdf6bfddb7c00e714de936674c4bdb065a531cf1cb15c7fc")

        hex = try ABIEncoder.soliditySha3(Int8(-23)).toHexString().addHexPrefix()
        assert(hex == "0xdc046d75852af4aea44a770057190294068a953828daaaab83800e2d0a8f1f35")

        hex = try ABIEncoder.soliditySha3(EthereumAddress("0x85F43D8a49eeB85d32Cf465507DD71d507100C1d")!).toHexString().addHexPrefix()
        assert(hex == "0xe88edd4848fdce08c45ecfafd2fbfdefc020a7eafb8178e94c5feaeec7ac0bb4")

        hex = try ABIEncoder.soliditySha3(["Hello!%", Int8(-23), EthereumAddress("0x85F43D8a49eeB85d32Cf465507DD71d507100C1d")!]).toHexString().addHexPrefix()
        assert(hex == "0xa13b31627c1ed7aaded5aecec71baf02fe123797fffd45e662eac8e06fbe4955")
    }

    func testSoliditySha3FailGivenFloatDouble() throws {
        assert((try? ABIEncoder.soliditySha3(Float(1))) == nil)
        assert((try? ABIEncoder.soliditySha3(Double(1))) == nil)
        assert((try? ABIEncoder.soliditySha3(CGFloat(1))) == nil)
        assert((try? ABIEncoder.soliditySha3([Float(1)])) == nil)
        assert((try? ABIEncoder.soliditySha3([Double(1)])) == nil)
        assert((try? ABIEncoder.soliditySha3([CGFloat(1)])) == nil)
    }

    /// `[AnyObject]` is not allowed to be used directly as input for `solidtySha3`.
    /// `AnyObject` erases type data making it impossible to encode some types correctly,
    /// e.g.: Bool can be treated as Int (8/16/32/64) and 0/1 numbers can be treated as Bool.
    func testSoliditySha3FailGivenArrayWithEmptyString() throws {
        var didFail = false
        do {
            _ = try ABIEncoder.soliditySha3([""] as [AnyObject])
        } catch {
            didFail = true
        }
        XCTAssertTrue(didFail)
    }

    /// `AnyObject` is not allowed to be used directly as input for `solidtySha3`.
    /// `AnyObject` erases type data making it impossible to encode some types correctly,
    /// e.g.: Bool can be treated as Int (8/16/32/64) and 0/1 numbers can be treated as Bool.
    func testSoliditySha3FailGivenEmptyString() throws {
        var didFail = false
        do {
            _ = try ABIEncoder.soliditySha3("" as AnyObject)
        } catch {
            didFail = true
        }
        XCTAssertTrue(didFail)
    }

    func testAbiEncodingEmptyValues() {
        let zeroBytes = ABIEncoder.encode(types: [ABI.Element.InOut](), values: [Any]())!
        XCTAssert(zeroBytes.count == 0)

        let functionWithNoInput = ABI.Element.Function(name: "testFunction",
                                                       inputs: [],
                                                       outputs: [],
                                                       constant: false,
                                                       payable: false)
        let encodedFunction = functionWithNoInput.encodeParameters([])
        XCTAssertTrue(functionWithNoInput.methodEncoding == encodedFunction)
        XCTAssertTrue("0xe16b4a9b" == encodedFunction?.toHexString().addHexPrefix().lowercased())
    }

    func testConvertToBigInt() {
        XCTAssertEqual(ABIEncoder.convertToBigInt(BigInt(-29390909).serialize()), -29390909)
        XCTAssertEqual(ABIEncoder.convertToBigInt(Data.fromHex("00FF")!), 255)
        XCTAssertEqual(ABIEncoder.convertToBigInt(BigInt(-29390909)), -29390909)
        XCTAssertEqual(ABIEncoder.convertToBigInt(BigUInt(29390909)), 29390909)
        XCTAssertEqual(ABIEncoder.convertToBigInt(UInt(123)), 123)
        XCTAssertEqual(ABIEncoder.convertToBigInt(UInt8(254)), 254)
        XCTAssertEqual(ABIEncoder.convertToBigInt(UInt16(9090)), 9090)
        XCTAssertEqual(ABIEncoder.convertToBigInt(UInt32(747474)), 747474)
        XCTAssertEqual(ABIEncoder.convertToBigInt(UInt64(45222)), 45222)
        XCTAssertEqual(ABIEncoder.convertToBigInt(Int(123)), 123)
        XCTAssertEqual(ABIEncoder.convertToBigInt(Int8(127)), 127)
        XCTAssertEqual(ABIEncoder.convertToBigInt(Int16(9090)), 9090)
        XCTAssertEqual(ABIEncoder.convertToBigInt(Int32(83888)), 83888)
        XCTAssertEqual(ABIEncoder.convertToBigInt(Int64(45222)), 45222)
        XCTAssertEqual(ABIEncoder.convertToBigInt(Int(-32213)), -32213)
        XCTAssertEqual(ABIEncoder.convertToBigInt(Int8(-10)), -10)
        XCTAssertEqual(ABIEncoder.convertToBigInt(Int16(-32000)), -32000)
        XCTAssertEqual(ABIEncoder.convertToBigInt(Int32(-50050500)), -50050500)
        XCTAssertEqual(ABIEncoder.convertToBigInt(Int64(-2)), -2)
        XCTAssertEqual(ABIEncoder.convertToBigInt("10"), 10)
        XCTAssertEqual(ABIEncoder.convertToBigInt("-10"), -10)
        XCTAssertEqual(ABIEncoder.convertToBigInt("FF"), 255)
        XCTAssertEqual(ABIEncoder.convertToBigInt("-FF"), -255)
        XCTAssertEqual(ABIEncoder.convertToBigInt("0xFF"), 255)
        XCTAssertEqual(ABIEncoder.convertToBigInt("    10  "), 10)
        XCTAssertEqual(ABIEncoder.convertToBigInt("  -10 "), -10)
        XCTAssertEqual(ABIEncoder.convertToBigInt(" FF   "), 255)
        XCTAssertEqual(ABIEncoder.convertToBigInt(" -FF   "), -255)
        XCTAssertEqual(ABIEncoder.convertToBigInt(" 0xFF    "), 255)
    }

    func testConvertToBigUInt() {
        /// When negative value is serialized the first byte represents sign when decoding as a signed number.
        /// Unsigned numbers treat the first byte as just another byte of a number, not a sign.
        XCTAssertEqual(ABIEncoder.convertToBigUInt(BigInt(-29390909).serialize()), 4324358205)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(Data.fromHex("00FF")!), 255)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(BigInt(-29390909)), nil)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(BigUInt(29390909)), 29390909)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(UInt(123)), 123)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(UInt8(254)), 254)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(UInt16(9090)), 9090)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(UInt32(747474)), 747474)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(UInt64(45222)), 45222)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(Int(123)), 123)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(Int8(127)), 127)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(Int16(9090)), 9090)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(Int32(83888)), 83888)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(Int64(45222)), 45222)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(Int(-32213)), nil)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(Int8(-10)), nil)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(Int16(-32000)), nil)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(Int32(-50050500)), nil)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(Int64(-2)), nil)
        XCTAssertEqual(ABIEncoder.convertToBigUInt("10"), 10)
        XCTAssertEqual(ABIEncoder.convertToBigUInt("-10"), nil)
        XCTAssertEqual(ABIEncoder.convertToBigUInt("FF"), 255)
        XCTAssertEqual(ABIEncoder.convertToBigUInt("-FF"), nil)
        XCTAssertEqual(ABIEncoder.convertToBigUInt("0xFF"), 255)
        XCTAssertEqual(ABIEncoder.convertToBigUInt("    10  "), 10)
        XCTAssertEqual(ABIEncoder.convertToBigUInt("  -10 "), nil)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(" FF   "), 255)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(" -FF   "), nil)
        XCTAssertEqual(ABIEncoder.convertToBigUInt(" 0xFF    "), 255)
    }

    /// When dynamic types (string, non-fixed size array, dynamic bytes) are encoded
    /// they include a special 32 bytes entry called data offset that hold the value telling
    /// how much bytes should be skipped from the beginning of the resulting byte array to reach the
    /// value of the dynamic type.
    func testDynamicTypesDataOffset() {
        var hexData = ABIEncoder.encode(types: [.string], values: ["test"])?.toHexString()
        XCTAssertEqual(hexData?[0..<64], "0000000000000000000000000000000000000000000000000000000000000020")
        XCTAssertEqual(hexData, "000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000047465737400000000000000000000000000000000000000000000000000000000")
        hexData = ABIEncoder.encode(types: [.array(type: .uint(bits: 8), length: 0)], values: [[1, 2, 3, 4]])?.toHexString()
        XCTAssertEqual(hexData?[0..<64], "0000000000000000000000000000000000000000000000000000000000000020")
        XCTAssertEqual(hexData, "000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000004")

        // This one shouldn't have data offset
        hexData = ABIEncoder.encode(types: [.array(type: .uint(bits: 8), length: 4)], values: [[1, 2, 3, 4]])?.toHexString()
        // First 32 bytes are the first value from the array
        XCTAssertEqual(hexData?[0..<64], "0000000000000000000000000000000000000000000000000000000000000001")
        XCTAssertEqual(hexData, "0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000004")

        let types: [ABI.Element.ParameterType] = [.uint(bits: 8),
                                                  .bool,
                                                  .array(type: .uint(bits: 8), length: 0),
                                                  .bytes(length: 2)]
        let values: [Any] = [10, false, [1, 2, 3, 4], Data(count: 2)]
        hexData = ABIEncoder.encode(types: types, values: values)?.toHexString()
        XCTAssertEqual(hexData?[128..<192], "0000000000000000000000000000000000000000000000000000000000000080")
        XCTAssertEqual(hexData, "000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000004")
    }

    /// Test for the expected output when encoding dynamic types.
    func testAbiEncodingDynamicTypes() {
        var encodedValue = ABIEncoder.encode(types: [.dynamicBytes], values: [Data.fromHex("6761766f66796f726b")!])!.toHexString()
        XCTAssertEqual(encodedValue, "000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000096761766f66796f726b0000000000000000000000000000000000000000000000")

        encodedValue = ABIEncoder.encode(types: [.dynamicBytes], values: [Data.fromHex("731a3afc00d1b1e3461b955e53fc866dcf303b3eb9f4c16f89e388930f48134b")!])!.toHexString()
        XCTAssertEqual(encodedValue, "00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000020731a3afc00d1b1e3461b955e53fc866dcf303b3eb9f4c16f89e388930f48134b")

        encodedValue = ABIEncoder.encode(types: [.dynamicBytes], values: [Data.fromHex("fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1")!])!.toHexString()
        XCTAssertEqual(encodedValue, "0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000009ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff100")

        encodedValue = ABIEncoder.encode(types: [.dynamicBytes], values: [Data.fromHex("c3a40000c3a4")!])!.toHexString()
        XCTAssertEqual(encodedValue, "00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000006c3a40000c3a40000000000000000000000000000000000000000000000000000")

        encodedValue = ABIEncoder.encode(types: [.string], values: ["gavofyork"])!.toHexString()
        XCTAssertEqual(encodedValue, "000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000096761766f66796f726b0000000000000000000000000000000000000000000000")

        encodedValue = ABIEncoder.encode(types: [.string], values: ["Heeäööä👅D34ɝɣ24Єͽ-.,äü+#/"])!.toHexString()
        XCTAssertEqual(encodedValue, "00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000026486565c3a4c3b6c3b6c3a4f09f9185443334c99dc9a33234d084cdbd2d2e2cc3a4c3bc2b232f0000000000000000000000000000000000000000000000000000")
    }
}
