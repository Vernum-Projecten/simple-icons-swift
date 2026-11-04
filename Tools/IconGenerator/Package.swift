// swift-tools-version: 6.2
// Generates Sources/SimpleIcons/Generated/ from a simple-icons npm package.
// A package of its own, so people who add simple-icons-swift never fetch it.
// Run it through scripts/dev/update-icons.sh, which downloads and verifies
// the npm package first.

import PackageDescription

let package = Package(
    name: "IconGenerator",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "generate-icons",
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("MemberImportVisibility"),
                .enableUpcomingFeature("InternalImportsByDefault"),
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
