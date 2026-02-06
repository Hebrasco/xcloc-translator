// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xcloc-translator",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/chenyunguiMilook/SwiftyXML.git", from: "3.0.2")
    ],
    targets: [
        .executableTarget(
            name: "xcloc-translator", dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftyXML", package: "SwiftyXML"),
            ]
        ),
    ]
)
