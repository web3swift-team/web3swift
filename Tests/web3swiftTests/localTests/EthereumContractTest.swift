//
//  EthereumContractTest.swift
//  Tests
//
//  Created by JeneaVranceanu on 07/07/2022.
//  Copyright © 2022 web3swift. All rights reserved.
//

import XCTest

@testable import Web3Core
@testable import web3swift

class EthereumContractTest: LocalTestCase {
    private static let eventsOnlyABI = "[{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"operation\",\"type\":\"uint256\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"contractAddress\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"ContractCreated\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"bytes32\",\"name\":\"dataKey\",\"type\":\"bytes32\"}],\"name\":\"DataChanged\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"operation\",\"type\":\"uint256\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"bytes4\",\"name\":\"selector\",\"type\":\"bytes4\"}],\"name\":\"Executed\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"previousOwner\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"newOwner\",\"type\":\"address\"}],\"name\":\"OwnershipTransferred\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"},{\"indexed\":true,\"internalType\":\"bytes32\",\"name\":\"typeId\",\"type\":\"bytes32\"},{\"indexed\":true,\"internalType\":\"bytes\",\"name\":\"returnedValue\",\"type\":\"bytes\"},{\"indexed\":false,\"internalType\":\"bytes\",\"name\":\"receivedData\",\"type\":\"bytes\"}],\"name\":\"UniversalReceiver\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"sender\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"ValueReceived\",\"type\":\"event\"}]"

    private static let overloadedFunctionsABI = "[{\"inputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"operation\",\"type\":\"uint256\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"contractAddress\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"ContractCreated\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"bytes32\",\"name\":\"dataKey\",\"type\":\"bytes32\"}],\"name\":\"DataChanged\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"operation\",\"type\":\"uint256\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"bytes4\",\"name\":\"selector\",\"type\":\"bytes4\"}],\"name\":\"Executed\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"previousOwner\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"newOwner\",\"type\":\"address\"}],\"name\":\"OwnershipTransferred\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"},{\"indexed\":true,\"internalType\":\"bytes32\",\"name\":\"typeId\",\"type\":\"bytes32\"},{\"indexed\":true,\"internalType\":\"bytes\",\"name\":\"returnedValue\",\"type\":\"bytes\"},{\"indexed\":false,\"internalType\":\"bytes\",\"name\":\"receivedData\",\"type\":\"bytes\"}],\"name\":\"UniversalReceiver\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"sender\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"ValueReceived\",\"type\":\"event\"},{\"stateMutability\":\"payable\",\"type\":\"fallback\"},{\"inputs\":[{\"internalType\":\"bytes32[]\",\"name\":\"dataKeys\",\"type\":\"bytes32[]\"}],\"name\":\"getData\",\"outputs\":[{\"internalType\":\"bytes[]\",\"name\":\"dataValues\",\"type\":\"bytes[]\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"dataKey\",\"type\":\"bytes32\"}],\"name\":\"getData\",\"outputs\":[{\"internalType\":\"bytes\",\"name\":\"dataValue\",\"type\":\"bytes\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"noInputFunction\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32[]\",\"name\":\"dataKeys\",\"type\":\"bytes32[]\"},{\"internalType\":\"bytes[]\",\"name\":\"dataValues\",\"type\":\"bytes[]\"}],\"name\":\"setData\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"dataKey\",\"type\":\"bytes32\"},{\"internalType\":\"bytes\",\"name\":\"dataValue\",\"type\":\"bytes\"}],\"name\":\"setData\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]"

    func test_decodeEvents() async throws {
        let web3 = try await Web3.new(LocalTestCase.url)
        let contract = try XCTUnwrap(web3.contract(EthereumContractTest.eventsOnlyABI))

        XCTAssertTrue(contract.contract.allEvents.count == 6)
        XCTAssertNotNil(contract.contract.events["ContractCreated"])
        XCTAssertNotNil(contract.contract.events["DataChanged"])
        XCTAssertNotNil(contract.contract.events["Executed"])
        XCTAssertNotNil(contract.contract.events["OwnershipTransferred"])
        XCTAssertNotNil(contract.contract.events["UniversalReceiver"])
        XCTAssertNotNil(contract.contract.events["ValueReceived"])
    }

    func test_decodedAllFunctions() async throws {
        let web3 = try await Web3.new(LocalTestCase.url)
        let contract = try XCTUnwrap(web3.contract(EthereumContractTest.overloadedFunctionsABI))

        XCTAssertTrue(contract.contract.allMethods.count == 5)

        XCTAssertTrue(contract.contract.methods["getData"]?.count == 2)
        XCTAssertTrue(contract.contract.methods["getData(bytes32[])"]?.count == 1)
        XCTAssertTrue(contract.contract.methods["getData(bytes32)"]?.count == 1)
        XCTAssertTrue(contract.contract.methods[getFuncSignature("getData(bytes32[])")]?.count == 1)
        XCTAssertTrue(contract.contract.methods[getFuncSignature("getData(bytes32)")]?.count == 1)

        XCTAssertTrue(contract.contract.methods["setData"]?.count == 2)
        XCTAssertTrue(contract.contract.methods["setData(bytes32,bytes)"]?.count == 1)
        XCTAssertTrue(contract.contract.methods["setData(bytes32[],bytes[])"]?.count == 1)
        XCTAssertTrue(contract.contract.methods[getFuncSignature("setData(bytes32,bytes)")]?.count == 1)
        XCTAssertTrue(contract.contract.methods[getFuncSignature("setData(bytes32[],bytes[])")]?.count == 1)

        XCTAssertTrue(contract.contract.methods["noInputFunction"]?.count == 1)
        XCTAssertTrue(contract.contract.methods["noInputFunction()"]?.count == 1)
        XCTAssertTrue(contract.contract.methods[getFuncSignature("noInputFunction()")]?.count == 1)
    }

    func test_encodeMethodBasedOnNameWithParameters_mustFail() async throws {
        let web3 = try await Web3.new(LocalTestCase.url)
        let contract = try XCTUnwrap(web3.contract(EthereumContractTest.overloadedFunctionsABI))

        /// Encoding method that expects parameters but we are not giving any.
        /// Result must be `nil`.
        XCTAssertNil(contract.createWriteOperation("setData(bytes32,bytes)"))
        XCTAssertNil(contract.createWriteOperation(getFuncSignature("setData(bytes32,bytes)")))
    }

    func test_encodeMethodBasedOnNameWithParameters() async throws {
        let web3 = try await Web3.new(LocalTestCase.url)
        let contract = try XCTUnwrap(web3.contract(EthereumContractTest.overloadedFunctionsABI, at: EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")))
        let parameters: [Any] = [
            [Data.randomBytes(length: 32), Data.randomBytes(length: 32)],
            [Data.randomBytes(length: 32), Data.randomBytes(length: 32)]
        ]
        let functionNameWithParameters = "setData(bytes32[],bytes[])"
        let transaction = contract.createWriteOperation(functionNameWithParameters, parameters: parameters)
        XCTAssertNotNil(transaction)

        func testDecoding(_ method: String) throws {
            let data = try XCTUnwrap(transaction?.transaction.data)
            let decodedData = try XCTUnwrap(contract.contract.methods[method]?.first?.decodeInputData(data))
            XCTAssertNotNil(decodedData)
            XCTAssertEqual(try XCTUnwrap(decodedData["0"] as? [Data]), try XCTUnwrap(parameters[0] as? [Data]))
            XCTAssertEqual(try XCTUnwrap(decodedData["1"] as? [Data]), try XCTUnwrap(parameters[1] as? [Data]))
        }

        try testDecoding(functionNameWithParameters)
        try testDecoding(getFuncSignature(functionNameWithParameters))
    }

    func test_encodeMethodBasedOnHexSignature() async throws {
        let web3 = try await Web3.new(LocalTestCase.url)
        let contract = try XCTUnwrap(web3.contract(EthereumContractTest.overloadedFunctionsABI, at: EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")))
        let parameters: [Any] = [Data.randomBytes(length: 32), Data.randomBytes(length: 32)]
        let functionSignature = getFuncSignature("setData(bytes32,bytes)")
        let transaction = contract.createWriteOperation(functionSignature, parameters: parameters)
        XCTAssertNotNil(transaction)

        let data = try XCTUnwrap(transaction?.transaction.data)
        let decodedData = try XCTUnwrap(contract.contract.methods[functionSignature]?.first?.decodeInputData(data))
        XCTAssertNotNil(decodedData)
        XCTAssertEqual(try XCTUnwrap(decodedData["0"] as? Data), try XCTUnwrap(parameters[0] as? Data))
        XCTAssertEqual(try XCTUnwrap(decodedData["1"] as? Data), try XCTUnwrap(parameters[1] as? Data))
    }
}

private func getFuncSignature(_ string: String) -> String {
    return String(string.sha3(.keccak256).prefix(8)).lowercased().addHexPrefix()
}
