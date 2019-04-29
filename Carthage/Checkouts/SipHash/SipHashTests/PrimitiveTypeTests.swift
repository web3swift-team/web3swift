//
//  PrimitiveTypeTests.swift
//  SipHash
//
//  Created by Károly Lőrentey on 2016-11-14.
//  Copyright © 2016-2017 Károly Lőrentey.
//

import XCTest
@testable import SipHash

class PrimitiveTypeTests: XCTestCase {
    func testBoolTrue() {
        let tests: [(Bool, [UInt8])] = [
            (false, [0]),
            (true, [1])
        ]
        for (value, data) in tests {
            var hash1 = SipHasher()
            hash1.append(value)
            let h1 = hash1.finalize()

            var hash2 = SipHasher()
            data.withUnsafeBufferPointer { buffer in
                hash2.append(UnsafeRawBufferPointer(buffer))
            }
            let h2 = hash2.finalize()

            XCTAssertEqual(h1, h2, "Mismatching hash for \(value)")
        }
    }

    func testInt() {
        let tests: [(Int, [UInt8])]
        switch MemoryLayout<UInt>.size {
        case 8:
            tests = [
                (0, [0, 0, 0, 0, 0, 0, 0, 0]),
                (1, [1, 0, 0, 0, 0, 0, 0, 0]),
                (0x0123456789abcdef, [0xef, 0xcd, 0xab, 0x89, 0x67, 0x45, 0x23, 0x01]),
                (Int.max, [255, 255, 255, 255, 255, 255, 255, 127]),
                (-1, [255, 255, 255, 255, 255, 255, 255, 255]),
                (Int.min, [0, 0, 0, 0, 0, 0, 0, 128]),
            ]
        case 4:
            tests = [
                (0, [0, 0, 0, 0]),
                (1, [1, 0, 0, 0]),
                (0x12345678, [0x78, 0x56, 0x34, 0x12]),
                (Int.max, [255, 255, 255, 127]),
                (-1, [255, 255, 255, 255]),
                (Int.min, [0, 0, 0, 128]),
            ]
        default:
            fatalError()
        }

        for (value, data) in tests {
            var hash1 = SipHasher()
            hash1.append(value.littleEndian)
            let h1 = hash1.finalize()

            var hash2 = SipHasher()
            data.withUnsafeBufferPointer { buffer in
                hash2.append(UnsafeRawBufferPointer(buffer))
            }
            let h2 = hash2.finalize()

            XCTAssertEqual(h1, h2, "Mismatching hash for \(value)")
        }
    }

    func testUInt() {
        let tests: [(UInt, [UInt8])]
        switch MemoryLayout<UInt>.size {
        case 8:
            tests = [
                (0, [0, 0, 0, 0, 0, 0, 0, 0]),
                (1, [1, 0, 0, 0, 0, 0, 0, 0]),
                (0x0123456789abcdef, [0xef, 0xcd, 0xab, 0x89, 0x67, 0x45, 0x23, 0x01]),
                (UInt.max, [255, 255, 255, 255, 255, 255, 255, 255]),
            ]
        case 4:
            tests = [
                (0, [0, 0, 0, 0]),
                (1, [1, 0, 0, 0]),
                (0x12345678, [0x78, 0x56, 0x34, 0x12]),
                (0xffffffff, [255, 255, 255, 255])
            ]
        default:
            fatalError()
        }

        for (value, data) in tests {
            var hash1 = SipHasher()
            hash1.append(value.littleEndian)
            let h1 = hash1.finalize()

            var hash2 = SipHasher()
            data.withUnsafeBufferPointer { buffer in
                hash2.append(UnsafeRawBufferPointer(buffer))
            }
            let h2 = hash2.finalize()

            XCTAssertEqual(h1, h2, "Mismatching hash for \(value)")
        }
    }

