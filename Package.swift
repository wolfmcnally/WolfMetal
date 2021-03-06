// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "WolfMetal",
    platforms: [
        .iOS(.v9), .macOS(.v10_13), .tvOS(.v11)
    ],
    products: [
        .library(
            name: "WolfMetal",
            targets: ["WolfMetal"]),
        ],
    dependencies: [
        .package(url: "https://github.com/wolfmcnally/WolfGraphics", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "WolfMetal",
            dependencies: [
                "WolfGraphics",
            ])
        ]
)
