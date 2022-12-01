// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Chronometer",
    platforms: [
        .macOS(.v10_13), .iOS(.v11)
    ],
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
