//
//  ArrayExtensionTests.swift
//  Created by albertopeam on 25/11/22.
//

@testable import Web3Core
import XCTest
import BigInt

final class ArrayExtensionTests: XCTestCase {
    func testToAnyObjectEmpty() {
        let result = [].toAnyObject()
        XCTAssertEqual(result.count, 0)
    }

    func testToAnyObjectNils() throws {
        let result = [nil, nil].toAnyObject()
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.first is NSNull)
        XCTAssertTrue(result.dropFirst().first is NSNull)
    }

    func testToAnyObjectNilAndNonNils() throws {
        let result = [
            1,
            nil,
            "2",
            NSNull(),
            Data(hex: "FA"),
            BigInt(3),
            BigUInt(4),
            EthereumAddress(Data(count: 20))
        ].toAnyObject()
        XCTAssertEqual(result.count, 8)
        XCTAssertEqual(result.first as? Int, 1)
        XCTAssertTrue(result.dropFirst(1).first is NSNull)
        XCTAssertEqual(result.dropFirst(2).first as? String, "2")
        XCTAssertTrue(result.dropFirst(3).first is NSNull)
        XCTAssertEqual(result.dropFirst(4).first as? Data, Data(hex: "FA"))
        XCTAssertEqual(result.dropFirst(5).first as? BigInt, BigInt(3))
        XCTAssertEqual(result.dropFirst(6).first as? BigUInt, BigUInt(4))
        XCTAssertEqual(result.dropFirst(7).first as? EthereumAddress, EthereumAddress(Data(count: 20)))
    }
}
