// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "SVGView",
    platforms: [
        .iOS(.v15), .macOS(.v14),
    ],
    products: [
        .library(
            name: "SVGView",
            targets: ["SVGView"]
        ),
    ],
    targets: [
        .target(
            name: "SVGView",
            path: "Source",
            exclude: ["Info.plist"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
