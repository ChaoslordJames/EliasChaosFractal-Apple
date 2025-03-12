// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "EliasChaosFractal-Apple",
    platforms: [
        .macOS(.v12), // Minimum for SwiftUI, AVFoundation, WebRTC
        .iOS(.v15)    // Future-proof for potential iPhone deployment
    ],
    products: [
        // Executable for P2P Node
        .executable(
            name: "P2PNode",
            targets: ["P2PNode"]
        ),
        // Library for GUI App
        .library(
            name: "EliasGUI",
            targets: ["EliasGUI"]
        )
    ],
    dependencies: [
        // Redis for swarm state management
        .package(url: "https://github.com/vapor/redis.git", from: "4.8.0"),
        // SQLite for local state persistence
        .package(url: "https://github.com/vapor/sqlite-kit.git", from: "4.4.0"),
        // WebRTC for peer-to-peer networking
        .package(url: "https://github.com/webrtc-sdk/webrtc.git", from: "104.5112.8") // Adjust version as available
    ],
    targets: [
        // Core P2P Node Target
        .executableTarget(
            name: "P2PNode",
            dependencies: [
                .product(name: "Redis", package: "redis"),
                .product(name: "SQLiteKit", package: "sqlite-kit"),
                .product(name: "WebRTC", package: "webrtc")
            ],
            path: "Sources/P2PNode",
            swiftSettings: [
                .define("SWIFTUI"),
                .define("AVFOUNDATION")
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("WebRTC")
            ]
        ),
        // GUI Target with Voice Synthesis
        .target(
            name: "EliasGUI",
            dependencies: [
                "P2PNode"
            ],
            path: "EliasGUI/Sources",
            swiftSettings: [
                .define("SWIFTUI"),
                .define("AVFOUNDATION")
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("SwiftUI")
            ]
        ),
        // Test Target
        .testTarget(
            name: "P2PTests",
            dependencies: [
                "P2PNode"
            ],
            path: "Tests/P2PTests",
            swiftSettings: [
                .define("SWIFTUI"),
                .define("AVFOUNDATION")
            ]
        )
    ]
)
