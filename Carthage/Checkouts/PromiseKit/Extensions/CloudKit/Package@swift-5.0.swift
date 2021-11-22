// swift-tools-version:5.0
import PackageDescription

let name = "PMKCloudKit"

let pkg = Package(name: name)
pkg.products = [
    .library(name: name, targets: [name]),
]
pkg.swiftLanguageVersions = [.v4, .v4_2, .v5]
pkg.dependencies = [
	.package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.0.0")
]

let target: Target = .target(name: name)
target.path = "Sources"
target.exclude = [
	"CKContainer+AnyPromise.h",
	"CKDatabase+AnyPromise.h",
	"\(name).h",
	"CKContainer+AnyPromise.m",
	"CKDatabase+AnyPromise.m"
]
target.dependencies = ["PromiseKit"]

pkg.targets = [target]

pkg.platforms = [
   .macOS(.v10_12), .iOS(.v10), .tvOS(.v10), .watchOS(.v3)
]
