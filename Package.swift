// swift-tools-version: 5.8
import PackageDescription

let package = Package(
  name: "OpacityCore",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    .library(
      name: "OpacityCore",
      targets: ["OpacityCore"])
  ],
  dependencies: [],
  targets: [
    .binaryTarget(
      name: "opacity_core",
      path: "opacity.xcframework"
    ),
    .target(
      name: "OpacityCoreObjc",
      dependencies: ["opacity_core"],
      path: "src/objc",
      publicHeadersPath: ".",
      linkerSettings: [
        .linkedFramework("CoreTelephony"),
        .linkedFramework("CoreLocation"),
        .linkedFramework("WebKit"),
      ]
    ),
    .target(
      name: "OpacityCoreSwift",
      dependencies: ["OpacityCoreObjc"],
      path: "src/swift"
    ),
  ]
)
