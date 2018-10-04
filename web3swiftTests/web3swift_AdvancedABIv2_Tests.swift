//
//  web3swift_AdvancedABIv2_Tests.swift
//  web3swift-iOS_Tests
//
//  Created by Anton Grigoriev on 02.07.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import XCTest
import CryptoSwift
import BigInt
import Result

@testable import web3swift_iOS

class web3swift_AdvancedABIv2_Tests: XCTestCase {
    
    func testAdvancedABIv2() {
        let abiString = "[{\"constant\":true,\"inputs\":[],\"name\":\"testDynOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testDynArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStaticArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testSingle\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"t\",\"type\":\"tuple\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"}]"
        let contractAddress = EthereumAddress("0xd14630167f878e92a40a1c12db4532f29cb3065e")
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let rawContract = contract?.contract as! ContractV2
        print(rawContract)
        let intermediate = contract?.method("testSingle", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testAdvancedABIv2staticArray() {
        let abiString = "[{\"constant\":true,\"inputs\":[],\"name\":\"testDynOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testDynArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStaticArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testSingle\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"t\",\"type\":\"tuple\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"}]"
        let contractAddress = EthereumAddress("0xd14630167f878e92a40a1c12db4532f29cb3065e")
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let rawContract = contract?.contract as! ContractV2
        print(rawContract)
        let intermediate = contract?.method("testStaticArray", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testAdvancedABIv2dynamicArray() {
        let abiString = "[{\"constant\":true,\"inputs\":[],\"name\":\"testDynOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testDynArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStaticArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testSingle\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"t\",\"type\":\"tuple\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"}]"
        let contractAddress = EthereumAddress("0xd14630167f878e92a40a1c12db4532f29cb3065e")
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let rawContract = contract?.contract as! ContractV2
        print(rawContract)
        let intermediate = contract?.method("testDynArray", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testAdvancedABIv2dynamicArrayOfStrings() {
        let abiString = "[{\"constant\":true,\"inputs\":[],\"name\":\"testDynOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testDynArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStaticArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testSingle\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"t\",\"type\":\"tuple\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"}]"
        let contractAddress = EthereumAddress("0xd14630167f878e92a40a1c12db4532f29cb3065e")
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let rawContract = contract?.contract as! ContractV2
        print(rawContract)
        let intermediate = contract?.method("testDynOfDyn", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testAdvancedABIv2staticArrayOfStrings() {
        let abiString = "[{\"constant\":true,\"inputs\":[],\"name\":\"testDynOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testDynArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStaticArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testSingle\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"t\",\"type\":\"tuple\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"}]"
        let contractAddress = EthereumAddress("0xd14630167f878e92a40a1c12db4532f29cb3065e")!
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let rawContract = contract?.contract as! ContractV2
        print(rawContract)
        let intermediate = contract?.method("testStOfDyn", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testEmptyArrayDecoding() {
        let abiString = "[{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"constant\":true,\"inputs\":[],\"name\":\"empty\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"
        let contractAddress = EthereumAddress("0x200eb5ccda1c35b0f5bf82552fdd65a8aee98e79")!
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let rawContract = contract?.contract as! ContractV2
        print(rawContract)
        let intermediate = contract?.method("empty", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testUserCase() {
        let abiString =  "[{\"constant\":true,\"inputs\":[],\"name\":\"getFlagData\",\"outputs\":[{\"name\":\"data\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"data\",\"type\":\"string\"}],\"name\":\"setFlagData\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]"
        let contractAddress = EthereumAddress("0x811411e3cdfd4750cdd3552feb3b89a46ddb612e")
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let intermediate = contract?.method("getFlagData", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
}
