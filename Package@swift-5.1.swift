// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Deli",
    platforms: [
        .iOS(.v8),
        .macOS(.v10_10),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(name: "Deli", targets: ["Deli"])
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "1.3.1"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "7.3.0")
    ],
    targets: [
        .target(
            name: "Deli",
            dependencies: [],
            path: "Sources/Deli"
        ),
        .testTarget(
            name: "DeliTests",
            dependencies: [
                "Deli",
                "Quick",
                "Nimble"
            ],
            path: "Tests/DeliTests"
        )
    ],
    swiftLanguageVersions: [.v4, .v4_2, .v5]
)
