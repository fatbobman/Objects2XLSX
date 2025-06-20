// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Objects2XLSX",
    platforms: [
        // The platforms that this package supports.
        .macOS(.v13), // Minimum macOS version
        .iOS(.v16), // Minimum iOS version
        .tvOS(.v16), // Minimum tvOS version
        .watchOS(.v9), // Minimum watchOS version
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to
        // other packages.
        .library(
            name: "Objects2XLSX",
            targets: ["Objects2XLSX"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-identified-collections.git", from: "1.0.0"),
        .package(url: "https://github.com/fatbobman/SimpleLogger.git", from: "0.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Objects2XLSX",
            dependencies: [
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                .product(name: "SimpleLogger", package: "SimpleLogger"),
            ]),
        .testTarget(
            name: "Objects2XLSXTests",
            dependencies: ["Objects2XLSX"]),
    ],
    swiftLanguageModes: [.v6])
