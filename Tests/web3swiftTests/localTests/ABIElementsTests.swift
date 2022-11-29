//
//  ABIElementsTest.swift
//
//  Created by JeneaVranceanu on 28.11.2022.
//

import Foundation
import XCTest
import Core

class ABIElementsTest: XCTestCase {
    typealias EthError = ABI.Element.EthError

    /// Function with any parameters should be able to decode `require` and `revert` calls in soliditiy.
    /// Note: `require(expression)` and `revert()` without a message return 0 bytes thus we cannot guarantee
    /// that 0 bytes response will be interpreted correctly.
    private let emptyFunction = ABI.Element.Function(name: "any",
                                                     inputs: [],
                                                     outputs: [],
                                                     constant: false,
                                                     payable: false)

    func testErrorRepresentation() {
        XCTAssertEqual(EthError(name: "Error", inputs: []).errorDeclaration, "Error()")
        XCTAssertEqual(EthError(name: "Error", inputs: [.init(name: "", type: .address)]).errorDeclaration, "Error(address)")
        XCTAssertEqual(EthError(name: "Error", inputs: [.init(name: "           ", type: .address)]).errorDeclaration, "Error(address)")
        XCTAssertEqual(EthError(name: "Error", inputs: [.init(name: "           ", type: .address), .init(name: "", type: .uint(bits: 256))]).errorDeclaration, "Error(address,uint256)")
        XCTAssertEqual(EthError(name: "Error", inputs: [.init(name: "sender", type: .address), .init(name: "    ", type: .uint(bits: 256))]).errorDeclaration, "Error(address sender,uint256)")
        // Not all types are supported in errors, e.g. tuples and functions are not supported
        let allTypesNamedAndNot: [ABI.Element.InOut] = [
            .init(name: "sender", type: .address),
            .init(name: "", type: .address),
            .init(name: "", type: .uint(bits: 8)),
            .init(name: "", type: .uint(bits: 16)),
            .init(name: "", type: .uint(bits: 32)),
            .init(name: "", type: .uint(bits: 64)),
            .init(name: "", type: .uint(bits: 128)),
            .init(name: "", type: .uint(bits: 256)),
            .init(name: "my_int_8", type: .int(bits: 8)),
            .init(name: "my_int_16", type: .int(bits: 16)),
            .init(name: "my_int_32", type: .int(bits: 32)),
            .init(name: "my_int_64", type: .int(bits: 64)),
            .init(name: "my_int_128", type: .int(bits: 128)),
            .init(name: "my_int_256", type: .int(bits: 256)),
            .init(name: "someFlag", type: .bool),
            .init(name: "rand_bytes", type: .bytes(length: 123)),
            .init(name: "", type: .dynamicBytes),
            .init(name: "arrarrarray123", type: .array(type: .bool, length: 0)),
            .init(name: "error_message_maybe", type: .string),
        ]
        XCTAssertEqual(EthError(name: "VeryCustomErrorName",
                                inputs: allTypesNamedAndNot).errorDeclaration,
                       "VeryCustomErrorName(address sender,address,uint8,uint16,uint32,uint64,uint128,uint256,int8 my_int_8,int16 my_int_16,int32 my_int_32,int64 my_int_64,int128 my_int_128,int256 my_int_256,bool someFlag,bytes123 rand_bytes,bytes,bool[] arrarrarray123,string error_message_maybe)")
    }

}
