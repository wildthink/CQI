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
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CQI",
            targets: ["CQI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/wildthink/MomXML", .branch("master")),
        .package(url: "https://github.com/wildthink/FeistyDB", .branch("master")),
        .package(url: "https://github.com/wildthink/Runtime", .branch("master")),
        .package(name: "SnapshotTesting",
                 url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
                 from: "1.9.0"),

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CQI",
            dependencies: [
                "FeistyDB",
                "MomXML",
                .product(name: "Runtime", package: "Runtime"),
                .product(name: "FeistyExtensions", package: "FeistyDB"),
            ]
//            ,exclude: ["Tests/__Snapshots__"]
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
