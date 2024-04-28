// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SRGFKit",
    platforms: [
        .iOS(.v16), .watchOS(.v9), .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SRGFKit",
            targets: ["SRGFKit"]
        ),
    ],
    dependencies: [
        .package(url: "./Packages/HBMihoyoAPI", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SRGFKit",
            dependencies: [
                .product(name: "HBMihoyoAPI", package: "HBMihoyoAPI"),
            ],
            resources: [
                .process("Assets/gacha_meta.json"),
            ]
        ),
        .testTarget(
            name: "SRGFKitTests",
            dependencies: ["SRGFKit"]
        ),
    ]
)
