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
      name: "opacity",
      path: "opacity.xcframework"
    ),
    .target(
      name: "OpacityCore",
      dependencies: ["opacity"],
      path: "Opacity",
      publicHeadersPath: ".",
      linkerSettings: [
        .linkedFramework("CoreTelephony"),
        .linkedFramework("CoreLocation"),
        .linkedFramework("WebKit"),
      ]
    ),
  ]
)
