// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Objects2XLSXDemo",
    platforms: [
        .macOS(.v13), // Minimum macOS version
        .iOS(.v16), // Minimum iOS version
        .tvOS(.v16), // Minimum tvOS version
        .watchOS(.v9), // Minimum watchOS version
    ],
    products: [
        // Demo executable product
        .executable(
            name: "Objects2XLSXDemo",
            targets: ["Objects2XLSXDemo"]
        ),
    ],
    dependencies: [
        // Reference to the parent Objects2XLSX library
        .package(path: "../"),
    ],
    targets: [
        // Demo executable target
        .executableTarget(
            name: "Objects2XLSXDemo",
            dependencies: [
                .product(name: "Objects2XLSX", package: "Objects2XLSX"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)