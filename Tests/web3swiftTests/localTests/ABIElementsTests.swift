//
//  ABIElementsTests.swift
//
//
//  Created by JeneaVranceanu on 09.01.2024.
//

import Foundation
import XCTest
@testable import web3swift
@testable import Web3Core

class ABIElementsTests: XCTestCase {

    func testABIElementFunction() {
        let test1Function = ABI.Element.Function(name: "Test1",
                                                 inputs: [],
                                                 outputs: [],
                                                 constant: true,
                                                 payable: false)

        XCTAssertEqual(test1Function.name, "Test1")
        XCTAssertEqual(test1Function.selector, String("Test1()".sha3(.keccak256).prefix(8)))
        XCTAssertEqual(test1Function.selectorEncoded,
                       Data.fromHex("Test1()".sha3(.keccak256))?.prefix(4))

    }

}
