// swift-tools-version: 5.8
import PackageDescription

let package = Package(
  name: "OpacityCore",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    .library(
      name: "OpacityCore",
      targets: ["OpacityCoreObjc", "OpacityCoreSwift"])
  ],
  dependencies: [],
  targets: [
    .binaryTarget(
      name: "sdk",
      path: "sdk.xcframework"
    ),
    .target(
      name: "OpacityCoreObjc",
      dependencies: ["sdk"],
      path: "src/objc",
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath("../../include")
      ],
      linkerSettings: [
        .linkedFramework("CoreTelephony"),
        .linkedFramework("CoreLocation"),
        .linkedFramework("WebKit"),
        .unsafeFlags(["-Wl,-keep_private_externs"]),  // Prevent symbol stripping
        .unsafeFlags(["-Wl,-no_deduplicate"]),  // Prevent symbol deduplication
      ]
    ),
    .target(
      name: "OpacityCoreSwift",
      dependencies: ["OpacityCoreObjc"],
      path: "src/swift"
    ),
  ]
)
