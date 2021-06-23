// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Web3swift",
    platforms: [
        .macOS(.v10_12), .iOS(.v11),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "web3swift", targets: ["web3swift"]),
    ],
    
    dependencies: [
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.2.0"),
        .package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.15.3"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.4"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "secp256k1"),
        .target(name: "libscrypt", sources: ["libscrypt/crypto_scrypt-nosse.c",
                                             "libscrypt/sha256.c",
                                             "libscrypt/slowequals.c",
            ]),
        .target(
            name: "web3swift",
            dependencies: ["BigInt", "secp256k1", "PromiseKit", "Starscream", "CryptoSwift", "libscrypt"],
            exclude: [
            ]),
        .testTarget(
            name: "web3swiftTests",
            dependencies: ["web3swift"]),
    ]
)
