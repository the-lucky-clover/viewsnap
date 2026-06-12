// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ViewSnap",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "ViewSnap",
            targets: ["ViewSnap"]
        ),
    ],
    dependencies: [
        // Add IINA dependency when available
    ],
    targets: [
        .target(
            name: "ViewSnap",
            dependencies: []
        )
    ]
)