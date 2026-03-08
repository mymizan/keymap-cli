// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "keymap-cli",
    products: [
        .executable(name: "keymap", targets: ["keymap"]),
    ],
    targets: [
        .executableTarget(
            name: "keymap",
            linkerSettings: [
                .linkedLibrary("sqlite3")
            ]),
        .testTarget(
            name: "keymapTests",
            dependencies: ["keymap"]),
    ]
)
