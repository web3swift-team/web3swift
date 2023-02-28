//
//  EthereumAddressTest.swift
//
//
//  Created by JeneaVranceanu on 03.02.2023.
//

import Foundation
import XCTest

@testable import Web3Core

class EthereumAddressTest: XCTestCase {

    func testZeroAddress() {
        XCTAssertNotNil(EthereumAddress(Data(count: 20)))
    }

    func testAddress() {
        let rawAddress = "0x200eb5ccda1c35b0f5bf82552fdd65a8aee98e79"
        let ethereumAddress = EthereumAddress(rawAddress)
        XCTAssertNotNil(ethereumAddress)
        XCTAssertEqual(ethereumAddress?.address.lowercased(), rawAddress)
    }

    func testInvalidAddress() {
        var rawAddress = "0x200eb5ccda1c35b0f5bf82552e98e79"
        var ethereumAddress = EthereumAddress(rawAddress)
        XCTAssertNil(ethereumAddress)
        rawAddress = "0x200eb5ccDA1c35b0f5bf82552fdd65a8aeeabcde"
        ethereumAddress = EthereumAddress(rawAddress)
        XCTAssertNil(ethereumAddress)
        rawAddress = "0x200eb5ccda1c35b0f5bf82552fdd65a8aeeabcdef"
        ethereumAddress = EthereumAddress(rawAddress)
        XCTAssertNil(ethereumAddress)
    }

    func testDescription() async throws {
        let rawAddress = "0x200eb5ccda1c35b0f5bf82552fdd65a8aee98e79"
        let ethereumAddress = EthereumAddress(rawAddress)

        let sut = String(describing: ethereumAddress)

        XCTAssertTrue(sut.contains("EthereumAddress\n"))
        XCTAssertTrue(sut.contains("type: normal\n"))
        XCTAssertTrue(sut.contains("address: 0x200EB5cCdA1c35B0F5Bf82552FDD65a8AEe98E79"))
    }
}
