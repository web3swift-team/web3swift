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
            .init(name: "error_message_maybe", type: .string)
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

    /// `require(expression)` and `revert()` without a message return 0 bytes,
    /// we can noly catch an error when function has a return value
    func testDecodeEmptyErrorOnOneOutputFunction() throws {
        let contract = try EthereumContract(abi: [.function(emptyFunction)])
        do {
            try contract.decodeReturnData(emptyFunction.signature, data: Data())
        } catch {
            XCTFail()
        }

        let contract2 = try EthereumContract(abi: [.function(oneOutputFunction)])
        do {
            try contract2.decodeReturnData(oneOutputFunction.signature, data: Data())
            XCTFail()
        } catch {
            print(error)
        }
    }

    /// Data is decoded as a call of `revert` or `require` with a message no matter the number of outputs configured in the ``ABI/Element/Function``.
    /// `revert(message)` and `require(false,message)`return at least 128 bytes. We cannot differentiate between `require` or `revert`.
    func testDecodeDefaultErrorWithMessage() throws {
        /// 08c379a0 - Error(string) function selector
        /// 0000000000000000000000000000000000000000000000000000000000000020 - Data offset
        /// 000000000000000000000000000000000000000000000000000000000000001a - Message length
        /// 4e6f7420656e6f7567682045746865722070726f76696465642e000000000000 - Message + 0 bytes padding
        /// 0000... - some more 0 bytes padding to make the number of bytes match 32 bytes chunks
        let errorResponse = Data.fromHex("08c379a00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000001a4e6f7420656e6f7567682045746865722070726f76696465642e0000000000000000000000000000000000000000000000000000000000000000000000000000")!
        let contract = try EthereumContract(abi: [.function(emptyFunction)])

        do {
            try contract.decodeReturnData(emptyFunction.signature, data: errorResponse)
            XCTFail("decode function should throw an error")
        } catch Web3Error.revert(_, let reason) {
            XCTAssertEqual(reason, "Not enough Ether provided.")
        }

        XCTAssertEqual(EthError.decodeStringError(errorResponse[4...]), "Not enough Ether provided.")
    }

    /// Data is decoded as a call of `revert Unauthorized()`
    func testDecodeRevertWithCustomError() throws {
        /// 82b42900 - Unauthorized() function selector
        /// 00000000000000000000000000000000000000000000000000000000 - padding bytes
        let errorResponse = Data.fromHex("82b429000000000000000000000000000000000000000000000000000000000000000000")!
        let error = ABI.Element.EthError(name: "Unauthorized", inputs: [])
        let contract = try EthereumContract(abi: [.function(emptyFunction), .error(error)] )

        do {
            try contract.decodeReturnData(emptyFunction.signature, data: errorResponse)
            XCTFail("decode function should throw an error")
        } catch Web3Error.revertCustom(let signature, let args) {
            XCTAssertEqual(signature, "Unauthorized()")
            XCTAssertTrue(args.isEmpty)
        }

        guard let decoded = error.decodeEthError(errorResponse[4...]) else {
            XCTFail("decode response failed.")
            return
        }
        XCTAssertTrue(decoded.isEmpty)
    }

    /// Data is decoded as a call of `revert Unauthorized(bool)`.
    /// Trying to decode as `Unauthorized(string)`. Must fail.
    func testDecodeRevertWithCustomErrorFailed() throws {
        /// 5caef992 - Unauthorized(bool) function selector
        /// 00000000000000000000000000000000000000000000000000000000 - padding bytes
        let errorResponse = Data.fromHex("5caef9920000000000000000000000000000000000000000000000000000000000000000")!
        let error = ABI.Element.EthError(name: "Unauthorized", inputs: [.init(name: "", type: .bool)])
        let contract = try EthereumContract(abi: [.function(oneOutputFunction), .error(error)] )

        do {
            try contract.decodeReturnData(oneOutputFunction.signature, data: errorResponse)
            XCTFail("decode function should throw an error")
        } catch Web3Error.revertCustom(let signature, let args) {
            XCTAssertEqual(signature, "Unauthorized(bool)")
            XCTAssertEqual(args["0"] as? Bool, false)
        }

        guard let decoded = error.decodeEthError(errorResponse[4...]) else {
            XCTFail("decode response failed.")
            return
        }
        XCTAssertEqual(decoded["0"] as? Bool, false)
    }

    /// Data is decoded as a call of `revert Unauthorized("Reason")`. Decoded only if custom error ABI is given.
    /// The custom error argument must be extractable by index and name if the name is available.
    func testDecodeRevertWithCustomErrorWithArguments() throws {
        /// 973d02cb  - `Unauthorized(string)` function selector
        /// 0000000000000000000000000000000000000000000000000000000000000020 - data offset
        /// 0000000000000000000000000000000000000000000000000000000000000006 - first custom argument length
        /// 526561736f6e0000000000000000000000000000000000000000000000000000 - first custom argument bytes + 0 bytes padding
        /// 0000... - some more 0 bytes padding to make the number of bytes match 32 bytes chunks
        let errorResponse = Data.fromHex("973d02cb00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000006526561736f6e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")!
        let error = ABI.Element.EthError(name: "Unauthorized", inputs: [.init(name: "message_arg", type: .string)])
        let contract = try EthereumContract(abi: [.function(emptyFunction), .error(error)])

        do {
            try contract.decodeReturnData(emptyFunction.signature, data: errorResponse)
            XCTFail("decode function should throw an error")
        } catch Web3Error.revertCustom(let signature, let args) {
            XCTAssertEqual(signature, "Unauthorized(string)")
            XCTAssertEqual(args["0"] as? String, "Reason")
            XCTAssertEqual(args["message_arg"] as? String, "Reason")
        }

        guard let decoded = error.decodeEthError(errorResponse[4...]) else {
            XCTFail("decode response failed.")
            return
        }
        XCTAssertEqual(decoded["0"] as? String, "Reason")
        XCTAssertEqual(decoded["message_arg"] as? String, "Reason")
    }

    /// Data is decoded as a panic exception is generated.
    /// Example:
    /// ``` solidity
    /// function panicError() public {
    ///     assert(false);
    /// }
    /// ```
    func testDecodePanicError() throws {
        let errorResponse = Data(hex: "4e487b710000000000000000000000000000000000000000000000000000000000000001")
        let contract = try EthereumContract(abi: [.function(emptyFunction)])

        do {
            try contract.decodeReturnData(emptyFunction.signature, data: errorResponse)
        } catch Web3Error.revert(let message, let code) {
            XCTAssertTrue(message.contains("reverted with panic code 0x01"))
            XCTAssertEqual(code, "0x01")
        }

        XCTAssertEqual(EthError.decodePanicError(errorResponse[4...]), 1)
    }
}
