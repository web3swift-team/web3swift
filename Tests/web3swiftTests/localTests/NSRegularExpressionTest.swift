//
//  NSRegularExpressionTest.swift
//
//  Created by JeneaVranceanu at 22.09.2022.
//

import Foundation
import XCTest

@testable import Web3Core

class NSRegularExpressionTest: XCTestCase {

    func test_stripLeadingZeroes() {
        XCTAssertEqual("random-string".stripLeadingZeroes(), "random-string")
        XCTAssertEqual("".stripLeadingZeroes(), "")
        XCTAssertEqual("0x".stripLeadingZeroes(), "0x")
        XCTAssertEqual("0x0".stripLeadingZeroes(), "0x0")
        XCTAssertEqual("0x00".stripLeadingZeroes(), "0x0")
        XCTAssertEqual("0x00".stripLeadingZeroes(), "0x0")
        XCTAssertEqual("0x00000".stripLeadingZeroes(), "0x0")
        XCTAssertEqual("0x000001".stripLeadingZeroes(), "0x1")
        XCTAssertEqual("0x1000001".stripLeadingZeroes(), "0x1000001")
        XCTAssertEqual("0x00000000012300001".stripLeadingZeroes(), "0x12300001")
    }

}
