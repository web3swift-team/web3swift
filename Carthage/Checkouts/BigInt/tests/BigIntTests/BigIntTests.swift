//
//  BigIntTests.swift
//  BigIntTests
//
//  Created by Károly Lőrentey on 2015-12-26.
//  Copyright © 2016-2017 Károly Lőrentey.
//

import XCTest
@testable import BigInt

class BigIntTests: XCTestCase {
    typealias Word = BigInt.Word

    func testSigns() {
        XCTAssertTrue(BigInt.isSigned)

        XCTAssertEqual(BigInt().signum(), 0)
        XCTAssertEqual(BigInt(-2).signum(), -1)
        XCTAssertEqual(BigInt(-1).signum(), -1)
        XCTAssertEqual(BigInt(0).signum(), 0)
        XCTAssertEqual(BigInt(1).signum(), 1)
        XCTAssertEqual(BigInt(2).signum(), 1)

        XCTAssertEqual(BigInt(words: [0, Word.max]).signum(), -1)
        XCTAssertEqual(BigInt(words: [0, 1]).signum(), 1)
    }

    func testInit() {
        XCTAssertEqual(BigInt().sign, .plus)
        XCTAssertEqual(BigInt().magnitude, 0)

        XCTAssertEqual(BigInt(Int64.min).sign, .minus)
        XCTAssertEqual(BigInt(Int64.min).magnitude - 1, BigInt(Int64.max).magnitude)

        let zero = BigInt(0)
        XCTAssertTrue(zero.magnitude.isZero)
        XCTAssertEqual(zero.sign, .plus)

        let minusOne = BigInt(-1)
        XCTAssertEqual(minusOne.magnitude, 1)
        XCTAssertEqual(minusOne.sign, .minus)

        let b: BigInt = 42
        XCTAssertEqual(b.magnitude, 42)
        XCTAssertEqual(b.sign, .plus)

        XCTAssertEqual(BigInt(UInt64.max).magnitude, BigUInt(UInt64.max))

        let b2: BigInt = "+300"
        XCTAssertEqual(b2.magnitude, 300)
        XCTAssertEqual(b2.sign, .plus)

        let b3: BigInt = "-300"
        XCTAssertEqual(b3.magnitude, 300)
        XCTAssertEqual(b3.sign, .minus)

        XCTAssertNil(BigInt("Not a number"))

        XCTAssertEqual(BigInt(unicodeScalarLiteral: UnicodeScalar(52)), BigInt(4))
        XCTAssertEqual(BigInt(extendedGraphemeClusterLiteral: "4"), BigInt(4))

        XCTAssertEqual(BigInt(words: []), 0)
        XCTAssertEqual(BigInt(words: [1, 1]), BigInt(1) << Word.bitWidth + 1)
        XCTAssertEqual(BigInt(words: [1, 2]), BigInt(2) << Word.bitWidth + 1)
        XCTAssertEqual(BigInt(words: [0, Word.max]), -(BigInt(1) << Word.bitWidth))
        XCTAssertEqual(BigInt(words: [1, Word.max]), -BigInt(Word.max))
        XCTAssertEqual(BigInt(words: [1, Word.max, Word.max]), -BigInt(Word.max))
    }

    func testInit_FloatingPoint() {
        XCTAssertEqual(BigInt(42.0), 42)
        XCTAssertEqual(BigInt(-42.0), -42)
        XCTAssertEqual(BigInt(42.5), 42)
        XCTAssertEqual(BigInt(-42.5), -42)
        XCTAssertEqual(BigInt(exactly: 42.0), 42)
        XCTAssertEqual(BigInt(exactly: -42.0), -42)
        XCTAssertNil(BigInt(exactly: 42.5))
        XCTAssertNil(BigInt(exactly: -42.5))
        XCTAssertNil(BigInt(exactly: Double.leastNormalMagnitude))
        XCTAssertNil(BigInt(exactly: Double.leastNonzeroMagnitude))
        XCTAssertNil(BigInt(exactly: Double.infinity))
        XCTAssertNil(BigInt(exactly: Double.nan))
        XCTAssertNil(BigInt(exactly: Double.signalingNaN))
        XCTAssertEqual(BigInt(clamping: -42), -42)
        XCTAssertEqual(BigInt(clamping: 42), 42)
        XCTAssertEqual(BigInt(truncatingIfNeeded: -42), -42)
        XCTAssertEqual(BigInt(truncatingIfNeeded: 42), 42)
    }

