//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
// Base58 tests by Mark Loit 2022
//

import XCTest
import Web3Core

@testable import web3swift

//
// This Test suite is intended to hold various tests for our data conversion code
// that don't seem to fit elsewhere
//

// Some base58 test vectors pulled from: https://tools.ietf.org/id/draft-msporny-base58-01.html
// note that one of the return values is incorrect in the reference above, it is corrected here
class DataConversionTests: LocalTestCase {
    // test an empty input for the base58 decoder & decoder
    func testBase58() throws {
        let vector = ""

        guard let resultDecoded = vector.base58DecodedData else { return XCTFail("base58 decode unexpectedly returned nil") }
        XCTAssert(resultDecoded.count == 0)

        let resultEncoded1 = vector.base58EncodedString
        XCTAssert(resultEncoded1 == vector)

        let arr = resultDecoded.withUnsafeBytes { Array($0) }
        let resultEncoded2 = arr.base58EncodedString
        XCTAssert(resultEncoded2 == vector)
    }

    // test a reference string "Hello World!"
    func testBase58HelloWorld() throws {
        let vector = "2NEpo7TZRRrLZSi2U"
        let expected = "Hello World!"

        guard let resultDecoded = vector.base58DecodedData else { return XCTFail("base58 decode unexpectedly returned nil") }
        let arr = resultDecoded.withUnsafeBytes { Array($0) }
        let str = String(bytes: arr, encoding: .utf8)
        XCTAssert(str == expected)

        let resultEncoded = expected.base58EncodedString
        XCTAssert(resultEncoded == vector)
    }

    // test a reference string "The quick brown fox jumps over the lazy dog."
    func testBase58LazyFox() throws {
        let vector = "USm3fpXnKG5EUBx2ndxBDMPVciP5hGey2Jh4NDv6gmeo1LkMeiKrLJUUBk6Z"
        let expected = "The quick brown fox jumps over the lazy dog."

        guard let resultDecoded = vector.base58DecodedData else { return XCTFail("base58 decode unexpectedly returned nil") }
        let arr = resultDecoded.withUnsafeBytes { Array($0) }
        let str = String(bytes: arr, encoding: .utf8)
        XCTAssert(str == expected)

        let resultEncoded = expected.base58EncodedString
        XCTAssert(resultEncoded == vector)
    }

    // test a reference binary value "0x000000287fb4cd" (tested as a hex string to validate length) **corrected from ref document
    func testBase58HexData() throws {
        let vector = "111233QC4"
        let expected = "0x000000287fb4cd"

        guard let resultDecoded = vector.base58DecodedData else { return XCTFail("base58 decode unexpectedly returned nil") }
        let str = resultDecoded.toHexString().addHexPrefix()
        XCTAssert(str == expected)

        let arr = resultDecoded.withUnsafeBytes { Array($0) }
        let resultEncoded = arr.base58EncodedString
        XCTAssert(resultEncoded == vector)
    }

    // test all zero encoded data from issue 424
    func testBase58Zero() throws {
        let vector = "11111111111111111111111111111111"
        let expected = "0x0000000000000000000000000000000000000000000000000000000000000000"

        guard let resultDecoded = vector.base58DecodedData else { return XCTFail("base58 decode unexpectedly returned nil") }
        let str = resultDecoded.toHexString().addHexPrefix()
        XCTAssert(str == expected)

        let arr = resultDecoded.withUnsafeBytes { Array($0) }
        let resultEncoded = arr.base58EncodedString
        XCTAssert(resultEncoded == vector)
    }

}
