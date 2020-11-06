// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "NoMoreSNSSDK",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(name: "NoMoreSNSSDK", targets: ["NoMoreSNSSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OAuthSwift/OAuthSwift", .upToNextMinor(from: "2.1.2")),
    ],
    targets: [
        .target(
            name: "NoMoreSNSSDK",
            dependencies: ["OAuthSwift"],
            path: "Sources"
        ),
    ]
)
