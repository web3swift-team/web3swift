//
//  String+ExtensionTests.swift
//
//  Created by JeneaVranceanu on 26.11.2023.
//

import Foundation
import XCTest

class StringExtensionsTest: XCTestCase {

    func testIsHex() throws {
        XCTAssertTrue("0x".isHex)
        XCTAssertTrue("0xF".isHex)
        XCTAssertTrue("F".isHex)
        XCTAssertTrue("0xFF".isHex)
        XCTAssertTrue("0x0123456789abcdefABCDEF".isHex)
        XCTAssertTrue("0123456789abcdefABCDEF".isHex)
        XCTAssertTrue("0123456789abcdefABCDEF ".isHex)
        XCTAssertTrue(" 0123456789abcdefABCDEF ".isHex)
        XCTAssertTrue(" 0123456789abcdefABCDEF".isHex)

        XCTAssertFalse("".isHex)
        XCTAssertFalse("-".isHex)
        XCTAssertFalse("xyz".isHex)
        XCTAssertFalse("0xCAFEQ".isHex)
        XCTAssertFalse("R0123456789abcdefABCDEF ".isHex)
        XCTAssertFalse(" R0123456789abcdefABCDEF ".isHex)
    }

}
