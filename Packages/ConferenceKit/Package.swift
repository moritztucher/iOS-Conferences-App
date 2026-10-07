// swift-tools-version: 6.2
import PackageDescription

/// Foundation-only code shared by the app and (from ADR-0009 phase 4) the Live Activity
/// widget extension: talk schedule types, feed decoding and the agenda logic.
/// No SwiftData or UI here, so the tests run in seconds with `swift test`.
let package = Package(
    name: "ConferenceKit",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "ConferenceKit", targets: ["ConferenceKit"])
    ],
    targets: [
        .target(name: "ConferenceKit"),
        .testTarget(name: "ConferenceKitTests", dependencies: ["ConferenceKit"])
    ]
)
