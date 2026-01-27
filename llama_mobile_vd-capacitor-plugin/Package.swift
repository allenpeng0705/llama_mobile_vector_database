// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LlamaMobileVdCapacitorPlugin",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "LlamaMobileVdCapacitorPlugin",
            targets: ["LlamaMobileVdCapacitorPlugin"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", exact: "8.0.1")
    ],
    targets: [
        .binaryTarget(
            name: "llama_mobile_vd",
            path: "ios/llama_mobile_vd.xcframework"
        ),
        .target(
            name: "LlamaMobileVdCapacitorPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                "llama_mobile_vd"
            ],
            path: "ios/Plugin"
        )
    ]
)