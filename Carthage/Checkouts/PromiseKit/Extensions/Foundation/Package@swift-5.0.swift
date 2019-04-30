// swift-tools-version:5.0

import PackageDescription

let pkg = Package(name: "PMKFoundation")
pkg.products = [
    .library(name: "PMKFoundation", targets: ["PMKFoundation"]),
]
pkg.dependencies = [
    .package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.8.3")
]
pkg.swiftLanguageVersions = [.v4, .v4_2, .v5]

let target: Target = .target(name: "PMKFoundation")
target.path = "Sources"
target.exclude = ["NSNotificationCenter", "NSTask", "NSURLSession"].flatMap {
    ["\($0)+AnyPromise.m", "\($0)+AnyPromise.h"]
}
target.exclude.append("PMKFoundation.h")

target.dependencies = [
    "PromiseKit"
]

#if os(Linux)
target.exclude += [
    "afterlife.swift",
    "NSObject+Promise.swift"
]
#endif

pkg.targets = [target]

pkg.platforms = [
   .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2)
]
