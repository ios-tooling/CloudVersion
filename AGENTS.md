# Agent notes

Small Swift package. Public CloudKit container `iCloud.com.standalone.cloudversion`, record type `AppVersion`, keyed by `bundleID-platform`. No third-party dependencies — keep it that way.

- Build: `swift build`
- Test: `swift test` (Swift Testing, not XCTest)
- Source lives in `Source/CloudVersion/`; tests in `Tests/CloudVersionTests/`
- Keep individual `.swift` files around 100 lines; split by responsibility
- All public API is `@MainActor` on `CloudVersion.shared`; CloudKit work is async/await
- Pure decision logic lives in `CheckDecision.swift` and is tested without CloudKit; the network seam is `VersionFetching` in `VersionFetcher.swift`
- Read README.md for the schema, the publish-gate semantics, and the entitlement requirements
