# 3.1.0 (2018-06-08)

This release contains the following changes:

- Swift 4.1 compatibility for Linux and macOS
- Fix warnings for Swift 4.1

There were no functional changes.

# 3.0.2 (2017-12-25)

This release contains the following packaging fix:

- Fixed product definitions in Package.swift not to create a duplicate library. (Issue #37)

There were no functional changes.

# 3.0.1 (2017-10-10)

This release contains the following bug fixes:

- Issue #27 — changing scope of `BigUInt` methods `kind` and `storage` to be `fileprivate`
- Making `subscript` method of `BigUInt` public

# 3.0.0 (2017-09-07)

This is a major release upgrading BigInt to the new integer protocols introduced in Swift 4 as part of [SE-0104, Protocol-oriented integers][se-0104].

[se-0104]: https://github.com/apple/swift-evolution/blob/master/proposals/0104-improved-integers.md

- Adopting the new protocols involved major, breaking changes throughout the API. These aren't individually listed here.
- The `BigUInt` struct now provides inline storage for big integers that fit inside two words. This optimization speeds up conversions from built-in fixed-width integer types, amongst other frequent operations.
- `BigInt` and `BigUInt` implements the new `Codable` protocol. In both cases, values are encoded in an unkeyed container starting with a string indicating the sign (`"+"` or `"-"`), followed by a sequence of 64-bit unsigned integers representing component words, from least to most significant.
- New method: `BigInt.modulo`, contributed by @FabioTacke.
- `BigUInt` does not implement `Collection` in this release. The collection of words is available in the standard read-only `words` property. Direct public access to collection methods have been removed; if you have been manipulating big integers using collection methods, you need to rewrite your code. If you have a usecase that isn't covered by the public API, please submit a PR adding the missing functionality. (Public read-write access to the underlying storage inside `BigUInt` will not be restored, though.)

BigInt is now part of the Attaswift project. The bundle identifiers in the supplied Xcode project have been updated accordingly.

Note that the URL for the package's Git repository has changed; please update your references.

# 2.2.0 (2017-06-20)

This release contains the following changes:

- `BigUInt.randomIntegerLessThan(_:)` was renamed to `BigUInt.randomInteger(lessThan:)` to match Swift 3 naming conventions. (The old name is still available for compatibility.)
- The `ShiftOperations` protocol was merged into `BigDigit` and removed. It was previously public by accident. (Issue #9)
- `BigInt.modulus(_:,_:)` is a new static method that returns the nonnegative modulus value of its two arguments. (PR #19 by @FabioTacke)


# 2.1.2 (2017-02-03)

This release contains the following bugfix:

- Issue #12: The iOS target in the supplied Xcode project file no longer copies extraneous files
  as resources into the framework bundle. The set of such files included generate-docs.sh, which
  led to App Store rejections for apps that build BigInt using the project file.
  (Thanks to @arrrnas and @wuftymerguftyguff)

No source-level changes were made.

# 2.1.1 (2016-11-23)

This release restores support for iOS 8.0 and macOS 10.9.

# 2.1.0 (2016-11-15)

This release contains the following changes:

- BigInt now uses the SipHash hashing algorithm instead of implementing its own hashing.
- The `SipHash` package has been added as a required dependency. I suggest you use a dependency manager.
- Minimum deployment targets have been bumped to iOS 9.0 and macOS 10.0 to match those of `SipHash`.
- BigInt now requires Swift 3.0.1, included in Xcode 8.1.
- The Xcode project file has been regenerated from scratch, with new names for targets and schemes.
- The bundle identifiers of frameworks generated from the Xcode project file have been changed to `hu.lorentey.BigInt.<platform>`.

# 2.0.1 (2016-11-08)

This release contains the following bugfixes:

- The Swift version number is now correctly set in all targets (PR #7 by @mAu888).
- BigInt now builds on Linux (PR #5 by @ratranqu).
- Building BigInt with the Swift Package Manager bundled with Swift 3.0.1 works correctly.

Additionally, Foundation imports that weren't actually needed were removed from sources.

# 2.0.0 (2016-09-20)

This release updates the project for Swift 3.0, including adapting the API to the new naming conventions.

Further changes:

- The behavior of `BigUInt.gcd` when one of the arguments is zero has been fixed; the result in this case is now equal to the other argument.
- `BigInt` now conforms to `Strideable`, `IntegerArithmetic`, `SignedNumber` and `AbsoluteValuable`.
- `BigUInt` now conforms to `Strideable`, `IntegerArithmetic` and `BitwiseOperations`.

# 1.3.0 (2016-03-23)

This release updates the project to require Swift 2.2 and Xcode 7.3. There have been no other changes.

# 1.2.3 (2016-01-12)

This release adds experimental support for the Swift Package Manager and Swift 2.2.
There were no source-level changes.

# 1.2.2 (2016-01-08)

This release fixes version numbers embedded in build products.

# 1.2.1 (2016-01-07)

This release simply removes the stray LICENSE.md file from iOS builds.


# 1.2.0 (2016-01-06)

With this release, BigInt supports watchOS and tvOS in addition to OS X and iOS. Deployment targets are as follows:

- OS X 10.9
- iOS 8
- watchOS 2
- tvOS 9

BigInt 1.2.0 also features support for both Carthage and CocoaPods deployments.


# 1.1.0 (2016-01-06)

`BigInt` now contains enough functionality to pretend it's a respectable big integer lib. Some of the new additions since 1.0.0:

- Conversion to/from `NSData`
- Vanilla exponentiation
- Algorithm to find the multiplicative inverse of an integer in modulo arithmetic
- An implementation of the Miller-Rabin primality test
- Support for generating random big integers
- Better support for playgrounds in Xcode
- Documentation for all public API
- Fun new calculation samples


# 1.0.0 (2016-01-04)

This is the first release of the BigInt module, providing arbitrary precision integer arithmetic operations
in pure Swift.

Two big integer types are included: `BigUInt` and `BigInt`, the latter being the signed variant.
Both of these are Swift structs with copy-on-write value semantics, and they can be used much
like any other integer type.

The library provides implementations for some of the most frequently useful functions on
big integers, including

- All functionality from `Comparable` and `Hashable`
- The full set of arithmetic operators: `+`, `-`, `*`, `/`, `%`, `+=`, `-=`, `*=`, `/=`, `%=`
- Addition and subtraction have variants that allow for shifting the digits of the second
operand on the fly.
- Unsigned subtraction will trap when the result would be negative. (There are variants
that return an overflow flag.)
- Multiplication uses brute force for numbers up to 1024 digits, then switches to Karatsuba's recursive method.
(This limit is configurable, see `BigUInt.directMultiplicationLimit`.)
A fused multiply-add method is also available.
- Division uses Knuth's Algorithm D, with its 3/2 digits wide quotient approximation.
It will trap when the divisor is zero. `BigUInt.divmod` returns the quotient and
remainder at once; this is faster than calculating them separately.
- Bitwise operators: `~`, `|`, `&`, `^`, `|=`, `&=`, `^=`, plus the following read-only properties:
- `width`: the minimum number of bits required to store the integer,
- `trailingZeroBitCount`: the number of trailing zero bits in the binary representation,
- `leadingZeroBitCount`: the number of leading zero bits (when the last digit isn't full),
- Shift operators: `>>`, `<<`, `>>=`, `<<=`
- Left shifts need to allocate memory to extend the digit array, so it's probably not a good idea
to left shift a `BigUInt` by 2^50 bits.
- Radix conversion between `String`s and big integers up to base 36 (using repeated divisions).
- Big integers use this to implement `StringLiteralConvertible` (in base 10).
- `sqrt(n)`: The square root of an integer (using Newton's method)
- `BigUInt.gcd(n, m)`: The greatest common divisor of two integers (Stein's algorithm)
- `BigUInt.powmod(base, exponent, modulus)`: Modular exponentiation (right-to-left binary method):

The implementations are intended to be reasonably efficient, but they are unlikely to be
competitive with GMP at all, even when I happened to implement an algorithm with same asymptotic
behavior as GMP. (I haven't performed a comparison benchmark, though.)

The library has 100% unit test coverage.
