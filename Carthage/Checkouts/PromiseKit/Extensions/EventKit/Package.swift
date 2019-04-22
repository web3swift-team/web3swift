// swift-tools-version:4.2

import PackageDescription

let name = "PMKEventKit"

let pkg = Package(name: name)
pkg.products = [
    .library(name: name, targets: [name]),
]
pkg.swiftLanguageVersions = [.v4, .v4_2]
pkg.dependencies = [
	.package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.0.0")
]

let target: Target = .target(name: name)
target.path = "Sources"
target.exclude = ["Tests"]
target.dependencies = ["PromiseKit"]

pkg.targets = [target]