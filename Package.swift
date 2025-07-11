// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Chronometer",
    products: [
        .library(name: "Chronometer", targets: ["Chronometer"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Chronometer",
            dependencies: []),
        .testTarget(
            name: "ChronometerTests",
            dependencies: ["Chronometer"]),
    ]
)
