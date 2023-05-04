// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HBMihoyoAPI",
    products: [
        .library(
            name: "HBMihoyoAPI",
            targets: ["HBMihoyoAPI"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "HBMihoyoAPI",
            dependencies: [],
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
