//
//  WordTests.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2017-7-26.
//  Copyright © 2017 Károly Lőrentey. All rights reserved.
//

import XCTest
@testable import BigInt

struct TestDivision<Word: FixedWidthInteger> where Word.Magnitude == Word {
    static func testDivision(_ u: (high: Word, low: Word.Magnitude), _ v: Word) {
        let (div, mod) = v.fastDividingFullWidth(u)
        var (ph, pl) = div.multipliedFullWidth(by: v)
        let (s, o) = pl.addingReportingOverflow(mod)
        pl = s
        if o { ph += Word(1) }

        if mod >= v {
            XCTFail("For u = \(u), v = \(v): u mod v = \(mod), which is greater than v")
        }

        func message() -> String {
            let uhs = String(u.high, radix: 16)
            let uls = String(u.low, radix: 16)
            let vs = String(v, radix: 16)
            let divs = String(div, radix: 16)
            let mods = String(mod, radix: 16)
            let phs = String(ph, radix: 16)
            let pls = String(pl, radix: 16)
            return "(\(uhs),\(uls)) / \(vs) = (\(divs), \(mods)), but div * v + mod = (\(phs),\(pls))"
        }
        XCTAssertEqual(ph, u.high, message())
        XCTAssertEqual(pl, u.low, message())
    }

    static func test() {
        testDivision((0, 0), 2)
        testDivision((0, 1), 2)
        testDivision((1, 0), 2)
        testDivision((8, 0), 136)
        testDivision((128, 0), 136)
        testDivision((2, 0), 35)
        testDivision((7, 12), 19)
    }
}

class WordTests: XCTestCase {
    func testFullDivide() {
        TestDivision<UInt8>.test()
        TestDivision<UInt16>.test()
        TestDivision<UInt32>.test()
        TestDivision<UInt64>.test()
        TestDivision<UInt>.test()

        #if false
        typealias Word = UInt8
        for v in 1 ... Word.max {
            for u1 in 0 ..< v {
                for u0 in 0 ..< Word.max {
                    TestDivision<Word>.testDivision((u1, u0), v)
                }
            }
        }
        #endif
    }
    
    func testConversion() {
        enum Direction {
            case unitsToWords
            case wordsToUnits
            case both
        }
        func test<Word: FixedWidthInteger, Unit: FixedWidthInteger>
            (direction: Direction = .both,
             words: [Word], of wtype: Word.Type = Word.self,
             units: [Unit], of utype: Unit.Type = Unit.self,
             file: StaticString = #file, line: UInt = #line) {
            switch direction {
            case .wordsToUnits, .both:
                let actualUnits = [Unit](Units(of: Unit.self, words))
                XCTAssertEqual(actualUnits, units, "words -> units", file: file, line: line)
            default:
                break
            }
            switch direction {
            case .unitsToWords, .both:
                var it = units.makeIterator()
                let actualWords = [Word](count: units.count, generator: { () -> Unit? in it.next() })
                XCTAssertEqual(actualWords, words, "units -> words", file: file, line: line)
            default:
                break
            }
        }


        test(words: [], of: UInt8.self,
             units: [], of: UInt8.self)
        test(words: [0x01], of: UInt8.self,
             units: [0x01], of: UInt8.self)
        test(words: [0x01, 0x02], of: UInt8.self,
             units: [0x02, 0x01], of: UInt8.self)

        test(words: [], of: UInt8.self,
             units: [], of: UInt16.self)
        test(direction: .unitsToWords,
             words: [0x01, 0x00], of: UInt8.self,
             units: [0x0001], of: UInt16.self)
        test(direction: .wordsToUnits,
             words: [0x01], of: UInt8.self,
             units: [0x0001], of: UInt16.self)
        test(words: [0x01, 0x02], of: UInt8.self,
             units: [0x0201], of: UInt16.self)
        test(direction: .wordsToUnits,
             words: [0x01, 0x02, 0x03], of: UInt8.self,
             units: [0x0003, 0x0201], of: UInt16.self)
        test(direction: .unitsToWords,
             words: [0x01, 0x02, 0x03, 0x00], of: UInt8.self,
             units: [0x0003, 0x0201], of: UInt16.self)

        test(words: [], of: UInt16.self,
             units: [], of: UInt8.self)
        test(words: [0x1234], of: UInt16.self,
             units: [0x12, 0x34], of: UInt8.self)
        test(words: [0x5678, 0x1234], of: UInt16.self,
             units: [0x12, 0x34, 0x56, 0x78], of: UInt8.self)
        test(direction: .unitsToWords,
             words: [0x789A, 0x3456, 0x12], of: UInt16.self,
             units: [0x12, 0x34, 0x56, 0x78, 0x9A], of: UInt8.self)
        test(direction: .wordsToUnits,
             words: [0x789A, 0x3456, 0x12], of: UInt16.self,
             units: [0x00, 0x12, 0x34, 0x56, 0x78, 0x9A], of: UInt8.self)
    }
}


