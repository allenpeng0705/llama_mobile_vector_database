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
    dependencies: [],
    targets: [
        .target(
            name: "iOSSDKExample",
            dependencies: [],
            path: "Sources",
            resources: [
                .process("../Main.storyboard"),
                .process("../LaunchScreen.storyboard")
            ],
            cSettings: [
                .headerSearchPath("../../llama_mobile_vd-ios-SDK/llama_mobile_vd.xcframework/ios-arm64/llama_mobile_vd.framework/Headers")
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("CoreGraphics"),
                .linkedLibrary("z"),
                .linkedLibrary("c++"),
                .linkedFramework("llama_mobile_vd", searchPaths: ["../../llama_mobile_vd-ios-SDK/llama_mobile_vd.xcframework/ios-arm64/llama_mobile_vd.framework"]),
                .unsafeFlags(["-F../../llama_mobile_vd-ios-SDK/llama_mobile_vd.xcframework/ios-arm64"])            ]
        )
    ]
)