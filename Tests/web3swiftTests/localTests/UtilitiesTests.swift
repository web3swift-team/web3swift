//
//  UtilitiesTests.swift
//
//  Created by albertopeam on 15/11/22.
//

import XCTest
import BigInt
import Web3Core

@testable import web3swift

class UtilitiesTests: XCTestCase {
    // MARK: - units

    struct Test {
        let input: Utilities.Units
        let output: Int
    }

    func testUnitsDecimals() throws {
        let units: [Test] = [.init(input: .wei, output: 0),
                             .init(input: .kwei, output: 3),
                             .init(input: .babbage, output: 3),
                             .init(input: .femtoether, output: 3),
                             .init(input: .mwei, output: 6),
                             .init(input: .lovelace, output: 6),
                             .init(input: .picoether, output: 6),
                             .init(input: .gwei, output: 9),
                             .init(input: .shannon, output: 9),
                             .init(input: .nanoether, output: 9),
                             .init(input: .nano, output: 9),
                             .init(input: .szabo, output: 12),
                             .init(input: .microether, output: 12),
                             .init(input: .micro, output: 12),
                             .init(input: .finney, output: 15),
                             .init(input: .milliether, output: 15),
                             .init(input: .milli, output: 15),
                             .init(input: .ether, output: 18),
                             .init(input: .kether, output: 21),
                             .init(input: .grand, output: 21),
                             .init(input: .mether, output: 24),
                             .init(input: .gether, output: 27),
                             .init(input: .tether, output: 30)
        ]
        units.forEach { test in
            XCTAssertEqual(test.input.decimals, test.output)
        }
    }
}
