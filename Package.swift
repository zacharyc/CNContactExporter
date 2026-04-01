// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CNContactExporter",
    platforms: [
        .macOS(.v14),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "CNContactExporter",
            targets: ["CNContactExporter"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "CNContactExporter",
            dependencies: ["Yams"]
        ),
        .testTarget(
            name: "CNContactExporterTests",
            dependencies: ["CNContactExporter"]
        )
    ]
)
