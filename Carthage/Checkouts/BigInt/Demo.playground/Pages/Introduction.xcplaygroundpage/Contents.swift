//: # Introduction
//:
//: The `BigInt` module provides a `BigInt` type that implements an [https://en.wikipedia.org/wiki/Arbitrary-precision_arithmetic](integer type of arbitrary width).
//: These work much like `Int`s, but they don't have a preset maximum value---so they will never overflow.
//: The only practical limit to their capacity is the amount of memory & address space that your computer has, and the
//: amount of time you're willing to spend waiting for results---when their operands are truly huge,
//: big integer operations can take a long time to execute.
//: (`BigInt` represents integers in base 2^64, storing digits in an `Array<UInt64>`, so the theoretical
//: maximum value it can store is (2^64)^`Int.max` - 1.)
import Foundation
import BigInt
//: `BigInt` has several interesting initializers, but for now, the simplest way to create big integers is to use integer
//: or string literals. The latter is useful when you want to create a number that's larger than `UIntMax.max`:
let a: BigInt = 123
let b: BigInt = 12345678
let c: BigInt = 1234567890123456
let d: BigInt = "12345678901234567890123456789012345678901234567890123456789012345678"
//: To work with `BigInt`s, you use the same arithmetic operators as you do with everyday `Int` values:
a + b
b - a
-b
a * b
a * b * c
a * b * c * d

d / c
d % c
d / (c * c)
d / (c * c * c)
d / (c * c * c * c)
//: [Next](@next)
