//
//  ABIElementErrorDecodingTest.swift
//
//  Created by JeneaVranceanu on 28.11.2022.
//

import Foundation
import XCTest
import Web3Core

class ABIElementErrorDecodingTest: XCTestCase {
    typealias EthError = ABI.Element.EthError

    /// Function with any parameters should be able to decode `require` and `revert` calls in soliditiy.
    /// Note: `require(expression)` and `revert()` without a message return 0 bytes thus we cannot guarantee
    /// that 0 bytes response will be interpreted correctly.
    private let emptyFunction = ABI.Element.Function(name: "any",
                                                     inputs: [],
                                                     outputs: [],
                                                     constant: false,
                                                     payable: false)
    private let oneOutputFunction = ABI.Element.Function(name: "any",
                                                         inputs: [],
                                                         outputs: [.init(name: "", type: .bool)],
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

    /// Empty Data is not decoded as a call of `revert` or `require` if function has no outputs.
    /// If a function that has no outputs attempts to decode empty `revert` or `require` must return `nil`
    /// because we don't know just based on the output if the call was successful or reverted.
    func testDecodeEmptyErrorOnNoOutputFunction() {
        XCTAssertTrue(emptyFunction.decodeErrorResponse(Data()) == nil)
    }

    func testDecodeEmptyErrorOnOneOutputFunction() {
        guard let errorData = oneOutputFunction.decodeErrorResponse(Data()) else {
            XCTFail("Empty Data must be decoded as a `revert()` or `require(false)` call if function used to decode it has at least one output parameter.")
            return
        }

        XCTAssertEqual(errorData["_success"] as? Bool, false)
        XCTAssertNotNil(errorData["_failureReason"] as? String)

        let decodedOutput = oneOutputFunction.decodeReturnData(Data())

        XCTAssertEqual(errorData["_success"] as? Bool, decodedOutput["_success"] as? Bool)
        XCTAssertEqual(errorData["_failureReason"] as? String, decodedOutput["_failureReason"] as? String)
    }

    /// Data is decoded as a call of `revert` or `require` with a message no matter the number of outputs configured in the ``ABI/Element/Function``.
    /// `revert(message)` and `require(false,message)`return at least 128 bytes. We cannot differentiate between `require` or `revert`.
    func testDecodeDefaultErrorWithMessage() {
        /// 08c379a0 - Error(string) function selector
        /// 0000000000000000000000000000000000000000000000000000000000000020 - Data offset
        /// 000000000000000000000000000000000000000000000000000000000000001a - Message length
        /// 4e6f7420656e6f7567682045746865722070726f76696465642e000000000000 - Message + 0 bytes padding
        /// 0000... - some more 0 bytes padding to make the number of bytes match 32 bytes chunks
        let errorResponse = Data.fromHex("08c379a00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000001a4e6f7420656e6f7567682045746865722070726f76696465642e00000000000000000000000000000000000000000000000000000000000000000000")!
        guard let errorData = emptyFunction.decodeErrorResponse(errorResponse) else {
            XCTFail("Data must be decoded as a `revert(\"Not enough Ether provided.\")` or `require(false, \"Not enough Ether provided.\")` but decoding failed completely.")
            return
        }

        XCTAssertEqual(errorData["_success"] as? Bool, false)
        XCTAssertEqual(errorData["_abortedByRevertOrRequire"] as? Bool, true)
        XCTAssertEqual(errorData["_errorMessage"] as? String, "Not enough Ether provided.")
        XCTAssertNotNil(errorData["_failureReason"] as? String)

        let decodedOutput = oneOutputFunction.decodeReturnData(errorResponse)

        XCTAssertEqual(errorData["_success"] as? Bool, decodedOutput["_success"] as? Bool)
        XCTAssertEqual(errorData["_failureReason"] as? String, decodedOutput["_failureReason"] as? String)
        XCTAssertEqual(errorData["_abortedByRevertOrRequire"] as? Bool, decodedOutput["_abortedByRevertOrRequire"] as? Bool)
        XCTAssertEqual(errorData["_errorMessage"] as? String, decodedOutput["_errorMessage"] as? String)
        XCTAssertEqual(decodedOutput["_errorMessage"] as? String, "Not enough Ether provided.")
    }

    /// Data is decoded as a call of `revert Unauthorized()`. Decoded only if custom error ABI is given.
    func testDecodeRevertWithCustomError() {
        /// 82b42900 - Unauthorized() function selector
        /// 00000000000000000000000000000000000000000000000000000000 - padding bytes
        let errorResponse = Data.fromHex("82b4290000000000000000000000000000000000000000000000000000000000")!
        let errors: [String: EthError] = ["82b42900" : .init(name: "Unauthorized", inputs: [])]
        guard let errorData = emptyFunction.decodeErrorResponse(errorResponse, errors: errors) else {
            XCTFail("Data must be decoded as a `revert(\"Not enough Ether provided.\")` or `require(false, \"Not enough Ether provided.\")` but decoding failed completely.")
            return
        }

        XCTAssertEqual(errorData["_success"] as? Bool, false)
        XCTAssertEqual(errorData["_abortedByRevertOrRequire"] as? Bool, true)
        XCTAssertEqual(errorData["_error"] as? String, "Unauthorized()")

        let decodedOutput = oneOutputFunction.decodeReturnData(errorResponse, errors: errors)

        XCTAssertEqual(errorData["_success"] as? Bool, decodedOutput["_success"] as? Bool)
        XCTAssertEqual(errorData["_abortedByRevertOrRequire"] as? Bool, decodedOutput["_abortedByRevertOrRequire"] as? Bool)
        XCTAssertEqual(errorData["_error"] as? String, decodedOutput["_error"] as? String)
    }

    /// Data is decoded as a call of `revert Unauthorized()`. Decoded only if custom error ABI is given.
    /// Trying to decode as `Unauthorized(string)`. Must fail.
    func testDecodeRevertWithCustomErrorFailed() {
        /// 82b42900 - Unauthorized() function selector
        /// 00000000000000000000000000000000000000000000000000000000 - padding bytes
        let errorResponse = Data.fromHex("82b4290000000000000000000000000000000000000000000000000000000000")!
        let errors: [String: EthError] = ["82b42900" : .init(name: "Unauthorized", inputs: [.init(name: "", type: .string)])]
        guard let errorData = emptyFunction.decodeErrorResponse(errorResponse, errors: errors) else {
            XCTFail("Data must be decoded as a `revert(\"Not enough Ether provided.\")` or `require(false, \"Not enough Ether provided.\")` but decoding failed completely.")
            return
        }

        XCTAssertEqual(errorData["_success"] as? Bool, false)
        XCTAssertEqual(errorData["_abortedByRevertOrRequire"] as? Bool, true)
        XCTAssertEqual(errorData["_error"] as? String, "Unauthorized(string)")
        XCTAssertEqual(errorData["_parsingError"] as? String, "Data matches Unauthorized(string) but failed to be decoded.")

        let decodedOutput = oneOutputFunction.decodeReturnData(errorResponse, errors: errors)

        XCTAssertEqual(errorData["_success"] as? Bool, decodedOutput["_success"] as? Bool)
        XCTAssertEqual(errorData["_abortedByRevertOrRequire"] as? Bool, decodedOutput["_abortedByRevertOrRequire"] as? Bool)
        XCTAssertEqual(errorData["_error"] as? String, decodedOutput["_error"] as? String)
        XCTAssertEqual(errorData["_parsingError"] as? String, decodedOutput["_parsingError"] as? String)
    }

    /// Data is decoded as a call of `revert Unauthorized("Reason")`. Decoded only if custom error ABI is given.
    /// The custom error argument must be extractable by index and name if the name is available.
    func testDecodeRevertWithCustomErrorWithArguments() {
        /// 973d02cb  - `Unauthorized(string)` function selector
        /// 0000000000000000000000000000000000000000000000000000000000000020 - data offset
        /// 0000000000000000000000000000000000000000000000000000000000000006 - first custom argument length
        /// 526561736f6e0000000000000000000000000000000000000000000000000000 - first custom argument bytes + 0 bytes padding
        /// 0000... - some more 0 bytes padding to make the number of bytes match 32 bytes chunks
        let errorResponse = Data.fromHex("973d02cb00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000006526561736f6e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")!
        let errors: [String: EthError] = ["973d02cb" : .init(name: "Unauthorized", inputs: [.init(name: "message_arg", type: .string)])]
        guard let errorData = emptyFunction.decodeErrorResponse(errorResponse, errors: errors) else {
            XCTFail("Data must be decoded as a `revert(\"Not enough Ether provided.\")` or `require(false, \"Not enough Ether provided.\")` but decoding failed completely.")
            return
        }

        XCTAssertEqual(errorData["_success"] as? Bool, false)
        XCTAssertEqual(errorData["_abortedByRevertOrRequire"] as? Bool, true)
        XCTAssertEqual(errorData["_error"] as? String, "Unauthorized(string message_arg)")
        XCTAssertEqual(errorData["0"] as? String, "Reason")
        XCTAssertEqual(errorData["0"] as? String, errorData["message_arg"] as? String)

        let decodedOutput = oneOutputFunction.decodeReturnData(errorResponse, errors: errors)

        XCTAssertEqual(errorData["_success"] as? Bool, decodedOutput["_success"] as? Bool)
        XCTAssertEqual(errorData["_abortedByRevertOrRequire"] as? Bool, decodedOutput["_abortedByRevertOrRequire"] as? Bool)
        XCTAssertEqual(errorData["_error"] as? String, decodedOutput["_error"] as? String)
        XCTAssertEqual(errorData["0"] as? String, decodedOutput["0"] as? String)
        XCTAssertEqual(errorData["message_arg"] as? String, decodedOutput["message_arg"] as? String)
    }
}
