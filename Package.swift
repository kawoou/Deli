// swift-tools-version:5.0
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
    targets: [
        .target(
            name: "Deli",
            dependencies: [],
            path: "Sources/Deli"
        )
    ],
    swiftLanguageVersions: [.v4, .v4_2, .v5]
)
