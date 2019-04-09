// swift-tools-version:4.2

import PackageDescription

let pkg = Package(name: "PMKAlamofire")
pkg.products = [
    .library(name: "PMKAlamofire", targets: ["PMKAlamofire"]),
]
pkg.dependencies = [
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "4.0.0")),
    .package(url: "https://github.com/mxcl/PromiseKit.git", .upToNextMajor(from: "6.0.0"))
]
pkg.swiftLanguageVersions = [.v3, .v4, .v4_2]

let target: Target = .target(name: "PMKAlamofire")
target.path = "Sources"
target.exclude = ["Tests"]
target.dependencies = [
    "PromiseKit",
    "Alamofire"
]

pkg.targets = [target]
