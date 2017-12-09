// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "UInt256",
    products: [
        .library(
            name: "UInt256",
            targets: ["UInt256"]),
    ],
    targets: [
        .target(
            name: "UInt256",
            dependencies: []),
        .testTarget(
            name: "UInt256Tests",
            dependencies: ["UInt256"]),
    ]
)
