// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Objects2XLSX",
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Objects2XLSX",
      targets: ["Objects2XLSX"],
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/tadija/AEXML.git", from: "4.7.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Objects2XLSX",
      dependencies: [
        .product(name: "AEXML", package: "AEXML"),
      ],
    ),
    .testTarget(
      name: "Objects2XLSXTests",
      dependencies: ["Objects2XLSX"],
    ),
  ],
  swiftLanguageModes: [.v6],
)
