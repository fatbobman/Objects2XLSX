// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Objects2XLSX",
    platforms: [
        // The platforms that this package supports.
        .macOS(.v12),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to
        // other packages.
        .library(
            name: "Objects2XLSX",
            targets: ["Objects2XLSX"])
    ],
    dependencies: [
        .package(url: "https://github.com/fatbobman/SimpleLogger.git", from: "0.7.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Objects2XLSX",
            dependencies: [
                .product(name: "SimpleLogger", package: "SimpleLogger")
            ]),
        .testTarget(
            name: "Objects2XLSXTests",
            dependencies: ["Objects2XLSX"])
    ],
    swiftLanguageModes: [.v6])
