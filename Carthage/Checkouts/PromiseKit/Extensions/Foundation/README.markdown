# PromiseKit Foundation Extensions ![Build Status]

This project adds promises to the Swift Foundation framework.

We support iOS, tvOS, watchOS, macOS and Linux, Swift 3.0, 3.1, 3.2, 4.0, 4.1,
4.2 and 5.0.

## CococaPods

```ruby
pod "PromiseKit/Foundation", "~> 6.0"
```

The extensions are built into `PromiseKit.framework` thus nothing else is
needed.

## Carthage

> Note we can no longer support Swift 3 with Carthage due to Xcode 10.2 dropping
it and our only being able to provide a single `.xcodeproj`.

```ruby
github "PromiseKit/Foundation" ~> 3.0
```

The extensions are built into their own framework:

```swift
// swift
import PromiseKit
import PMKFoundation
```

```objc
// objc
@import PromiseKit;
@import PMKFoundation;
```

## SwiftPM

```swift
package.dependencies.append(.package(url: "https://github.com/PromiseKit/Foundation.git", from: "3.0.0"))
```


[Build Status]: https://travis-ci.org/PromiseKit/Foundation.svg?branch=master
