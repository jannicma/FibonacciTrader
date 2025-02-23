// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FibonacciTrader",
    platforms: [
        .macOS(.v15)
    ],
        dependencies: [
        .package(url: "https://github.com/codewinsdotcom/PostgresClientKit.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "FibonacciTrader",
            dependencies: ["PostgresClientKit"]
        )
    ]
)