    func testInt64() {
        let tests: [(Int64, [UInt8])] = [
            (0, [0, 0, 0, 0, 0, 0, 0, 0]),
            (1, [1, 0, 0, 0, 0, 0, 0, 0]),
            (0x0123456789abcdef, [0xef, 0xcd, 0xab, 0x89, 0x67, 0x45, 0x23, 0x01]),
            (Int64.max, [255, 255, 255, 255, 255, 255, 255, 127]),
            (-1, [255, 255, 255, 255, 255, 255, 255, 255]),
            (Int64.min, [0, 0, 0, 0, 0, 0, 0, 128]),
            ]
        for (value, data) in tests {
            var hash1 = SipHasher()
            hash1.append(value.littleEndian)
            let h1 = hash1.finalize()

            var hash2 = SipHasher()
            data.withUnsafeBufferPointer { buffer in
                hash2.append(UnsafeRawBufferPointer(buffer))
            }
            let h2 = hash2.finalize()

            XCTAssertEqual(h1, h2, "Mismatching hash for \(value)")
        }
    }

    func testUInt64() {
        let tests: [(UInt64, [UInt8])] = [
            (0, [0, 0, 0, 0, 0, 0, 0, 0]),
            (1, [1, 0, 0, 0, 0, 0, 0, 0]),
            (0x0123456789abcdef, [0xef, 0xcd, 0xab, 0x89, 0x67, 0x45, 0x23, 0x01]),
            (UInt64.max, [255, 255, 255, 255, 255, 255, 255, 255]),
            ]
        for (value, data) in tests {
            var hash1 = SipHasher()
            hash1.append(value.littleEndian)
            let h1 = hash1.finalize()

            var hash2 = SipHasher()
            data.withUnsafeBufferPointer { buffer in
                hash2.append(UnsafeRawBufferPointer(buffer))
            }
            let h2 = hash2.finalize()

            XCTAssertEqual(h1, h2, "Mismatching hash for \(value)")
        }
    }

    func testInt32() {
        let tests: [(Int32, [UInt8])] = [
            (0, [0, 0, 0, 0]),
            (1, [1, 0, 0, 0]),
            (0x12345678, [0x78, 0x56, 0x34, 0x12]),
            (Int32.max, [255, 255, 255, 127]),
            (-1, [255, 255, 255, 255]),
            (Int32.min, [0, 0, 0, 128]),
        ]
        for (value, data) in tests {
            var hash1 = SipHasher()
            hash1.append(value.littleEndian)
            let h1 = hash1.finalize()

            var hash2 = SipHasher()
            data.withUnsafeBufferPointer { buffer in
                hash2.append(UnsafeRawBufferPointer(buffer))
            }
            let h2 = hash2.finalize()

            XCTAssertEqual(h1, h2, "Mismatching hash for \(value)")
        }
    }

    func testUInt32() {
        let tests: [(UInt32, [UInt8])] = [
            (0, [0, 0, 0, 0]),
            (1, [1, 0, 0, 0]),
            (0x12345678, [0x78, 0x56, 0x34, 0x12]),
            (0xffffffff, [255, 255, 255, 255])
        ]
        for (value, data) in tests {
            var hash1 = SipHasher()
            hash1.append(value.littleEndian)
            let h1 = hash1.finalize()

            var hash2 = SipHasher()
            data.withUnsafeBufferPointer { buffer in
                hash2.append(UnsafeRawBufferPointer(buffer))
            }
            let h2 = hash2.finalize()

            XCTAssertEqual(h1, h2, "Mismatching hash for \(value)")
        }
    }

    func testInt16() {
        let tests: [(Int16, [UInt8])] = [
            (0, [0, 0]),
            (1, [1, 0]),
            (0x1234, [0x34, 0x12]),
            (0x7fff, [255, 127]),
            (-1, [0xff, 0xff]),
            (-42, [214, 0xff]),
            (Int16.min, [0x00, 0x80])
        ]
        for (value, data) in tests {
            var hash1 = SipHasher()
            hash1.append(value.littleEndian)
            let h1 = hash1.finalize()

            var hash2 = SipHasher()
            data.withUnsafeBufferPointer { buffer in
                hash2.append(UnsafeRawBufferPointer(buffer))
            }
            let h2 = hash2.finalize()

            XCTAssertEqual(h1, h2, "Mismatching hash for \(value)")
        }
    }

