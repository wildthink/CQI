// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CQI",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "CQI",
            targets: ["CQI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/wildthink/MomXML", .branch("master")),
        .package(url: "https://github.com/wildthink/FeistyDB", .branch("master")),
        .package(url: "https://github.com/wildthink/Runtime", .branch("master")),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.6.0"),
        .package(name: "SnapshotTesting",
                 url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
                 from: "1.9.0"),

    ],
    targets: [
         .target(
            name: "CQI",
            dependencies: [
                "FeistyDB",
                "MomXML",
                .product(name: "Runtime", package: "Runtime"),
                .product(name: "FeistyExtensions", package: "FeistyDB"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
        .testTarget(
            name: "CQITests",
            dependencies: [
                "CQI",
                .product(name: "SnapshotTesting", package: "SnapshotTesting"),
            ]
            ,exclude: ["__Snapshots__"]
        ),
    ]
)
