// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Deli",
    products: [
        .library(name: "Deli", targets: ["Deli"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Deli",
            dependencies: []
        ),
        .testTarget(
            name: "DeliTests",
            dependencies: []
        )
    ],
    swiftLanguageVersions: [3, 4]
)