    func testUInt16() {
        let tests: [(UInt16, [UInt8])] = [
            (0, [0, 0]),
            (1, [1, 0]),
            (0x1234, [0x34, 0x12]),
            (0xffff, [255, 255])
        ]
        for (value, data) in tests {
            var hash1 = SipHasher()
            hash1.append(value.littleEndian)
            let h1 = hash1.finalize()

            var hash2 = SipHasher()
            data.withUnsafeBufferPointer { buffer in
                hash2.append(UnsafeRawBufferPointer(buffer))
            }
            let h2 = hash2.finalize()

            XCTAssertEqual(h1, h2, "Mismatching hash for \(value)")
        }
    }

    func testInt8() {
        let tests: [(Int8, [UInt8])] = [
            (0, [0]),
            (1, [1]),
            (42, [42]),
            (127, [127]),
            (-1, [255]),
            (-42, [214]),
            (-128, [128])
        ]
        for (value, data) in tests {
            var hash1 = SipHasher()
            hash1.append(value)
            let h1 = hash1.finalize()

            var hash2 = SipHasher()
            data.withUnsafeBufferPointer { buffer in
                hash2.append(UnsafeRawBufferPointer(buffer))
            }
            let h2 = hash2.finalize()

            XCTAssertEqual(h1, h2, "Mismatching hash for \(value)")
        }
    }

    func testUInt8() {
        let tests: [(UInt8, [UInt8])] = [
            (0, [0]),
            (1, [1]),
            (42, [42]),
            (255, [255])
        ]
        for (value, data) in tests {
            var hash1 = SipHasher()
            hash1.append(value)
            let h1 = hash1.finalize()

            var hash2 = SipHasher()
            data.withUnsafeBufferPointer { buffer in
                hash2.append(UnsafeRawBufferPointer(buffer))
            }
            let h2 = hash2.finalize()

            XCTAssertEqual(h1, h2, "Mismatching hash for \(value)")
        }
    }

    func testFloat() {
        let zeroA: Int = {
            var h = SipHasher()
            h.append(0.0 as Float)
            return h.finalize()
        }()

        let zeroB: Int = {
            var h = SipHasher()
            h.append(-0.0 as Float)
            return h.finalize()
        }()

        XCTAssertEqual(zeroA, zeroB, "+0.0 and -0.0 should have the same hash value")

        let oneHash: Int = {
            var h = SipHasher()
            h.append(1.0 as Float)
            return h.finalize()
        }()
        let oneExpected: Int = {
            var h = SipHasher()
            let d = Array<UInt8>([0, 0, 128, 63])
            d.withUnsafeBufferPointer { b in
                h.append(UnsafeRawBufferPointer(b))
            }
            return h.finalize()
        }()
        XCTAssertEqual(oneHash, oneExpected)
    }

    func testDouble() {
        let zeroA: Int = {
            var h = SipHasher()
            h.append(0.0 as Double)
            return h.finalize()
        }()

        let zeroB: Int = {
            var h = SipHasher()
            h.append(-0.0 as Double)
            return h.finalize()
        }()

        XCTAssertEqual(zeroA, zeroB, "+0.0 and -0.0 should have the same hash value")

        let oneHash: Int = {
            var h = SipHasher()
            h.append(1.0 as Double)
            return h.finalize()
        }()
        let oneExpected: Int = {
            var h = SipHasher()
            let d = Array<UInt8>([0, 0, 0, 0, 0, 0, 240, 63])
            d.withUnsafeBufferPointer { b in
                h.append(UnsafeRawBufferPointer(b))
            }
            return h.finalize()
        }()
        XCTAssertEqual(oneHash, oneExpected)
    }

