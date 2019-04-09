# SipHash

[![Swift 4.0](https://img.shields.io/badge/Swift-4-blue.svg)](https://swift.org)
[![License](https://img.shields.io/badge/licence-MIT-blue.svg)](https://github.com/attaswift/SipHash/blob/master/LICENSE.md)
[![Platform](https://img.shields.io/badge/platforms-macOS%20∙%20iOS%20∙%20watchOS%20∙%20tvOS%20∙%20Linux-blue.svg)](https://developer.apple.com/platforms/)

[![Build Status](https://travis-ci.org/attaswift/SipHash.svg?branch=master)](https://travis-ci.org/attaswift/SipHash)
[![Code Coverage](https://codecov.io/github/attaswift/SipHash/coverage.svg?branch=master)](https://codecov.io/github/attaswift/SipHash?branch=master)

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)
[![CocoaPod Version](https://img.shields.io/cocoapods/v/SipHash.svg)](http://cocoapods.org/pods/SipHash)

`SipHash` is a pure Swift implementation of the [SipHash] hashing algorithm designed by
Jean-Philippe Aumasson and Daniel J. Bernstein in 2012:

[SipHash]: https://131002.net/siphash

> SipHash is a family of pseudorandom functions (a.k.a. keyed hash functions) optimized for speed on short messages.
>
> Target applications include network traffic authentication and defense against hash-flooding DoS attacks.
>
> SipHash is secure, fast, and simple (for real):
> - SipHash is simpler and faster than previous cryptographic algorithms (e.g. MACs based on universal hashing)
> - SipHash is competitive in performance with insecure non-cryptographic algorithms (e.g. MurmurHash)
>
> -- <cite>[131002.net][SipHash]</cite>

SipHash has a variety of flavors; this package implements the one called SipHash-2-4.

Note that the Swift Standard Library [already includes an implementation][stdlib] of SipHash-2-4 and SipHash-1-3;
however, the APIs are currently private and not available for use outside of stdlib. This package provides an
independent implementation that's available for use in third-party code.

[stdlib]: https://github.com/apple/swift/blob/master/stdlib/public/core/SipHash.swift.gyb

The current release of SipHash requires Swift 4.

## Sample Code

```swift
import SipHash

// `SipHashable` is like `Hashable`, but simpler.
struct Book: SipHashable {
    let title: String
    let pageCount: Int

    // You need to implement this method instead of `hashValue`.
    func appendHashes(to hasher: inout SipHasher) {
         // Simply append the fields you want to include in the hash.
         hasher.append(title)
         hasher.append(pageCount)
    }

    static func ==(left: Book, right: Book) -> Bool {
         return left.title == right.title && left.pageCount == right.pageCount
    }
}

// You can now use Books in sets or as dictionary keys.
let book = Book(title: "The Colour of Magic", pageCount: 206)
let books: Set<Book> = [book]


// If you prefer to do so, you may also create & use hashers directly.
var hasher = SipHasher()
hasher.add(book)
hasher.add(42)
// Finalizing the hasher extracts the hash value and invalidates it.
let hash = hasher.finalize()
```

## Why Would I Use SipHash?

Writing a good implementation of `hashValue` is hard, even if we just need to combine the values of a couple of fields.
We need to come up with a deterministic function that blends the field values well, producing a fixed-width
result without too many collisions on typical inputs. But how many collisions are "too many"? Do we even know what
our "typical inputs" look like? For me, the answer to both of these questions is usually "I have absolutely no idea",
and I bet you have the same problem.

Thus, verifying that our `hashValue` implementations work well is an exercise in frustration.

We need to somehow check the properties of the hash function by looking at its behavior given various inputs.
It is easy enough to write tests for the requirement that equal values have equal `hashValues`.
But verifying that the hash has few collisions requires making some assumptions on the
statistical properties of "typical" inputs -- and even if we'd be somehow confident enough to do that, writing the code
to do it is way too complicated.

Instead of rolling your own ad-hoc hash function, why not just use an algorithm designed specifically to blend data
into a hash? Using a standardized algorithm means we don't need to worry about collision behavior any more: if the
algorithm was designed well, we'll always have good results.

The SipHash algorithm is a particularly good choice for hashing. It implements a 64-bit cryptographic
message-authentication code (MAC) with a 256-bit internal state initialized from a 128-bit secret key that's (typically)
randomly generated for each execution of the binary.
SipHash is designed to protect against hash collision attacks, while remaining simple to use and fast.
It is already used by Perl, Python, Ruby, Rust, and even Swift itself -- which is why the documentation of `Hashable`
explicitly warns that the value returned by `hashValue` may be different across executions.

The standard library already implements SipHash, but the implementation is private. (It is technically available
for use, but it is not formally part of the stdlib API, and it is subject to change/removal across even point releases.)
I expect a refactored version of stdlib's SipHash will become available as public API in a future Swift release.
But while we're waiting for that, this package provides an alternative implementation that is available today.

## Is this code full of bugs?

Indubitably. Please report all bugs you find!

The package has 100% unit test coverage. Unfortunately this doesn't tell you much about its reliability in practice.

The test suite verifies that the package generates values that match the test vectors supplied by SipHash's original
authors, which makes me reasonably confident that this package implements SipHash correctly.
Obviously, your mileage may vary.

## Reference docs

[Nicely formatted reference docs][docs] are available courtesy of [Jazzy].

[docs]: https://attaswift.github.io/SipHash/
[Jazzy]: https://github.com/realm/jazzy

## Installation

### CocoaPods

If you use CocoaPods, you can start using `SipHash` by including it as a dependency in your `Podfile`:

```
pod 'SipHash', '~> 1.2'
```

### Carthage

For Carthage, add the following line to your `Cartfile`:

```
github "attaswift/SipHash" ~> 1.2
```

### Swift Package Manager

For Swift Package Manager, add `SipHash` to the dependencies list inside your `Package.swift` file:

```
import PackageDescription

let package = Package(
    name: "MyPackage",
    dependencies: [
        .Package(url: "https://github.com/attaswift/SipHash.git", from: "1.2.1")
    ]
)
```

### Standalone Development

If you don't use a dependency manager, you need to clone this repo somewhere near your project, and add a reference to `SipHash.xcodeproj` to your project's `xcworkspace`. You can put the clone of SipHash wherever you like on disk, but it is a good idea to set it up as a submodule of your app's top-level Git repository.

To link your application binary with SipHash, just add `SipHash.framework` from the SipHash project to the Embedded Binaries section of your app target's General page in Xcode. As long as the SipHash project file is referenced in your workspace, this framework will be listed in the "Choose items to add" sheet that opens when you click on the "+" button of your target's Embedded Binaries list.

There is no need to do any additional setup beyond adding the framework targets to Embedded Binaries.
