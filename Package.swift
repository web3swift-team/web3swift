// swift-tools-version:5.3
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
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.15.4"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.4"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.2"),
    ],
	targets: {
		var targets: [Target] = [
			.target(name: "secp256k1"),
			.testTarget(
				name: "web3swiftTests",
				dependencies: ["web3swift"])
		]
		
#if os(iOS)
		// iOS build platform
		targets.append(contentsOf: [
			.target(
				name: "web3swift",
				dependencies: ["BigInt", "secp256k1", "PromiseKit", "Starscream", "CryptoSwift"]
			)
		])
#else
		// not iOS build platform, e.g. macOS, linux
		targets.append(contentsOf: [
			.target(
				name: "web3swift",
				dependencies: ["BigInt", "secp256k1", "PromiseKit", "Starscream", "CryptoSwift"],
				exclude: ["Browser"]
			)
		])
#endif
		return targets
	}()
)
