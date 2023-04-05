// swift-tools-version: 5.5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Web3swift",
    platforms: [
        .macOS(.v10_15), .iOS(.v13)
    ],
    products: [
        .library(name: "web3swift", targets: ["web3swift"])
    ],
    dependencies: [
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.5.1")
    ],
    targets: [
        .target(name: "secp256k1"),
        .target(
            name: "Web3Core",
            dependencies: ["BigInt", "secp256k1", "CryptoSwift"]
        ),
        .target(
            name: "web3swift",
            dependencies: ["Web3Core", "BigInt", "secp256k1"],
            resources: [
                .copy("./Browser/browser.js"),
                .copy("./Browser/browser.min.js"),
                .copy("./Browser/wk.bridge.min.js")
            ]
        ),
        .testTarget(
            name: "localTests",
            dependencies: ["web3swift"],
            path: "Tests/web3swiftTests/localTests",
            resources: [
                .copy("../../../TestToken/Helpers/SafeMath/SafeMath.sol"),
                .copy("../../../TestToken/Helpers/TokenBasics/ERC20.sol"),
                .copy("../../../TestToken/Helpers/TokenBasics/IERC20.sol"),
                .copy("../../../TestToken/Token/Web3SwiftToken.sol")
            ]
        ),
        .testTarget(
            name: "remoteTests",
            dependencies: ["web3swift"],
            path: "Tests/web3swiftTests/remoteTests",
            resources: [
                .copy("../../../TestToken/Helpers/SafeMath/SafeMath.sol"),
                .copy("../../../TestToken/Helpers/TokenBasics/ERC20.sol"),
                .copy("../../../TestToken/Helpers/TokenBasics/IERC20.sol"),
                .copy("../../../TestToken/Token/Web3SwiftToken.sol")
            ]
        )
    ]
)
