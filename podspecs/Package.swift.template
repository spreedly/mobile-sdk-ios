// swift-tools-version:5.3
import PackageDescription

let package = Package(
        name: "Spreedly",
        platforms: [ .iOS(.v12) ],
        products: [
            .library(
                    name: "Spreedly",
                    targets: ["Spreedly", "SpreedlyCocoa"])
        ],
        dependencies: [],
        targets: [
            .binaryTarget(
                    name: "Spreedly",
                    path: "Spreedly.xcframework"
            ),
            .binaryTarget(
                    name: "SpreedlyCocoa",
                    path: "SpreedlyCocoa.xcframework"
            )
        ]
)