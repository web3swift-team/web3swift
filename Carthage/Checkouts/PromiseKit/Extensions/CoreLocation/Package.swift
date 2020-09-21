// swift-tools-version:5.1

import PackageDescription

let exclude = ["PMKCoreLocation.h"] + ["CLGeocoder", "CLLocationManager"].flatMap {
    ["\($0)+AnyPromise.m", "\($0)+AnyPromise.h"]
}

let package = Package(
    name: "PMKCoreLocation",
    products: [
        .library(
            name: "PMKCoreLocation",
            targets: ["PMKCoreLocation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.0.0"),
    ],
    targets: [
        .target(
            name: "PMKCoreLocation",
            dependencies: ["PromiseKit"],
            path: "Sources",
            exclude: exclude),
        .testTarget(
            name: "PMKCoreLocationTests",
            dependencies: ["PMKCoreLocation"],
            path: "Tests"),
    ]
)
