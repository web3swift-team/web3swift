// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Web3swift",
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(name: "web3swift", targets: ["web3swift"]),
    ],
  dependencies: [
    .package(url: "https://github.com/attaswift/BigInt.git", from: "3.1.0"),
    .package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.8.4"),
    .package(url: "https://github.com/daltoniam/Starscream.git", from: "3.1.0"),
    .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.0.0"),
    ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(name: "secp256k1"),
    .target(
      name: "web3swift",
      dependencies: ["BigInt", "secp256k1", "PromiseKit", "Starscream", "CryptoSwift"],
      exclude: [
        ]),
    .testTarget(
      name: "web3swiftTests",
      dependencies: ["web3swift"]),
    ]
)
