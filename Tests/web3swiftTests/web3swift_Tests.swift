//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//


import XCTest
import CryptoSwift
import BigInt
//import EthereumAddress
//import secp256k1_swift

@testable import web3swift

class web3swift_Tests: XCTestCase {
    
    func testBitFunctions () {
        let data = Data([0xf0, 0x02, 0x03])
        let firstBit = data.bitsInRange(0,1)
        XCTAssert(firstBit == 1)
        let first4bits = data.bitsInRange(0,4)
        XCTAssert(first4bits == 0x0f)
    }
    
    func testCombiningPublicKeys() {
        let priv1 = Data(repeating: 0x01, count: 32)
        let pub1 = Web3.Utils.privateToPublic(priv1, compressed: true)!
        let priv2 = Data(repeating: 0x02, count: 32)
        let pub2 = Web3.Utils.privateToPublic(priv2, compressed: true)!
        let combined = SECP256K1.combineSerializedPublicKeys(keys: [pub1, pub2], outputCompressed: true)
        let compinedPriv = Data(repeating: 0x03, count: 32)
        let compinedPub = Web3.Utils.privateToPublic(compinedPriv, compressed: true)
        XCTAssert(compinedPub == combined)
    }
    
    func testChecksumAddress() {
        let input = "0xfb6916095ca1df60bb79ce92ce3ea74c37c5d359"
        let output = EthereumAddress.toChecksumAddress(input);
        XCTAssert(output == "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359", "Failed to checksum address")
    }
    
    func testChecksumAddressParsing() {
        let input = "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359"
        let addr = EthereumAddress(input);
        XCTAssert(addr != nil);
        let invalidInput = "0xfb6916095ca1df60bB79Ce92cE3Ea74c37c5d359"
        let invalidAddr = EthereumAddress(invalidInput);
        XCTAssert(invalidAddr == nil);
    }
    
    func testBigUIntFromHex() {
        let hexRepresentation = "0x1c31de57e49fc00".stripHexPrefix()
        let biguint = BigUInt(hexRepresentation, radix: 16)!
        XCTAssert(biguint == BigUInt("126978086000000000"))
    }
    
    func testBloom() {
        let positive = [
                "testtest",
                "test",
                "hallo",
                "other",
            ]
        let negative = [
                "tes",
                "lo",
            ]
        var bloom = EthereumBloomFilter()
        for str in positive {
            let data = str.data(using: .utf8)!
            let oldBytes = bloom.bytes
            bloom.add(BigUInt(data))
            let newBytes = bloom.bytes
            if (newBytes != oldBytes) {
                print("Added new bits")
            }
        }
        for str in positive {
            let data = str.data(using: .utf8)!
            XCTAssert(bloom.lookup(data), "Failed")
        }
        for str in negative {
            let data = str.data(using: .utf8)!
            XCTAssert(bloom.lookup(data) == false, "Failed")
        }
    }

    func testMakePrivateKey()
    {
        let privKey = SECP256K1.generatePrivateKey()
        XCTAssert(privKey != nil, "Failed to create new private key")
    }
    
    func testUserCaseEventParsing() throws {
        let contractAddress = EthereumAddress("0x7ff546aaccd379d2d1f241e1d29cdd61d4d50778")
        let jsonString = "[{\"constant\":false,\"inputs\":[{\"name\":\"_id\",\"type\":\"string\"}],\"name\":\"deposit\",\"outputs\":[],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_id\",\"type\":\"string\"},{\"indexed\":true,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Deposit\",\"type\":\"event\"}]"
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(jsonString, at: contractAddress, abiVersion: 2)
        guard let eventParser = contract?.createEventParser("Deposit", filter: nil) else {return XCTFail()}
        let pres = try eventParser.parseBlockByNumber(UInt64(2138657))
        XCTAssert(pres.count == 1)
    }
    
    func testIBANcreation() {
        let iban = "XE7338O073KYGTWWZN0F2WZ0R8PX5ZPPZS"
        let native = Web3.Utils.Iban(iban)
        XCTAssert(native != nil)
        let expectedAddress = "0x00c5496aEe77C1bA1f0854206A26DdA82a81D6D8"
        let createdAddress = native?.toEthereumAddress()?.address
        XCTAssert(createdAddress == expectedAddress)
        
        let address = EthereumAddress("0x03c5496aee77c1ba1f0854206a26dda82a81d6d8")!
        let fromAddress = Web3.Utils.Iban(address)
        let ibn = fromAddress?.iban
        XCTAssert(ibn == "XE83FUTTUNPK7WZJSGGCWVEBARQWQ8YML4")
    }
    
    func testGenericRPCresponse() {
        let hex = "0x1"
        let rpcResponse = JSONRPCresponse(id: 1, jsonrpc: "2.0", result: hex, error: nil)
        let value: BigUInt? = rpcResponse.getValue()
        XCTAssert(value == 1)
    }
    
    func testPublicMappingsAccess() {
        do {
            let jsonString = "[{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"users\",\"outputs\":[{\"name\":\"name\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"address\"}],\"name\":\"userDeviceCount\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalUsers\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"
            let web3 = Web3.InfuraRinkebyWeb3()
            guard let addr = EthereumAddress("0xdef61132a0c1259464b19e4590e33666aae38574") else {return XCTFail()}
            let contract = web3.contract(jsonString, at: addr, abiVersion: 2)
            XCTAssert(contract != nil)
            let allMethods = contract!.contract.allMethods
            let userDeviceCount = try contract!.read("userDeviceCount", parameters: [addr as AnyObject])?.callPromise().wait()
            print(userDeviceCount!)
            let totalUsers = try contract!.read("totalUsers", parameters: [])?.callPromise().wait()
            print(totalUsers!)
            let user = try contract!.read("users", parameters: [0 as AnyObject])?.callPromise().wait()
            print(user!)
            print(allMethods)
        } catch {
            print(error)
        }
    }
    
}

