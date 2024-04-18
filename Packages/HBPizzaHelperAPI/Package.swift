// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HBPizzaHelperAPI",
    platforms: [
        .iOS(.v16), .watchOS(.v9), .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "HBPizzaHelperAPI",
            targets: ["HBPizzaHelperAPI"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/sindresorhus/Defaults", from: "7.3.1"),
        .package(url: "./Packages/DefaultsKeys", from: "1.0.0"),
        .package(url: "./Packages/HBMihoyoAPI", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "HBPizzaHelperAPI",
            dependencies: [
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "DefaultsKeys", package: "DefaultsKeys"),
                .product(name: "HBMihoyoAPI", package: "HBMihoyoAPI"),
            ]
        ),
        .testTarget(
            name: "HBPizzaHelperAPITests",
            dependencies: ["HBPizzaHelperAPI"]
        ),
    ]
)
