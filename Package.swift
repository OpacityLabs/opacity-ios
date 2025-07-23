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
      ]
    ),
    .target(
      name: "OpacityCoreSwift",
      dependencies: ["OpacityCoreObjc"],
      path: "src/swift"
    ),
  ]
)
