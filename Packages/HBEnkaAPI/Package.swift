// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HBEnkaAPI",
    platforms: [
        .iOS(.v15), .watchOS(.v9), .macOS(.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HBEnkaAPI",
            targets: ["HBEnkaAPI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/Defaults", from: "7.3.1"),
        .package(url: "./Packages/DefaultsKeys", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HBEnkaAPI",
            dependencies: [
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "DefaultsKeys", package: "DefaultsKeys"),
            ]
        ),
        .testTarget(
            name: "HBEnkaAPITests",
            dependencies: ["HBEnkaAPI"]
        ),
    ]
)
