// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let package = Package(
    name: "SwiftAdventOfCode",
    platforms: [.macOS(.v13)],
    products: [
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
            name: "aoc2022",
            targets: ["AdventOfCode2022"]
        ),
        .executable(
            name: "aoc2023",
            targets: ["AdventOfCode2023"]
        ),
        .executable(
            name: "aoc2024",
            targets: ["AdventOfCode2024"]
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
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/mpalmer685/swift-ascii-table", exact: "0.2.0"),
    ],
    targets: [
        .target(
            name: "AOCKit",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "CLISpinner", package: "CLISpinner"),
                .product(name: "Codextended", package: "Codextended"),
                .product(name: "Files", package: "Files"),
                .product(name: "Rainbow", package: "Rainbow"),
                .product(name: "AsciiTable", package: "swift-ascii-table"),
            ]
        ),
        .executableTarget(
            name: "AdventOfCode2020",
            dependencies: ["AOCKit"]
        ),
        .executableTarget(
            name: "AdventOfCode2021",
            dependencies: ["AOCKit"]
        ),
        .executableTarget(
            name: "AdventOfCode2022",
            dependencies: ["AOCKit"]
        ),
        .executableTarget(
            name: "AdventOfCode2023",
            dependencies: ["AOCKit"]
        ),
        .executableTarget(
            name: "AdventOfCode2024",
            dependencies: ["AOCKit"]
        ),
    ]
)
