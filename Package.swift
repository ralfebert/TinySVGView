// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "TinySVGView",
    platforms: [
        .iOS(.v16), .macOS(.v14),
    ],
    products: [
        .library(
            name: "TinySVGView",
            targets: ["TinySVGView"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/CoreOffice/XMLCoder", from: "0.17.1"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.0"),
    ],
    targets: [
        .target(
            name: "TinySVGView",
            dependencies: [
                .product(name: "XMLCoder", package: "XMLCoder"),
            ],
            path: "Source",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "TinySVGViewTests",
            dependencies: [
                "TinySVGView",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            exclude: ["__Snapshots__"],
            resources: [.copy("sample.svg"), .copy("shapes.svg")]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
