//
//  ArrayExtensionTests.swift
//  Created by albertopeam on 25/11/22.
//

@testable import Core
import XCTest

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
        let result = [1, nil, "", NSNull()].toAnyObject()
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result.first as? Int, 1)
        XCTAssertTrue(result.dropFirst().first is NSNull)
        XCTAssertNil(result.dropFirst().first as? String, "2")
        XCTAssertTrue(result.dropFirst().first is NSNull)
    }
}
