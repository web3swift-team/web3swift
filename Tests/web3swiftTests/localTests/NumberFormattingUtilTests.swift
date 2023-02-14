//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import CryptoSwift
import BigInt
import Web3Core

@testable import web3swift

class NumberFormattingUtilTests: LocalTestCase {

    func testNumberFormattingUtil() throws {
        let balance = BigInt("-1000000000000000000")
        let formatted = Utilities.formatToPrecision(balance, units: .ether, formattingDecimals: 4, decimalSeparator: ",")
        XCTAssertEqual(formatted, "-1")
    }

    func testNumberFormattingUtil2() throws {
        let balance = BigInt("-1000000000000000")
        let formatted = Utilities.formatToPrecision(balance, units: .ether, formattingDecimals: 4, decimalSeparator: ",")
        XCTAssertEqual(formatted, "-0,0010")
    }

    func testNumberFormattingUtil3() throws {
        let balance = BigInt("-1000000000000")
        let formatted = Utilities.formatToPrecision(balance, units: .ether, formattingDecimals: 4, decimalSeparator: ",")
        XCTAssertEqual(formatted, "-0,0000")
    }

    func testNumberFormattingUtil4() throws {
        let balance = BigInt("-1000000000000")
        let formatted = Utilities.formatToPrecision(balance, units: .ether, formattingDecimals: 9, decimalSeparator: ",")
        XCTAssertEqual(formatted, "-0,000001000")
    }

    func testNumberFormattingUtil5() throws {
        let balance = BigInt("-1")
        let formatted = Utilities.formatToPrecision(balance, units: .ether, formattingDecimals: 9, decimalSeparator: ",", fallbackToScientific: true)
        XCTAssertEqual(formatted, "-1e-18")
    }

    func testNumberFormattingUtil6() throws {
        let balance = BigInt("0")
        let formatted = Utilities.formatToPrecision(balance, units: .ether, formattingDecimals: 9, decimalSeparator: ",")
        XCTAssertEqual(formatted, "0")
    }

    func testNumberFormattingUtil7() throws {
        let balance = BigInt("-1100000000000000000")
        let formatted = Utilities.formatToPrecision(balance, units: .ether, formattingDecimals: 4, decimalSeparator: ",")
        XCTAssertEqual(formatted, "-1,1000")
    }

    func testNumberFormattingUtil8() throws {
        let balance = BigInt("100")
        let formatted = Utilities.formatToPrecision(balance, units: .ether, formattingDecimals: 4, decimalSeparator: ",", fallbackToScientific: true)
        XCTAssertEqual(formatted, "1,00e-16")
    }

    func testNumberFormattingUtil9() throws {
        let balance = BigInt("1000000")
        let formatted = Utilities.formatToPrecision(balance, units: .ether, formattingDecimals: 4, decimalSeparator: ",", fallbackToScientific: true)
        XCTAssertEqual(formatted, "1,0000e-12")
    }

    func testFormatPreccissionFallbacksToUnitsDecimals() throws {
        let bInt = BigInt(1_700_000_000_000_000_000)
        let result = Utilities.formatToPrecision(bInt, units: .ether, formattingDecimals: Utilities.Units.ether.decimals + 1, decimalSeparator: ",")
        XCTAssertEqual(result, "1,700000000000000000")
    }
}
