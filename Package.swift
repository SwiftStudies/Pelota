// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pelota",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "TiledKit",
            targets: ["TiledKit"]),
        .library(
            name: "SwiftScript",
            targets: ["SwiftScript"]),
        .library(
            name: "Pelota",
            targets: ["Pelota"]),
        .executable(
            name: "xtiled",
            targets: ["xtiled"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/SwiftStudies/OysterKit.git", .revision("6f48458b746a44cbfd1bef5ad69b233fa5ec7325")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Pelota",
            dependencies: []),
        .testTarget(
            name: "PelotaTests",
            dependencies: ["Pelota"]),
        .target(
            name: "TiledKit",
            dependencies: ["Pelota"]),
        .testTarget(
            name: "TiledKitTests",
            dependencies: ["TiledKit"]),
        .target(
            name: "SwiftScript",
            dependencies: ["Pelota","OysterKit"]),
        .testTarget(
            name: "SwiftScriptTests",
            dependencies: ["TiledKit"]),
        .target(
            name: "xtiled",
            dependencies: []),
        .testTarget(
            name: "xtiledTests",
            dependencies: ["xtiled"]),
    ]
)
