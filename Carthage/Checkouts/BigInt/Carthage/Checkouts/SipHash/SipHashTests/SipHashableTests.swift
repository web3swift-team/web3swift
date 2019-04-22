//
//  SipHashableTests.swift
//  SipHash
//
//  Created by Károly Lőrentey on 2016-11-14.
//  Copyright © 2016-2017 Károly Lőrentey.
//

import XCTest
@testable import SipHash

private struct Book: SipHashable {
    let title: String
    let pageCount: Int

    func appendHashes(to hasher: inout SipHasher) {
        hasher.append(title)
        hasher.append(pageCount)
    }

    static func ==(left: Book, right: Book) -> Bool {
        return left.title == right.title && left.pageCount == right.pageCount
    }
}

class SipHashableTests: XCTestCase {
    func testBookHashValue() {
        let book = Book(title: "The Colour of Magic", pageCount: 206)
        let actual = book.hashValue

        var hasher = SipHasher()
        hasher.append(book.title.hashValue)
        hasher.append(book.pageCount)
        let expected = hasher.finalize()

        XCTAssertEqual(actual, expected)
    }

    func testBookEquality() {
        let book1 = Book(title: "The Colour of Magic", pageCount: 206)
        let hash1 = book1.hashValue

        let book2 = Book(title: "The Colour of Magic", pageCount: 206)
        let hash2 = book2.hashValue

        XCTAssertEqual(hash1, hash2)
    }

    func testAddSipHashable() {
        let book = Book(title: "The Colour of Magic", pageCount: 206)
        let hash1 = book.hashValue

        var hasher = SipHasher()
        hasher.append(book)
        let hash2 = hasher.finalize()

        XCTAssertEqual(hash1, hash2)
    }
}
