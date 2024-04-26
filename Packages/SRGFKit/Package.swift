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
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SRGFKit"
        ),
        .testTarget(
            name: "SRGFKitTests",
            dependencies: ["SRGFKit"]
        ),
    ]
)
