// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EnkaKitHSR",
    platforms: [
        .iOS(.v16), .watchOS(.v9), .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EnkaKitHSR",
            targets: ["EnkaKitHSR", "EnkaSwiftUIViews"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/Defaults", from: "8.2.0"),
        .package(url: "./Packages/DefaultsKeys", from: "1.0.0"),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "4.1.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EnkaKitHSR",
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
                .process("EnkaAssets/RealNameDict.json"),
                .process("EnkaAssets/StarRailScore.json"),
                .process("EnkaAssets/Wallpapers.json"),
            ]
        ),
        .target(
            name: "EnkaSwiftUIViews",
            dependencies: [
                "EnkaKitHSR",
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "DefaultsKeys", package: "DefaultsKeys"),
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
            ]
        ),
        .testTarget(
            name: "EnkaKitHSRTests",
            dependencies: ["EnkaKitHSR", "EnkaSwiftUIViews"]
        ),
    ]
)