    func testConversionToFloatingPoint() {
        func test<F: BinaryFloatingPoint>(_ a: BigInt, _ b: F, file: StaticString = #file, line: UInt = #line)
        where F.RawExponent: FixedWidthInteger, F.RawSignificand: FixedWidthInteger {
                let f = F(a)
                XCTAssertEqual(f, b, file: file, line: line)
        }

        for i in -100 ..< 100 {
            test(BigInt(i), Double(i))
        }
        test(BigInt(0x5A5A5A), 0x5A5A5A as Double)
        test(BigInt(1) << 64, 0x1p64 as Double)
        test(BigInt(0x5A5A5A) << 64, 0x5A5A5Ap64 as Double)
        test(BigInt(1) << 1023, 0x1p1023 as Double)
        test(BigInt(10) << 1020, 0xAp1020 as Double)
        test(BigInt(1) << 1024, Double.infinity)
        test(BigInt(words: convertWords([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xFFFFFFFFFFFFF800, 0])),
             Double.greatestFiniteMagnitude)

        for i in -100 ..< 100 {
            test(BigInt(i), Float(i))
        }
        test(BigInt(0x5A5A5A), 0x5A5A5A as Float)
        test(BigInt(1) << 64, 0x1p64 as Float)
        test(BigInt(0x5A5A5A) << 64, 0x5A5A5Ap64 as Float)
        test(BigInt(1) << 1023, 0x1p1023 as Float)
        test(BigInt(10) << 1020, 0xAp1020 as Float)
        test(BigInt(1) << 1024, Float.infinity)
        test(BigInt(words: convertWords([0, 0xFFFFFF0000000000, 0])),
             Float.greatestFiniteMagnitude)
    }

    func testTwosComplement() {
        func check(_ a: [Word], _ b: [Word], file: StaticString = #file, line: UInt = #line) {
            var a2 = a
            a2.twosComplement()
            XCTAssertEqual(a2, b, file: file, line: line)
            var b2 = b
            b2.twosComplement()
            XCTAssertEqual(b2, a, file: file, line: line)
        }
        check([1], [Word.max])
        check([Word.max], [1])
        check([1, 1], [Word.max, Word.max - 1])
        check([(1 as Word) << (Word.bitWidth - 1)], [(1 as Word) << (Word.bitWidth - 1)])
        check([0], [0])
        check([0, 0, 1], [0, 0, Word.max])
        check([0, 0, 1, 0, 1], [0, 0, Word.max, Word.max, Word.max - 1])
        check([0, 0, 1, 1], [0, 0, Word.max, Word.max - 1])
        check([0, 0, 1, 0, 0, 0], [0, 0, Word.max, Word.max, Word.max, Word.max])
    }

    func testSign() {
        XCTAssertEqual(BigInt(-1).sign, .minus)
        XCTAssertEqual(BigInt(0).sign, .plus)
        XCTAssertEqual(BigInt(1).sign, .plus)
    }

    func testBitWidth() {
        XCTAssertEqual(BigInt(0).bitWidth, 0)
        XCTAssertEqual(BigInt(1).bitWidth, 2)
        XCTAssertEqual(BigInt(-1).bitWidth, 2)
        XCTAssertEqual((BigInt(1) << 64).bitWidth, Word.bitWidth + 2)
        XCTAssertEqual(BigInt(Word.max).bitWidth, Word.bitWidth + 1)
        XCTAssertEqual(BigInt(Word.max >> 1).bitWidth, Word.bitWidth)
    }

    func testTrailingZeroBitCount() {
        XCTAssertEqual(BigInt(0).trailingZeroBitCount, 0)
        XCTAssertEqual(BigInt(1).trailingZeroBitCount, 0)
        XCTAssertEqual(BigInt(-1).trailingZeroBitCount, 0)
        XCTAssertEqual(BigInt(2).trailingZeroBitCount, 1)
        XCTAssertEqual(BigInt(Word.max).trailingZeroBitCount, 0)
        XCTAssertEqual(BigInt(-2).trailingZeroBitCount, 1)
        XCTAssertEqual(-BigInt(Word.max).trailingZeroBitCount, 0)
        XCTAssertEqual((BigInt(1) << 100).trailingZeroBitCount, 100)
        XCTAssertEqual(((-BigInt(1)) << 100).trailingZeroBitCount, 100)
    }

    func testWords() {
        XCTAssertEqual(Array(BigInt(0).words), [])
        XCTAssertEqual(Array(BigInt(1).words), [1])
        XCTAssertEqual(Array(BigInt(-1).words), [Word.max])

        let highBit = (1 as Word) << (Word.bitWidth - 1)
        XCTAssertEqual(Array(BigInt(highBit).words), [highBit, 0])
        XCTAssertEqual(Array((-BigInt(highBit)).words), [highBit, Word.max])

        XCTAssertEqual(Array(BigInt(sign: .plus, magnitude: BigUInt(words: [Word.max])).words), [Word.max, 0])
        XCTAssertEqual(Array(BigInt(sign: .minus, magnitude: BigUInt(words: [Word.max])).words), [1, Word.max])

        XCTAssertEqual(Array((BigInt(1) << Word.bitWidth).words), [0, 1])
        XCTAssertEqual(Array((-(BigInt(1) << Word.bitWidth)).words), [0, Word.max])

        XCTAssertEqual(Array((BigInt(42) << Word.bitWidth).words), [0, 42])
        XCTAssertEqual(Array((-(BigInt(42) << Word.bitWidth)).words), [0, Word.max - 41])

        let huge = BigUInt(words: [0, 1, 2, 3, 4])
        XCTAssertEqual(Array(BigInt(sign: .plus, magnitude: huge).words), [0, 1, 2, 3, 4])
        XCTAssertEqual(Array(BigInt(sign: .minus, magnitude: huge).words),
                       [0, Word.max, ~2, ~3, ~4] as [Word])


        XCTAssertEqual(BigInt(1).words[100], 0)
        XCTAssertEqual(BigInt(-1).words[100], Word.max)

        XCTAssertEqual(BigInt(words: [0, 1, 2, 3, 4]).words.indices, 0 ..< 5)
    }

    func testComplement() {
        XCTAssertEqual(~BigInt(-3), BigInt(2))
        XCTAssertEqual(~BigInt(-2), BigInt(1))
        XCTAssertEqual(~BigInt(-1), BigInt(0))
        XCTAssertEqual(~BigInt(0), BigInt(-1))
        XCTAssertEqual(~BigInt(1), BigInt(-2))
        XCTAssertEqual(~BigInt(2), BigInt(-3))

        XCTAssertEqual(~BigInt(words: [1, 2, 3, 4]),
                       BigInt(words: [Word.max - 1, Word.max - 2, Word.max - 3, Word.max - 4]))
        XCTAssertEqual(~BigInt(words: [Word.max - 1, Word.max - 2, Word.max - 3, Word.max - 4]),
                       BigInt(words: [1, 2, 3, 4]))
    }

    func testBinaryAnd() {
        XCTAssertEqual(BigInt(1) & BigInt(2), 0)
        XCTAssertEqual(BigInt(-1) & BigInt(2), 2)
        XCTAssertEqual(BigInt(-1) & BigInt(words: [1, 2, 3, 4]), BigInt(words: [1, 2, 3, 4]))
        XCTAssertEqual(BigInt(-1) & -BigInt(words: [1, 2, 3, 4]), -BigInt(words: [1, 2, 3, 4]))
        XCTAssertEqual(BigInt(Word.max) & BigInt(words: [1, 2, 3, 4]), BigInt(1))
        XCTAssertEqual(BigInt(Word.max) & BigInt(words: [Word.max, 1, 2]), BigInt(Word.max))
        XCTAssertEqual(BigInt(Word.max) & BigInt(words: [Word.max, Word.max - 1]), BigInt(Word.max))
    }

    func testBinaryOr() {
        XCTAssertEqual(BigInt(1) | BigInt(2), 3)
        XCTAssertEqual(BigInt(-1) | BigInt(2), -1)
        XCTAssertEqual(BigInt(-1) | BigInt(words: [1, 2, 3, 4]), -1)
        XCTAssertEqual(BigInt(-1) | -BigInt(words: [1, 2, 3, 4]), -1)
        XCTAssertEqual(BigInt(Word.max) | BigInt(words: [1, 2, 3, 4]),
                       BigInt(words: [Word.max, 2, 3, 4]))
        XCTAssertEqual(BigInt(Word.max) | BigInt(words: [1, 2, 3, Word.max]),
                       BigInt(words: [Word.max, 2, 3, Word.max]))
        XCTAssertEqual(BigInt(Word.max) | BigInt(words: [Word.max - 1, Word.max - 1]),
                       BigInt(words: [Word.max, Word.max - 1]))
    }

    func testBinaryXor() {
        XCTAssertEqual(BigInt(1) ^ BigInt(2), 3)
        XCTAssertEqual(BigInt(-1) ^ BigInt(2), -3)
        XCTAssertEqual(BigInt(1) ^ BigInt(-2), -1)
        XCTAssertEqual(BigInt(-1) ^ BigInt(-2), 1)
        XCTAssertEqual(BigInt(-1) ^ BigInt(words: [1, 2, 3, 4]),
                       BigInt(words: [~1, ~2, ~3, ~4] as [Word]))
        XCTAssertEqual(BigInt(-1) ^ -BigInt(words: [1, 2, 3, 4]),
                       BigInt(words: [0, 2, 3, 4]))
        XCTAssertEqual(BigInt(Word.max) ^ BigInt(words: [1, 2, 3, 4]),
                       BigInt(words: [~1, 2, 3, 4] as [Word]))
        XCTAssertEqual(BigInt(Word.max) ^ BigInt(words: [1, 2, 3, Word.max]),
                       BigInt(words: [~1, 2, 3, Word.max] as [Word]))
        XCTAssertEqual(BigInt(Word.max) ^ BigInt(words: [Word.max - 1, Word.max - 1]),
                       BigInt(words: [1, Word.max - 1]))
    }

    func testConversionToString() {
        let b = BigInt(-256)
        XCTAssertEqual(b.description, "-256")
        XCTAssertEqual(String(b, radix: 16, uppercase: true), "-100")
        let pql = b.playgroundDescription as? String
        if pql == "-256 (9 bits)" {}
        else {
            XCTFail("Unexpected Playground Quick Look: \(pql ?? "nil")")
        }
    }

    func testComparable() {
        XCTAssertTrue(BigInt(1) == BigInt(1))
        XCTAssertFalse(BigInt(1) == BigInt(-1))

        XCTAssertTrue(BigInt(1) < BigInt(42))
        XCTAssertFalse(BigInt(1) < -BigInt(42))
        XCTAssertTrue(BigInt(-1) < BigInt(42))
        XCTAssertTrue(BigInt(-42) < BigInt(-1))
    }

    func testHashable() {
        XCTAssertEqual(BigInt(1).hashValue, BigInt(1).hashValue)
        XCTAssertNotEqual(BigInt(1).hashValue, BigInt(2).hashValue)
        XCTAssertNotEqual(BigInt(42).hashValue, BigInt(-42).hashValue)
        XCTAssertNotEqual(BigInt(1).hashValue, BigInt(-1).hashValue)
    }

    func testStrideable() {
        XCTAssertEqual(BigInt(1).advanced(by: 100), 101)
        XCTAssertEqual(BigInt(Word.max).advanced(by: 1 as BigInt.Stride), BigInt(1) << Word.bitWidth)

        XCTAssertEqual(BigInt(Word.max).distance(to: BigInt(words: [0, 1])), BigInt(1))
        XCTAssertEqual(BigInt(words: [0, 1]).distance(to: BigInt(Word.max)), BigInt(-1))
        XCTAssertEqual(BigInt(0).distance(to: BigInt(words: [0, 1])), BigInt(words: [0, 1]))
    }

    func compare(_ a: Int, _ b: Int, r: Int, file: StaticString = #file, line: UInt = #line, op: (BigInt, BigInt) -> BigInt) {
        XCTAssertEqual(op(BigInt(a), BigInt(b)), BigInt(r), file: file, line: line)
    }

    func testAddition() {
        compare(0, 0, r: 0, op: +)
        compare(1, 2, r: 3, op: +)
        compare(1, -2, r: -1, op: +)
        compare(-1, 2, r: 1, op: +)
        compare(-1, -2, r: -3, op: +)
        compare(2, -1, r: 1, op: +)
    }

    func testNegation() {
        XCTAssertEqual(-BigInt(0), BigInt(0))
        XCTAssertEqual(-BigInt(1), BigInt(-1))
        XCTAssertEqual(-BigInt(-1), BigInt(1))
    }

    func testSubtraction() {
        compare(0, 0, r: 0, op: -)
        compare(2, 1, r: 1, op: -)
        compare(2, -1, r: 3, op: -)
        compare(-2, 1, r: -3, op: -)
        compare(-2, -1, r: -1, op: -)
    }

    func testMultiplication() {
        compare(0, 0, r: 0, op: *)
        compare(0, 1, r: 0, op: *)
        compare(1, 0, r: 0, op: *)
        compare(0, -1, r: 0, op: *)
        compare(-1, 0, r: 0, op: *)
        compare(2, 3, r: 6, op: *)
        compare(2, -3, r: -6, op: *)
        compare(-2, 3, r: -6, op: *)
        compare(-2, -3, r: 6, op: *)
    }

    func testQuotientAndRemainder() {
        func compare(_ a: BigInt, _ b: BigInt, r: (BigInt, BigInt), file: StaticString = #file, line: UInt = #line) {
            let actual = a.quotientAndRemainder(dividingBy: b)
            XCTAssertEqual(actual.quotient, r.0, "quotient", file: file, line: line)
            XCTAssertEqual(actual.remainder, r.1, "remainder", file: file, line: line)
        }

        compare(0, 1, r: (0, 0))
        compare(0, -1, r: (0, 0))
        compare(7, 4, r: (1, 3))
        compare(7, -4, r: (-1, 3))
        compare(-7, 4, r: (-1, -3))
        compare(-7, -4, r: (1, -3))
    }

    func testDivision() {
        compare(0, 1, r: 0, op: /)
        compare(0, -1, r: 0, op: /)
        compare(7, 4, r: 1, op: /)
        compare(7, -4, r: -1, op: /)
        compare(-7, 4, r: -1, op: /)
        compare(-7, -4, r: 1, op: /)
    }

    func testRemainder() {
        compare(0, 1, r: 0, op: %)
        compare(0, -1, r: 0, op: %)
        compare(7, 4, r: 3, op: %)
        compare(7, -4, r: 3, op: %)
        compare(-7, 4, r: -3, op: %)
        compare(-7, -4, r:-3, op: %)
    }

    func testModulo() {
        XCTAssertEqual(BigInt(22).modulus(5), 2)
        XCTAssertEqual(BigInt(-22).modulus(5), 3)
        XCTAssertEqual(BigInt(22).modulus(-5), 2)
        XCTAssertEqual(BigInt(-22).modulus(-5), 3)
    }

    func testStrideableRequirements() {
        XCTAssertEqual(5, BigInt(3).advanced(by: 2))
        XCTAssertEqual(2, BigInt(3).distance(to: 5))
    }

    func testAbsoluteValuableRequirements() {
        XCTAssertEqual(BigInt(5), abs(5 as BigInt))
        XCTAssertEqual(BigInt(0), abs(0 as BigInt))
        XCTAssertEqual(BigInt(5), abs(-5 as BigInt))
    }

    func testIntegerArithmeticRequirements() {
        XCTAssertEqual(3 as Int64, Int64(3 as BigInt))
        XCTAssertEqual(-3 as Int64, Int64(-3 as BigInt))
    }

    func testAssignmentOperators() {
        var a = BigInt(1)
        a += 13
        XCTAssertEqual(a, 14)

        a -= 7
        XCTAssertEqual(a, 7)

        a *= 3
        XCTAssertEqual(a, 21)

        a /= 2
        XCTAssertEqual(a, 10)

        a %= 7
        XCTAssertEqual(a, 3)
    }

    func testExponentiation() {
        XCTAssertEqual(BigInt(0).power(0), 1)
        XCTAssertEqual(BigInt(0).power(1), 0)
        XCTAssertEqual(BigInt(0).power(2), 0)

        XCTAssertEqual(BigInt(1).power(-2), 1)
        XCTAssertEqual(BigInt(1).power(-1), 1)
        XCTAssertEqual(BigInt(1).power(0), 1)
        XCTAssertEqual(BigInt(1).power(1), 1)
        XCTAssertEqual(BigInt(1).power(2), 1)

        XCTAssertEqual(BigInt(2).power(-4), 0)
        XCTAssertEqual(BigInt(2).power(-3), 0)
        XCTAssertEqual(BigInt(2).power(-2), 0)
        XCTAssertEqual(BigInt(2).power(-1), 0)
        XCTAssertEqual(BigInt(2).power(0), 1)
        XCTAssertEqual(BigInt(2).power(1), 2)
        XCTAssertEqual(BigInt(2).power(2), 4)
        XCTAssertEqual(BigInt(2).power(3), 8)
        XCTAssertEqual(BigInt(2).power(4), 16)

        XCTAssertEqual(BigInt(-1).power(-4), 1)
        XCTAssertEqual(BigInt(-1).power(-3), -1)
        XCTAssertEqual(BigInt(-1).power(-2), 1)
        XCTAssertEqual(BigInt(-1).power(-1), -1)
        XCTAssertEqual(BigInt(-1).power(0), 1)
        XCTAssertEqual(BigInt(-1).power(1), -1)
        XCTAssertEqual(BigInt(-1).power(2), 1)
        XCTAssertEqual(BigInt(-1).power(3), -1)
        XCTAssertEqual(BigInt(-1).power(4), 1)

        XCTAssertEqual(BigInt(-2).power(-4), 0)
        XCTAssertEqual(BigInt(-2).power(-3), 0)
        XCTAssertEqual(BigInt(-2).power(-2), 0)
        XCTAssertEqual(BigInt(-2).power(-1), 0)
        XCTAssertEqual(BigInt(-2).power(0), 1)
        XCTAssertEqual(BigInt(-2).power(1), -2)
        XCTAssertEqual(BigInt(-2).power(2), 4)
        XCTAssertEqual(BigInt(-2).power(3), -8)
        XCTAssertEqual(BigInt(-2).power(4), 16)
    }

    func testModularExponentiation() {
        for i in -5 ... 5 {
            for j in -5 ... 5 {
                for m in [-7, -5, -3, -2, -1, 1, 2, 3, 5, 7] {
                    guard i != 0 || j >= 0 else { continue }
                    XCTAssertEqual(BigInt(i).power(BigInt(j), modulus: BigInt(m)),
                                   BigInt(i).power(j).modulus(BigInt(m)),
                                   "\(i), \(j), \(m)")
                }
            }
        }
    }

    func testSquareRoot() {
        XCTAssertEqual(BigInt(0).squareRoot(), 0)
        XCTAssertEqual(BigInt(1).squareRoot(), 1)
        XCTAssertEqual(BigInt(2).squareRoot(), 1)
        XCTAssertEqual(BigInt(3).squareRoot(), 1)
        XCTAssertEqual(BigInt(4).squareRoot(), 2)
        XCTAssertEqual(BigInt(5).squareRoot(), 2)
        XCTAssertEqual(BigInt(9).squareRoot(), 3)
    }

    func testGCD() {
        XCTAssertEqual(BigInt(12).greatestCommonDivisor(with: 15), 3)
        XCTAssertEqual(BigInt(-12).greatestCommonDivisor(with: 15), 3)
        XCTAssertEqual(BigInt(12).greatestCommonDivisor(with: -15), 3)
        XCTAssertEqual(BigInt(-12).greatestCommonDivisor(with: -15), 3)
    }

    func testInverse() {
        for base in -100 ... 100 {
            for modulus in [2, 3, 4, 5] {
                let base = BigInt(base)
                let modulus = BigInt(modulus)
                if let inverse = base.inverse(modulus) {
                    XCTAssertEqual((base * inverse).modulus(modulus), 1, "\(base), \(modulus), \(inverse)")
                }
                else {
                    XCTAssertGreaterThan(BigInt(base).greatestCommonDivisor(with: modulus), 1, "\(base), \(modulus)")
                }
            }
        }
    }

    func testPrimes() {
        XCTAssertFalse(BigInt(-7).isPrime())
        XCTAssertTrue(BigInt(103).isPrime())

        XCTAssertFalse(BigInt(-3_215_031_751).isStrongProbablePrime(7))
        XCTAssertTrue(BigInt(3_215_031_751).isStrongProbablePrime(7))
        XCTAssertFalse(BigInt(3_215_031_751).isPrime())
    }

    func testShifts() {
        XCTAssertEqual(BigInt(1) << Word.bitWidth, BigInt(words: [0, 1]))
        XCTAssertEqual(BigInt(-1) << Word.bitWidth, BigInt(words: [0, Word.max]))
        XCTAssertEqual(BigInt(words: [0, 1]) << -Word.bitWidth, BigInt(1))

        XCTAssertEqual(BigInt(words: [0, 1]) >> Word.bitWidth, BigInt(1))
        XCTAssertEqual(BigInt(-1) >> Word.bitWidth, BigInt(-1))
        XCTAssertEqual(BigInt(1) >> Word.bitWidth, BigInt(0))
        XCTAssertEqual(BigInt(words: [0, Word.max]) >> Word.bitWidth, BigInt(-1))
        XCTAssertEqual(BigInt(1) >> -Word.bitWidth, BigInt(words: [0, 1]))

        XCTAssertEqual(BigInt(1) &<< BigInt(Word.bitWidth), BigInt(words: [0, 1]))
        XCTAssertEqual(BigInt(words: [0, 1]) &>> BigInt(Word.bitWidth), BigInt(1))
    }

    func testShiftAssignments() {

        var a: BigInt = 1
        a <<= Word.bitWidth
        XCTAssertEqual(a, BigInt(words: [0, 1]))

        a = -1
        a <<= Word.bitWidth
        XCTAssertEqual(a, BigInt(words: [0, Word.max]))

        a = BigInt(words: [0, 1])
        a <<= -Word.bitWidth
        XCTAssertEqual(a, 1)

        a = BigInt(words: [0, 1])
        a >>= Word.bitWidth
        XCTAssertEqual(a, 1)

        a = -1
        a >>= Word.bitWidth
        XCTAssertEqual(a, -1)

        a = 1
        a >>= Word.bitWidth
        XCTAssertEqual(a, 0)

        a = BigInt(words: [0, Word.max])
        a >>= Word.bitWidth
        XCTAssertEqual(a, BigInt(-1))

        a = 1
        a >>= -Word.bitWidth
        XCTAssertEqual(a, BigInt(words: [0, 1]))

        a = 1
        a &<<= BigInt(Word.bitWidth)
        XCTAssertEqual(a, BigInt(words: [0, 1]))

        a = BigInt(words: [0, 1])
        a &>>= BigInt(Word.bitWidth)
        XCTAssertEqual(a, BigInt(1))

    }

    func testCodable() {
        func test(_ a: BigInt, file: StaticString = #file, line: UInt = #line) {
            do {
                let json = try JSONEncoder().encode(a)
                print(String(data: json, encoding: .utf8)!)
                let b = try JSONDecoder().decode(BigInt.self, from: json)
                XCTAssertEqual(a, b, file: file, line: line)
            }
            catch let error {
                XCTFail("Error thrown: \(error.localizedDescription)", file: file, line: line)
            }
        }
        test(0)
        test(1)
        test(-1)
        test(0x0102030405060708)
        test(-0x0102030405060708)
        test(BigInt(1) << 64)
        test(-BigInt(1) << 64)
        test(BigInt(words: [1, 2, 3, 4, 5, 6, 7]))
        test(-BigInt(words: [1, 2, 3, 4, 5, 6, 7]))

        XCTAssertThrowsError(try JSONDecoder().decode(BigUInt.self, from: "[\"*\", 1]".data(using: .utf8)!)) { error in
            guard let error = error as? DecodingError else { XCTFail("Expected a decoding error"); return }
            guard case .dataCorrupted(let context) = error else { XCTFail("Expected a dataCorrupted error"); return }
            XCTAssertEqual(context.debugDescription, "Invalid big integer sign")
        }
    }
    //
    // you have to manually register linux tests here :-(
    //
    static var allTests = [
        ("testSigns", testSigns),
        ("testInit", testInit),
        ("testInit_FloatingPoint", testInit_FloatingPoint),
        ("testConversionToFloatingPoint", testConversionToFloatingPoint),
        ("testTwosComplement", testTwosComplement),
        ("testSign", testSign),
        ("testBitWidth", testBitWidth),
        ("testTrailingZeroBitCount", testTrailingZeroBitCount),
        ("testWords", testWords),
        ("testComplement", testComplement),
        ("testBinaryAnd", testBinaryAnd),
        ("testBinaryOr", testBinaryOr),
        ("testBinaryXor", testBinaryXor),
        ("testConversionToString", testConversionToString),
        ("testComparable", testComparable),
        ("testHashable", testHashable),
        ("testStrideable", testStrideable),
        ("testAddition", testAddition),
        ("testNegation", testNegation),
        ("testSubtraction", testSubtraction),
        ("testMultiplication", testMultiplication),
        ("testQuotientAndRemainder", testQuotientAndRemainder),
        ("testDivision", testDivision),
        ("testRemainder", testRemainder),
        ("testModulo", testModulo),
        ("testStrideableRequirements", testStrideableRequirements),
        ("testAbsoluteValuableRequirements", testAbsoluteValuableRequirements),
        ("testIntegerArithmeticRequirements", testIntegerArithmeticRequirements),
        ("testAssignmentOperators", testAssignmentOperators),
        ("testExponentiation", testExponentiation),
        ("testModularExponentiation", testModularExponentiation),
        ("testSquareRoot", testSquareRoot),
        ("testGCD", testGCD),
        ("testInverse", testInverse),
        ("testPrimes", testPrimes),
        ("testShifts", testShifts),
        ("testShiftAssignments", testShiftAssignments),
        ("testCodable", testCodable),
    ]
}
