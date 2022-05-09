// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "ChronometerKit",
    platforms: [
        .macOS(.v10_13), .iOS(.v11)
    ],
    products: [
        .library(name: "ChronometerKit", targets: ["ChronometerKit"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ChronometerKit",
            dependencies: []),
        .testTarget(
            name: "ChronometerTests",
            dependencies: ["ChronometerKit"]),
    ]
)
