//
//  web3swiftABITests.swift
//  web3swift-iOS_Tests
//
//  Created by Георгий Фесенко on 02/07/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import XCTest
import BigInt

@testable import web3swift_iOS

class web3swift_ABI_Tests: XCTestCase {
    
    
    func testRealABIv2() {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"getUsers\",\"outputs\":[{\"name\":\"\",\"type\":\"address[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"handle\",\"type\":\"string\"},{\"name\":\"city\",\"type\":\"bytes32\"},{\"name\":\"state\",\"type\":\"bytes32\"},{\"name\":\"country\",\"type\":\"bytes32\"}],\"name\":\"registerNewUser\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"SHA256notaryHash\",\"type\":\"bytes32\"}],\"name\":\"getImage\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"userAddress\",\"type\":\"address\"}],\"name\":\"getUser\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"bytes32\"},{\"name\":\"\",\"type\":\"bytes32\"},{\"name\":\"\",\"type\":\"bytes32\"},{\"name\":\"\",\"type\":\"bytes32[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"getAllImages\",\"outputs\":[{\"name\":\"\",\"type\":\"bytes32[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"imageURL\",\"type\":\"string\"},{\"name\":\"SHA256notaryHash\",\"type\":\"bytes32\"}],\"name\":\"addImageToUser\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"userAddress\",\"type\":\"address\"}],\"name\":\"getUserImages\",\"outputs\":[{\"name\":\"\",\"type\":\"bytes32[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIv2.Record].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIv2.Element in
                return try record.parse()
            })
            print(abiNative)
            XCTAssert(abiNative.count > 0, "Can't parse some real-world ABI")
        } catch {
            XCTFail()
            print(error)
        }
    }
    
    func testABIv2Parsing () {
        let jsonString = "[{\"name\":\"f\",\"type\":\"function\",\"inputs\":[{\"name\":\"s\",\"type\":\"tuple\",\"components\":[{\"name\":\"a\",\"type\":\"uint256\"},{\"name\":\"b\",\"type\":\"uint256[]\"},{\"name\":\"c\",\"type\":\"tuple[]\",\"components\":[{\"name\":\"x\",\"type\":\"uint256\"},{\"name\":\"y\",\"type\":\"uint256\"}]}]},{\"name\":\"t\",\"type\":\"tuple\",\"components\":[{\"name\":\"x\",\"type\":\"uint256\"},{\"name\":\"y\",\"type\":\"uint256\"}]},{\"name\":\"a\",\"type\":\"uint256\"},{\"name\":\"z\",\"type\":\"uint256[3]\"}],\"outputs\":[]}]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIv2.Record].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIv2.Element in
                return try record.parse()
            })
            print(abiNative)
            XCTAssert(abiNative.count > 0, "Can't parse some real-world ABI")
        } catch {
            XCTFail()
            print(error)
        }
    }
    
    func testABIdecoding2() {
        let jsonString = "[{\"type\":\"function\",\"name\":\"balance\",\"constant\":true},{\"type\":\"function\",\"name\":\"send\",\"constant\":false,\"inputs\":[{\"name\":\"amount\",\"type\":\"uint256\"}]},{\"type\":\"function\",\"name\":\"test\",\"constant\":false,\"inputs\":[{\"name\":\"number\",\"type\":\"uint32\"}]},{\"type\":\"function\",\"name\":\"string\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"string\"}]},{\"type\":\"function\",\"name\":\"bool\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"bool\"}]},{\"type\":\"function\",\"name\":\"address\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"address\"}]},{\"type\":\"function\",\"name\":\"uint64[2]\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint64[2]\"}]},{\"type\":\"function\",\"name\":\"uint64[]\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint64[]\"}]},{\"type\":\"function\",\"name\":\"foo\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint32\"}]},{\"type\":\"function\",\"name\":\"bar\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint32\"},{\"name\":\"string\",\"type\":\"uint16\"}]},{\"type\":\"function\",\"name\":\"slice\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint32[2]\"}]},{\"type\":\"function\",\"name\":\"slice256\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint256[2]\"}]},{\"type\":\"function\",\"name\":\"sliceAddress\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"address[]\"}]},{\"type\":\"function\",\"name\":\"sliceMultiAddress\",\"constant\":false,\"inputs\":[{\"name\":\"a\",\"type\":\"address[]\"},{\"name\":\"b\",\"type\":\"address[]\"}]}]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIv2.Record].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIv2.Element in
                return try record.parse()
            })
            print(abiNative)
            XCTAssert(true, "Failed to parse ABI")
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testABIv2decoding() {
        let jsonString = "[{\"type\":\"constructor\",\"payable\":false,\"stateMutability\":\"nonpayable\",\"inputs\":[{\"name\":\"testInt\",\"type\":\"uint256\"}]},{\"type\":\"function\",\"name\":\"foo\",\"constant\":false,\"payable\":false,\"stateMutability\":\"nonpayable\",\"inputs\":[{\"name\":\"b\",\"type\":\"uint256\"},{\"name\":\"c\",\"type\":\"bytes32\"}],\"outputs\":[{\"name\":\"\",\"type\":\"address\"}]},{\"type\":\"event\",\"name\":\"Event\",\"inputs\":[{\"indexed\":true,\"name\":\"b\",\"type\":\"uint256\"},{\"indexed\":false,\"name\":\"c\",\"type\":\"bytes32\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"Event2\",\"inputs\":[{\"indexed\":true,\"name\":\"b\",\"type\":\"uint256\"},{\"indexed\":false,\"name\":\"c\",\"type\":\"bytes32\"}],\"anonymous\":false}]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIv2.Record].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIv2.Element in
                return try record.parse()
            })
            print(abiNative)
            XCTAssert(true, "Failed to parse ABI")
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testABIv2decoding2() {
        let jsonString = "[{\"type\":\"function\",\"name\":\"balance\",\"constant\":true},{\"type\":\"function\",\"name\":\"send\",\"constant\":false,\"inputs\":[{\"name\":\"amount\",\"type\":\"uint256\"}]},{\"type\":\"function\",\"name\":\"test\",\"constant\":false,\"inputs\":[{\"name\":\"number\",\"type\":\"uint32\"}]},{\"type\":\"function\",\"name\":\"string\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"string\"}]},{\"type\":\"function\",\"name\":\"bool\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"bool\"}]},{\"type\":\"function\",\"name\":\"address\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"address\"}]},{\"type\":\"function\",\"name\":\"uint64[2]\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint64[2]\"}]},{\"type\":\"function\",\"name\":\"uint64[]\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint64[]\"}]},{\"type\":\"function\",\"name\":\"foo\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint32\"}]},{\"type\":\"function\",\"name\":\"bar\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint32\"},{\"name\":\"string\",\"type\":\"uint16\"}]},{\"type\":\"function\",\"name\":\"slice\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint32[2]\"}]},{\"type\":\"function\",\"name\":\"slice256\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint256[2]\"}]},{\"type\":\"function\",\"name\":\"sliceAddress\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"address[]\"}]},{\"type\":\"function\",\"name\":\"sliceMultiAddress\",\"constant\":false,\"inputs\":[{\"name\":\"a\",\"type\":\"address[]\"},{\"name\":\"b\",\"type\":\"address[]\"}]}]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIv2.Record].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIv2.Element in
                return try record.parse()
            })
            print(abiNative)
            XCTAssert(true, "Failed to parse ABI")
        } catch {
            print(error)
            XCTFail()
        }
    }
        
    func testABIv2encoding1()
    {
        //        var a = abi.methodID('baz', [ 'uint32', 'bool' ]).toString('hex') + abi.rawEncode([ 'uint32', 'bool' ], [ 69, 1 ]).toString('hex')
        //        var b = 'cdcd77c000000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001'
        //
        let types = [
            ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.uint(bits: 32)),
            ABIv2.Element.InOut(name: "2", type: ABIv2.Element.ParameterType.bool)
        ]
        let data = ABIv2Encoder.encode(types: types, values: [BigUInt(69), true] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0x00000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001"
        print(data!.toHexString().lowercased())
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }
    
    func testABIv2encoding2()
    {
        let types = [
            ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.string)
        ]
        let data = ABIv2Encoder.encode(types: types, values: ["dave"] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000046461766500000000000000000000000000000000000000000000000000000000"
        print(data!.toHexString().lowercased())
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }
    
    func testABIv2encoding3()
    {
        //        var a = abi.methodID('sam', [ 'bytes', 'bool', 'uint256[]' ]).toString('hex') + abi.rawEncode([ 'bytes', 'bool', 'uint256[]' ], [ 'dave', true, [ 1, 2, 3 ] ]).toString('hex')
        //        var b = 'a5643bf20000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000464617665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003'
        let types = [
            ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.dynamicBytes),
            ABIv2.Element.InOut(name: "2", type: ABIv2.Element.ParameterType.bool),
            ABIv2.Element.InOut(name: "3", type: ABIv2.Element.ParameterType.array(type: .uint(bits: 256), length: 0))
        ]
        
        let data = ABIv2Encoder.encode(types: types, values: ["dave".data(using: .utf8)!, true, [BigUInt(1), BigUInt(2), BigUInt(3)] ] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0x0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000464617665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003"
        print(data!.toHexString().lowercased())
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }
    
    func testABIv2encoding4()
    {
        //        var a = abi.rawEncode([ 'int256' ], [ new BN('-19999999999999999999999999999999999999999999999999999999999999', 10) ]).toString('hex')
        //        var b = 'fffffffffffff38dd0f10627f5529bdb2c52d4846810af0ac000000000000001'
        
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.int(bits: 256))]
        let number = BigInt("-19999999999999999999999999999999999999999999999999999999999999", radix: 10)
        let data = ABIv2Encoder.encode(types: types,
                                       values: [number!] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0xfffffffffffff38dd0f10627f5529bdb2c52d4846810af0ac000000000000001"
        let result = data?.toHexString().lowercased().addHexPrefix()
        print(result)
        XCTAssert(result == expected, "failed to encode")
    }
    
    func testABIv2encoding5()
    {
        //        var a = abi.rawEncode([ 'string' ], [ ' hello world hello world hello world hello world  hello world hello world hello world hello world  hello world hello world hello world hello world hello world hello world hello world hello world' ]).toString('hex')
        //        var b = '000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000c22068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64000000000000000000000000000000000000000000000000000000000000'
        
        let string = " hello world hello world hello world hello world  hello world hello world hello world hello world  hello world hello world hello world hello world hello world hello world hello world hello world"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.string)]
        let data = ABIv2Encoder.encode(types: types,
                                       values: [string] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000c22068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64000000000000000000000000000000000000000000000000000000000000"
        print(data?.toHexString().lowercased().addHexPrefix())
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }
    
    func testABIv2encoding6()
    {
        //        var a = abi.methodID('f', [ 'uint', 'uint32[]', 'bytes10', 'bytes' ]).toString('hex') + abi.rawEncode([ 'uint', 'uint32[]', 'bytes10', 'bytes' ], [ 0x123, [ 0x456, 0x789 ], '1234567890', 'Hello, world!' ]).toString('hex')
        //        var b = '8be6524600000000000000000000000000000000000000000000000000000000000001230000000000000000000000000000000000000000000000000000000000000080313233343536373839300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000004560000000000000000000000000000000000000000000000000000000000000789000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000'
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.uint(bits: 256)),
                     ABIv2.Element.InOut(name: "2", type: ABIv2.Element.ParameterType.array(type: .uint(bits: 32), length: 0)),
                     ABIv2.Element.InOut(name: "3", type: ABIv2.Element.ParameterType.bytes(length: 10)),
                     ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.dynamicBytes)
        ]
        let data = ABIv2Encoder.encode(types: types,
                                       values: [BigUInt("123", radix: 16)!,
                                                [BigUInt("456", radix: 16)!, BigUInt("789", radix: 16)!] as [AnyObject],
                                                "1234567890",
                                                "Hello, world!"] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0x00000000000000000000000000000000000000000000000000000000000001230000000000000000000000000000000000000000000000000000000000000080313233343536373839300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000004560000000000000000000000000000000000000000000000000000000000000789000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000"
        print(data!.toHexString().lowercased())
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }
    
    func testABIv2encoding7()
    {
        let types = [
            ABIv2.Element.InOut(name: "2", type: ABIv2.Element.ParameterType.array(type: .string, length: 0))
        ]
        let data = ABIv2Encoder.encode(types: types,
                                       values: [["Hello", "World"]] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000548656c6c6f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005576f726c64000000000000000000000000000000000000000000000000000000"
        print(data!.toHexString().lowercased())
        XCTAssert(data?.toHexString().lowercased() == expected, "failed to encode")
    }
    
    func testABIv2encoding8()
    {
        let types = [
            ABIv2.Element.InOut(name: "2", type: ABIv2.Element.ParameterType.array(type: .string, length: 2))
        ]
        let data = ABIv2Encoder.encode(types: types,
                                       values: [["Hello", "World"]] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000548656c6c6f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005576f726c64000000000000000000000000000000000000000000000000000000"
        print(data!.toHexString().lowercased())
        XCTAssert(data?.toHexString().lowercased() == expected, "failed to encode")
    }
    
    
    
    func testABIv2Decoding1() {
        let data = "0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000005c0000000000000000000000000000000000000000000000000000000000000003"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.array(type: .uint(bits: 256), length: 2)),
                     ABIv2.Element.InOut(name: "2", type: ABIv2.Element.ParameterType.uint(bits: 256))]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == 2)
        guard let firstElement = result[0] as? [BigUInt] else {return XCTFail()}
        XCTAssert(firstElement.count == 2)
        guard let secondElement = result[1] as? BigUInt else {return XCTFail()}
        XCTAssert(firstElement[0] == BigUInt(1))
        XCTAssert(firstElement[1] == BigUInt(92))
        XCTAssert(secondElement == BigUInt(3))
    }
    
    func testABIv2Decoding2() {
        let data = "00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.array(type: .uint(bits: 256), length: 0))]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == 1)
        guard let firstElement = result[0] as? [BigUInt] else {return XCTFail()}
        XCTAssert(firstElement.count == 3)
        XCTAssert(firstElement[0] == BigUInt(1))
        XCTAssert(firstElement[1] == BigUInt(2))
        XCTAssert(firstElement[2] == BigUInt(3))
    }
    
    func testABIv2Decoding3() {
        let data = "0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000b68656c6c6f20776f726c64000000000000000000000000000000000000000000"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.dynamicBytes)]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == 1)
        guard let firstElement = result[0] as? Data else {return XCTFail()}
        XCTAssert(firstElement.count == 11)
    }
    
    func testABIv2Decoding4() {
        let data = "0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000b68656c6c6f20776f726c64000000000000000000000000000000000000000000"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.string)]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == 1)
        guard let firstElement = result[0] as? String else {return XCTFail()}
        XCTAssert(firstElement == "hello world")
    }
    
    func testABIv2Decoding5() {
        let data = "fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.int(bits: 32))]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == 1)
        guard let firstElement = result[0] as? BigInt else {return XCTFail()}
        XCTAssert(firstElement == BigInt(-2))
    }
    
    func testABIv2Decoding6() {
        let data = "ffffffffffffffffffffffffffffffffffffffffffffffffffffb29c26f344fe"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.int(bits: 64))]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == 1)
        guard let firstElement = result[0] as? BigInt else {return XCTFail()}
        XCTAssert(firstElement == BigInt("-85091238591234")!)
    }
    
    func testABIv2Decoding7() {
        let data = "0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002a"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.bool),
                     ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.uint(bits: 32))]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == types.count)
        guard let firstElement = result[0] as? Bool else {return XCTFail()}
        XCTAssert(firstElement == true)
        guard let secondElement = result[1] as? BigUInt else {return XCTFail()}
        XCTAssert(secondElement == 42)
    }
    
    func testABIv2Decoding8() {
        let data = "000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002a"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.bool),
                     ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.array(type: .uint(bits: 256), length: 0))]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == types.count)
        guard let firstElement = result[0] as? Bool else {return XCTFail()}
        XCTAssert(firstElement == true)
        guard let secondElement = result[1] as? [BigUInt] else {return XCTFail()}
        XCTAssert(secondElement.count == 1)
        XCTAssert(secondElement[0] == 42)
    }
    
    func testABIv2Decoding9() {
        let data = "0000000000000000000000000000000000000000000000000000000000000020" +
            "0000000000000000000000000000000000000000000000000000000000000002" +
            "000000000000000000000000407d73d8a49eeb85d32cf465507dd71d507100c1" +
        "000000000000000000000000407d73d8a49eeb85d32cf465507dd71d507100c3"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.array(type: .address, length: 0))]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == types.count)
        guard let firstElement = result[0] as? [EthereumAddress] else {return XCTFail()}
        XCTAssert(firstElement.count == 2)
        XCTAssert(firstElement[0].address.lowercased().stripHexPrefix() == "407d73d8a49eeb85d32cf465507dd71d507100c1")
        XCTAssert(firstElement[1].address.lowercased().stripHexPrefix() == "407d73d8a49eeb85d32cf465507dd71d507100c3")
    }
    
    
    
//    func testABIparsing1()
//    {
//        let typeString = "uint256[2][3]"
//        let type = try! ABITypeParser.parseTypeString(typeString)
//        switch type {
//        case .staticABIType(let unwrappedType):
//            switch unwrappedType{
//            case .array(_, length: let length):
//                XCTAssert(length == 3, "Failed to parse")
//            default:
//                XCTFail()
//            }
//        case .dynamicABIType(_):
//            XCTFail()
//            
//        }
//    }
//    
//    func testABIparsing2()
//    {
//        let typeString = "uint256[2][]"
//        let type = try! ABITypeParser.parseTypeString(typeString)
//        switch type {
//        case .staticABIType(_):
//            XCTFail()
//        case .dynamicABIType(let unwrappedType):
//            switch unwrappedType{
//            case .dynamicArray(_):
//                XCTAssert(true)
//            default:
//                XCTFail()
//            }
//        }
//    }
    
}
