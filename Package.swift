// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-entity-serialization",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        .library(
            name: "EntitySerialization",
            targets: ["EntitySerialization"]
        ),
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "EntitySerialization",
            dependencies: []
        ),
        .testTarget(
            name: "EntitySerializationTests",
            dependencies: [
                "EntitySerialization"
            ]
        ),
    ]
)
