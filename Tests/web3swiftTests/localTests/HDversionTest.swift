//
//  HDversionTest.swift
//
//  Created by JeneaVranceanu on 12.03.2023.
//

import Foundation
import XCTest
import Web3Core

class HDversionTest: XCTestCase {

    func testPrefixesNotNil() {
        XCTAssertNotNil(HDNode.HDversion.publicPrefix)
        XCTAssertNotNil(HDNode.HDversion.privatePrefix)
    }

}