    #if arch(i386) || arch(x86_64)
    func testFloat80() {
        let f1: Float80 = 0.0
        let f2: Float80 = -0.0

        XCTAssertEqual(f1, f2)

        let zeroA: Int = {
            var h = SipHasher()
            h.append(f1)
            return h.finalize()
        }()

        let zeroB: Int = {
            var h = SipHasher()
            h.append(f2)
            return h.finalize()
        }()

        XCTAssertEqual(zeroA, zeroB, "+0.0 and -0.0 should have the same hash value")

        let oneHash: Int = {
            var h = SipHasher()
            h.append(1.0 as Float80)
            return h.finalize()
        }()
        let oneExpected: Int = {
            var h = SipHasher()
            let d = Array<UInt8>([0, 0, 0, 0, 0, 0, 0, 128, 255, 63])
            d.withUnsafeBufferPointer { b in
                h.append(UnsafeRawBufferPointer(b))
            }
            return h.finalize()
        }()
        XCTAssertEqual(oneHash, oneExpected)
    }
    #endif

    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    func testCGFloat() {
        let zeroA: Int = {
            var h = SipHasher()
            h.append(0.0 as CGFloat)
            return h.finalize()
        }()

        let zeroB: Int = {
            var h = SipHasher()
            h.append(-0.0 as CGFloat)
            return h.finalize()
        }()

        XCTAssertEqual(zeroA, zeroB, "+0.0 and -0.0 should have the same hash value")

        let oneHash: Int = {
            var h = SipHasher()
            h.append(1.0 as CGFloat)
            return h.finalize()
        }()
        let oneExpected: Int = {
            var h = SipHasher()
            let d: Array<UInt8>
            if CGFloat.NativeType.self == Double.self {
                d = [0, 0, 0, 0, 0, 0, 240, 63]
            }
            else if CGFloat.NativeType.self == Float.self {
                d = [0, 0, 128, 63]
            }
            else {
                fatalError()
            }
            d.withUnsafeBufferPointer { b in
                h.append(UnsafeRawBufferPointer(b))
            }
            return h.finalize()
        }()
        XCTAssertEqual(oneHash, oneExpected)

    }
    #endif

    func testOptional_nil() {
        let expected: Int = {
            var hasher = SipHasher()
            hasher.append(0 as UInt8)
            return hasher.finalize()
        }()

        let actual: Int = {
            var hasher = SipHasher()
            hasher.append(nil as Int?)
            return hasher.finalize()
        }()

        XCTAssertEqual(actual, expected)
    }

    func testOptional_nonnil() {
        let expected: Int = {
            var hasher = SipHasher()
            hasher.append(1 as UInt8)
            hasher.append(42)
            return hasher.finalize()
        }()

        let actual: Int = {
            var hasher = SipHasher()
            hasher.append(42 as Int?)
            return hasher.finalize()
        }()

        XCTAssertEqual(actual, expected)
    }
    //
    // you have to manually register linux tests here :-(
    //
    static var allTests = [
      ("testBoolTrue",        testBoolTrue),
      ("testInt",             testInt),
      ("testUInt",            testUInt),
      ("testInt64",           testInt64),
      ("testUInt64",          testUInt64),
      ("testInt32",           testInt32),
      ("testUInt32",          testUInt32),
      ("testInt16",           testInt16),
      ("testUInt16",          testUInt16),
      ("testInt8",            testInt8),
      ("testUInt8",           testUInt8),
      ("testFloat",           testFloat),
      ("testDouble",          testDouble),
      ("testFloat80",         testFloat80),
      // ("testCGFloat",         testCGFloat), // missing in Linux
      ("testOptional_nil",    testOptional_nil),
      ("testOptional_nonnil", testOptional_nonnil),
    ]
}
