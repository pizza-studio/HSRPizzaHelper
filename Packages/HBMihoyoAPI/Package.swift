// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HBMihoyoAPI",
    platforms: [
        .iOS(.v16), .watchOS(.v9), .macOS(.v13),
    ],
    products: [
        .library(
            name: "HBMihoyoAPI",
            targets: ["HBMihoyoAPI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/Defaults", from: "8.2.0"),
        .package(url: "./Packages/DefaultsKeys", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "HBMihoyoAPI",
            dependencies: [
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "DefaultsKeys", package: "DefaultsKeys"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "HBMihoyoAPITests",
            dependencies: ["HBMihoyoAPI"]
        ),
    ]
)
