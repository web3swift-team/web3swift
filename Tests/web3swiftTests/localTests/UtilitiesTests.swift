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

    func testPublicKeyWithNoPrefixToAddress() throws {
        var address = Utilities.publicToAddress(Data.fromHex("0x18ed2e1ec629e2d3dae7be1103d4f911c24e0c80e70038f5eb5548245c475f504c220d01e1ca419cb1ba4b3393b615e99dd20aa6bf071078f70fd949008e7411")!)?.address
        XCTAssertEqual(address, "0x28828f43df370651AC5A6cFd02fBD0885Fbb3c00")
        address = Utilities.publicToAddress(Data.fromHex("0x52972572d465d016d4c501887b8df303eee3ed602c056b1eb09260dfa0da0ab288742f4dc97d9edb6fd946babc002fdfb06f26caf117b9405ed79275763fdb1c")!)?.address
        XCTAssertEqual(address, "0x6eDBe1F6D48FbF1b053D6c9FA7997C710B84f55F")
    }

    func testPublicKeyWithPrefixToAddress() throws {
        var address = Utilities.publicToAddress(Data.fromHex("0x0418ed2e1ec629e2d3dae7be1103d4f911c24e0c80e70038f5eb5548245c475f504c220d01e1ca419cb1ba4b3393b615e99dd20aa6bf071078f70fd949008e7411")!)?.address
        XCTAssertEqual(address, "0x28828f43df370651AC5A6cFd02fBD0885Fbb3c00")
        address = Utilities.publicToAddress(Data.fromHex("0x0452972572d465d016d4c501887b8df303eee3ed602c056b1eb09260dfa0da0ab288742f4dc97d9edb6fd946babc002fdfb06f26caf117b9405ed79275763fdb1c")!)?.address
        XCTAssertEqual(address, "0x6eDBe1F6D48FbF1b053D6c9FA7997C710B84f55F")
    }

    func testPublicKeyWithInvalidPrefixToAddress() throws {
        var address = Utilities.publicToAddress(Data.fromHex("0x0318ed2e1ec629e2d3dae7be1103d4f911c24e0c80e70038f5eb5548245c475f504c220d01e1ca419cb1ba4b3393b615e99dd20aa6bf071078f70fd949008e7411")!)?.address
        XCTAssertEqual(address, nil)
        address = Utilities.publicToAddress(Data.fromHex("0x0152972572d465d016d4c501887b8df303eee3ed602c056b1eb09260dfa0da0ab288742f4dc97d9edb6fd946babc002fdfb06f26caf117b9405ed79275763fdb1c")!)?.address
        XCTAssertEqual(address, nil)
    }

    func testCompressedPublicKeyToAddress() throws {
        var address = Utilities.publicToAddress(Data.fromHex("0x0318ed2e1ec629e2d3dae7be1103d4f911c24e0c80e70038f5eb5548245c475f50")!)?.address
        XCTAssertEqual(address, "0x28828f43df370651AC5A6cFd02fBD0885Fbb3c00")
        address = Utilities.publicToAddress(Data.fromHex("0x0252972572d465d016d4c501887b8df303eee3ed602c056b1eb09260dfa0da0ab2")!)?.address
        XCTAssertEqual(address, "0x6eDBe1F6D48FbF1b053D6c9FA7997C710B84f55F")
    }

    func testCompressedPublicKeyWithInvalidPrefixToAddress() throws {
        var address = Utilities.publicToAddress(Data.fromHex("0x0718ed2e1ec629e2d3dae7be1103d4f911c24e0c80e70038f5eb5548245c475f50")!)?.address
        XCTAssertEqual(address, nil)
        address = Utilities.publicToAddress(Data.fromHex("0x0852972572d465d016d4c501887b8df303eee3ed602c056b1eb09260dfa0da0ab2")!)?.address
        XCTAssertEqual(address, nil)
    }

    func testStringIsHex() {
        XCTAssertTrue("1234567890abcdef".isHex)
        XCTAssertFalse("ghijklmn".isHex)
    }
}
