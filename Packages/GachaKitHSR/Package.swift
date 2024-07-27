// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GachaKitHSR",
    platforms: [
        .iOS(.v16), .watchOS(.v9), .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GachaKitHSR",
            targets: ["GachaKitHSR"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/Defaults", from: "7.3.1"),
        .package(url: "./Packages/DefaultsKeys", from: "1.0.0"),
        .package(url: "https://github.com/pizza-studio/GachaMetaGenerator", from: "2.0.3"),
        .package(url: "./Packages/HBMihoyoAPI", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GachaKitHSR",
            dependencies: [
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "DefaultsKeys", package: "DefaultsKeys"),
                .product(name: "GachaMetaDB", package: "GachaMetaGenerator"),
                .product(name: "HBMihoyoAPI", package: "HBMihoyoAPI"),
            ],
            resources: []
        ),
        .testTarget(
            name: "GachaKitHSRTests",
            dependencies: ["GachaKitHSR"]
        ),
    ]
)
