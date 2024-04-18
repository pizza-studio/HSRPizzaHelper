// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HBEnkaAPI",
    platforms: [
        .iOS(.v16), .watchOS(.v9), .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HBEnkaAPI",
            targets: ["HBEnkaAPI", "EnkaSwiftUIViews"]
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
            ],
            resources: [
                .process("EnkaAssets/hsr_jsons/honker_avatars.json"),
                .process("EnkaAssets/hsr_jsons/honker_characters.json"),
                .process("EnkaAssets/hsr_jsons/honker_meta.json"),
                .process("EnkaAssets/hsr_jsons/honker_ranks.json"),
                .process("EnkaAssets/hsr_jsons/honker_relics.json"),
                .process("EnkaAssets/hsr_jsons/honker_skills.json"),
                .process("EnkaAssets/hsr_jsons/honker_skilltree.json"),
                .process("EnkaAssets/hsr_jsons/honker_weps.json"),
                .process("EnkaAssets/hsr_jsons/hsr.json"),
            ]
        ),
        .target(
            name: "EnkaSwiftUIViews",
            dependencies: [
                "HBEnkaAPI",
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "DefaultsKeys", package: "DefaultsKeys"),
            ]
        ),
        .testTarget(
            name: "HBEnkaAPITests",
            dependencies: ["HBEnkaAPI", "EnkaSwiftUIViews"]
        ),
    ]
)
