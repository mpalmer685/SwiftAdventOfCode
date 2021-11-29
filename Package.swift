// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftAdventOfCode",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AOCKit",
            targets: ["AOCKit"]
        ),
        .executable(
            name: "aoc2020",
            targets: ["AdventOfCode2020"]
        ),
        .executable(
            name: "aoc2021",
            targets: ["AdventOfCode2021"]
        ),
        .executable(
            name: "AdventOfCode2020",
            targets: ["AdventOfCode2020"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
        .package(url: "https://github.com/kiliankoe/CLISpinner", from: "0.4.0"),
        .package(url: "https://github.com/JohnSundell/Codextended", from: "0.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AOCKit",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Files", package: "Files"),
                .product(name: "Rainbow", package: "Rainbow"),
                .product(name: "CLISpinner", package: "CLISpinner"),
                .product(name: "Codextended", package: "Codextended"),
            ]
        ),
        .target(
            name: "AdventOfCode2020",
            dependencies: ["AOCKit"]
        ),
        .target(
            name: "AdventOfCode2021",
            dependencies: ["AOCKit"]
        ),
    ]
)
