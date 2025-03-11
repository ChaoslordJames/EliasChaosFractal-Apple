// swift-tools-version:5.7
import PackageDescription

let package = Package(
   name: "EliasChaosFractal-Apple",
   platforms: [
       .macOS(.v12), // Minimum for SwiftUI and AVFoundation
       .iOS(.v15)    // For potential iPhone deployment
   ],
   products: [
       // Executable product for the P2P node
       .executable(
           name: "P2PNode",
           targets: ["P2PNode"]
       ),
       // Library product for the GUI app
       .library(
           name: "EliasGUI",
           targets: ["EliasGUI"]
       )
   ],
   dependencies: [
       // Redis for swarm state management
       .package(url: "https://github.com/vapor/redis.git", from: "4.8.0"),
       // CryptoKit is part of Swift standard library, no external dependency needed
       // SQLite3 for local state persistence
       .package(url: "https://github.com/vapor/sqlite-kit.git", from: "4.4.0")
   ],
   targets: [
       // Core P2P Node Target
       .executableTarget(
           name: "P2PNode",
           dependencies: [
               .product(name: "Redis", package: "redis"),
               .product(name: "SQLiteKit", package: "sqlite-kit")
           ],
           path: "Sources/P2PNode",
           swiftSettings: [
               .define("SWIFTUI") // Enable SwiftUI integration
           ]
       ),
       // GUI Target with Voice Synthesis
       .target(
           name: "EliasGUI",
           dependencies: [
               "P2PNode" // Link to core swarm logic
           ],
           path: "EliasGUI/Sources",
           swiftSettings: [
               .define("SWIFTUI"),
               .define("AVFOUNDATION") // Enable voice synthesis
           ],
           linkerSettings: [
               .linkedFramework("AVFoundation"), // Voice synthesis
               .linkedFramework("SwiftUI")       // GUI framework
           ]
       ),
       // Test Target (optional, stubbed for now)
       .testTarget(
           name: "P2PTests",
           dependencies: ["P2PNode"],
           path: "Tests/P2PTests"
       )
   ]
)
