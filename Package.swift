// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DesignSystem",
  platforms: [
    .iOS(.v18)
  ],
  products: [
    .library(
      name: "DesignSystem",
      targets: ["Resources", "Font", "Component"]
    ),
  ],
  targets: [
    .target(
      name: "Resources",
      resources: [
        .process("Resources")
      ],
      plugins: ["AssetContants"]
    ),
    .target(
      name: "Font",
      resources: [
        .process("Font")
      ]
    ),
    .target(
      name: "Component",
      dependencies: [
        .target(name: "Resources"),
        .target(name: "Font")
      ]
    ),
    .executableTarget(name: "AssetContantsExec", path: "Sources/AssetContantsExec"),
    .plugin(name: "AssetContants", capability: .buildTool(), dependencies: ["AssetContantsExec"]),
    .plugin(
      name: "ColorGenerator",
      capability: .command(
        intent: .custom(
          verb: "generate-colors",
          description: "Generate color constants from xcassets"
        ),
        permissions: [
          .writeToPackageDirectory(reason: "Generate DesignSystem+Color.swift file")
        ]
      )
    ),
    .plugin(
      name: "ImageGenerator",
      capability: .command(
        intent: .custom(
          verb: "generate-images",
          description: "Generate image constants from xcassets"
        ),
        permissions: [
          .writeToPackageDirectory(reason: "Generate DesignSystem+Image.swift file")
        ]
      )
    )
  ]
)
