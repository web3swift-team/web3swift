//
//  web3swiftDecodeSolidityErrorType.swift
//  Tests
//
//  Created by JeneaVranceanu on 25/01/2022.
//  Copyright © 2022 web3swift. All rights reserved.
//

import XCTest
import web3swift
import Web3Core

/// Since solidity 0.8.4 a new type was introduced called `error`.
/// Contracts' ABI with this type were not decodable.
class DecodeSolidityErrorType: XCTestCase {

    func testStructuredErrorTypeDecoding() async throws {
        let contractAbiWithErrorTypes = "[{\"inputs\":[{\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"disallowedAddress\",\"type\":\"address\"}],\"name\":\"NotAllowedAddress\",\"type\":\"error\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"internalType\":\"bytes4\",\"name\":\"disallowedFunction\",\"type\":\"bytes4\"}],\"name\":\"NotAllowedFunction\",\"type\":\"error\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"internalType\":\"string\",\"name\":\"permission\",\"type\":\"string\"}],\"name\":\"NotAuthorised\",\"type\":\"error\"}]"
        let web3Instance = try await Web3.new(LocalTestCase.url)
        let contract = Web3.Contract(web3: web3Instance, abiString: contractAbiWithErrorTypes)
        assert(contract != nil)
    }
}
