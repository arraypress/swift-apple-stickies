// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "swift-apple-stickies",
    // macOS only — Stickies is a Mac app, and its notes are files on this Mac.
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppleStickies", targets: ["AppleStickies"]),
    ],
    dependencies: [
        .package(url: "https://github.com/arraypress/swift-rich-text.git", from: "0.1.0"),
    ],
    targets: [
        .target(name: "AppleStickies", dependencies: [.product(name: "RichText", package: "swift-rich-text")]),
        .testTarget(name: "AppleStickiesTests", dependencies: ["AppleStickies"]),
    ]
)

// Swift 7's import rule, today: a file must import every module whose members
// it uses, rather than leaning on another file's imports.
for target in package.targets where target.type != .system && target.type != .binary && target.type != .plugin {
    target.swiftSettings = (target.swiftSettings ?? []) + [.enableUpcomingFeature("MemberImportVisibility")]
}
