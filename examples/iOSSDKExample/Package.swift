// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "iOSSDKExample",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "iOSSDKExample",
            targets: ["iOSSDKExample"]
        )
    ],
    dependencies: [
        .package(path: "../../llama_mobile_vd-ios-SDK/LlamaMobileVDBundle")
    ],
    targets: [
        .target(
            name: "iOSSDKExample",
            dependencies: [.product(name: "LlamaMobileVD", package: "LlamaMobileVDBundle")],
            path: "Sources",
            resources: [
                .process("../Main.storyboard"),
                .process("../LaunchScreen.storyboard")
            ]
        )
    ]
)