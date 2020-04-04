//
//  ProfileTests.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2015-12-31.
//  Copyright © 2016-2017 Károly Lőrentey.
//

import XCTest
import BigInt

#if Profile

func factorial(_ n: Int) -> BigUInt {
    var fact = BigUInt(1)
    for i in BigUInt.Word(1) ... BigUInt.Word(n) {
        fact.multiply(byWord: i)
    }
    return fact
}

class ProfileTests: XCTestCase {
    typealias Word = BigUInt.Word

    func measure_(autostart: Bool = true, block: @escaping ()->Void) {
        var round = 0
        self.measureMetrics(type(of: self).defaultPerformanceMetrics, automaticallyStartMeasuring: autostart) {
            print("Round \(round) started")
            block()
            round += 1
        }
    }

    func testFibonacciAddition() {
        var n1 = BigUInt(1)
        var n2 = BigUInt(1)
        self.measure {
            n1 = BigUInt(1)
            n2 = BigUInt(1)
            for i in 0..<200000 {
                if i & 1 == 0 {
                    n1 += n2
                }
                else {
                    n2 += n1
                }
            }
        }
        noop(n1)
        noop(n2)
    }

    func checkFactorial(fact: BigUInt, n: Int, file: StaticString = #file, line: UInt = #line) {
        var remaining = fact
        for i in 1...n {
            let (div, mod) = remaining.quotientAndRemainder(dividingBy: BigUInt(i))
            XCTAssertEqual(mod, 0, "for divisor = \(i)", file: file, line: line)
            remaining = div
        }
        XCTAssertEqual(remaining, 1, file: file, line: line)
    }

    func testDivisionOfFactorial() {
        let n = 32767
        let fact = factorial(n)
        self.measure {
            checkFactorial(fact: fact, n: n)
        }
    }

    func testPrintingFactorial() {
        let n = 32767
        let fact = factorial(n)
        var string: String = ""
        self.measure {
            string = String(fact, radix: 10)
        }
        XCTAssertEqual(BigUInt(string, radix: 10), fact)
    }

    func testReadingFactorial() {
        let n = 32767
        let fact = factorial(n)
        let string = String(fact, radix: 10)
        print(string)
        self.measure {
            XCTAssertEqual(BigUInt(string, radix: 10), fact)
        }
    }

    func testFactorial() {
        var fact = BigUInt()
        let n = 32767
        self.measure {
            fact = factorial(n)
        }
        checkFactorial(fact: fact, n: n)
    }

    func testBalancedFactorial() {
        func balancedFactorial(level: Int, offset: Int = 0) -> BigUInt {
            if level == 0 {
                return BigUInt(offset == 0 ? 1 : offset)
            }
            let a = balancedFactorial(level: level - 1, offset: 2 * offset)
            let b = balancedFactorial(level: level - 1, offset: 2 * offset + 1)
            return a * b
        }

        let power = 15

        var fact = BigUInt()
        self.measure {
            fact = balancedFactorial(level: power)
        }
        checkFactorial(fact: fact, n: ((1 as Int) << power) - 1)
    }

    func testDivision() {
        var divisors: [BigUInt] = []
        func balancedFactorial(level: Int, offset: Int = 0) -> BigUInt {
            if level == 0 {
                return BigUInt(offset == 0 ? 1 : offset)
            }
            let a = balancedFactorial(level: level - 1, offset: 2 * offset)
            let b = balancedFactorial(level: level - 1, offset: 2 * offset + 1)
            let p = a * b
            if level >= 10 { divisors.append(p) }
            return p
        }

        let power = 14

        let fact = balancedFactorial(level: power)
        print("Performing \(divisors.count) divisions with digit counts (\(fact.words.count) / (\(divisors[0].words.count)...\(divisors[divisors.count - 1].words.count))")
        var divs: [BigUInt] = []
        var mods: [BigUInt] = []
        divs.reserveCapacity(divisors.count)
        mods.reserveCapacity(divisors.count)
        self.measure_(autostart: false) {
            divs.removeAll()
            mods.removeAll()
            self.startMeasuring()
            for divisor in divisors {
                let (div, mod) = fact.quotientAndRemainder(dividingBy: divisor)
                divs.append(div)
                mods.append(mod)
            }
            self.stopMeasuring()
        }
        for i in 0..<mods.count {
            XCTAssertEqual(mods[i], 0, "div = \(divs[i]), mod = \(mods[i]) for divisor = \(divisors[i])")
        }
        checkFactorial(fact: fact, n: ((1 as Int) << power) - 1)
    }

    func randomBigUInts(_ count: Int, seed: UInt, withMaxWords words: Int) -> [BigUInt] {
        var rnd = PseudoRandomNumbers(seed: seed)
        return (0 ..< count).map { _ in BigUInt(words: (0 ..< words).map { _ in rnd.next()! }) }
    }

    func testSquareRoot() {
        let numbers = randomBigUInts(1000, seed: 42, withMaxWords: 60)
        var roots: [BigUInt] = []
        self.measure {
            roots.removeAll()
            for number in numbers {
                let root = number.squareRoot()
                roots.append(root)
            }
        }

        for i in 0..<numbers.count {
            XCTAssertLessThanOrEqual(roots[i] * roots[i], numbers[i])
            XCTAssertGreaterThan((roots[i] + 1) * (roots[i] + 1), numbers[i])
        }
    }

    func testModularExponentiation() {
        let m15 = (BigUInt(1) << 1279) - BigUInt(1)
        let tests = randomBigUInts(24, seed: 42, withMaxWords: 19)
        self.measure {
            for test in tests {
                assert(test < m15)
                let x = test.power(m15, modulus: m15)
                XCTAssertEqual(x, test)
            }
        }
    }

    func testGCD() {
        // This test relies on the fact that if fibo(i) is the ith Fibonacci number, then
        // gcd(fibo(i), fibo(j)) == fibo(gcd(i, j))
        let limit = 80_000
        var fibo: [BigUInt] = [0, 1]
        for i in 0 ..< limit - 2 {
            fibo.append(fibo[i] + fibo[i + 1])
        }

        let count = 10

        let j = limit / 2
        let bj = BigUInt(j)

        self.measure {
            for i in limit - count ..< limit {
                let bi = BigUInt(i)
                let g1 = fibo[i].greatestCommonDivisor(with: fibo[j])
                let g2 = Int(bi.greatestCommonDivisor(with: bj).words[0])
                XCTAssertEqual(g1, fibo[g2])
            }
        }
    }

    func testMersennePrimes() {
        self.measure {
            // OEIS has all known Mersenne exponents: https://oeis.org/A000043
            // But only a fool would trust those sinister mathmaticists; so let's verify they tell the truth this time
            let exponents: Set<Int> = [2, 3, 5, 7, 13, 17, 19, 31, 61, 89, 107, 127, 521, 607, 1279, 2203, 2281]
            for exp in 1...1000 {
                let mersenne = BigUInt(1) << exp - 1
                XCTAssertEqual(mersenne.isPrime(), exponents.contains(exp), "\(exp) smells fishy")
            }
            // Seems legit. You win this round, evil magmaticians
        }
    }
}
#endif
