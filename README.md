# CloudVersion

A tiny Swift package that lets an app publish its current version to a shared **public** CloudKit container, and check whether a newer version has been published. Records carry a *minimum supported version*, so apps can detect hard-breaking releases and prompt users to update.

The same container can host records for many apps; records are keyed by `bundleID + platform`. No third-party dependencies — just CloudKit and Foundation.

- **Container:** `iCloud.com.standalone.cloudversion` (overridable)
- **Database:** public
- **Record type:** `AppVersion`
- **Platforms:** macOS 14, iOS 17, watchOS 10, tvOS 17, visionOS 1

## Installation

Swift Package Manager:

```swift
.package(url: "https://github.com/bengottlieb/CloudVersion", from: "0.1.0"),
```

Then add the `CloudVersion` library to your target's dependencies.

## Quick start

```swift
import CloudVersion

@main
struct MyApp: App {
    init() {
        Task {
            do {
                let result = try await CloudVersion.shared.check(allowPublish: false)
                handle(result)
            } catch let error as CloudVersionError {
                print(error.description)
            }
        }
    }
}

func handle(_ result: CheckResult) {
    switch result {
    case .upToDate(let version):
        print("Up to date at \(version)")
    case .updateAvailable(let version, let build, let notes):
        print("Update available: \(version) (\(build)). \(notes ?? "")")
    case .mustUpdate(let minimum, let latest):
        // Block the user; they're below the floor.
        print("You must update to at least \(minimum). Latest: \(latest).")
    case .noPublishedRecord:
        print("No record yet — first run for this bundle/platform.")
    case .publishedNewVersion(let version):
        print("Published \(version) to the cloud.")
    }
}
```

## Container setup

CloudVersion uses a single, named CloudKit container shared by every app that adopts it.

1. **Sign into CloudKit Dashboard** (https://icloud.developer.apple.com) with the Apple ID that owns the container.
2. **Create the container** `iCloud.com.standalone.cloudversion` if it does not exist.
3. **In Xcode**, open your target → *Signing & Capabilities* → add the **iCloud** capability → enable **CloudKit** → add `iCloud.com.standalone.cloudversion` to the Containers list.
4. After the first record is written, return to CloudKit Dashboard and add **Queryable** indexes on the `bundleID` and `platform` fields, and a **Sortable** index on `updatedAt`. Then *Deploy Schema to Production* when you ship.

If the container is missing from your entitlements (or the user is on a build with no iCloud capability), `check(...)` throws `CloudVersionError.containerUnavailable` with a remediation message. To target a different container, set `CloudVersion.shared.containerID = "iCloud.your.container"` before the first call to `check(...)`.

## Record schema

Each app publishes one `AppVersion` record per platform.

| Field | Type | Notes |
|---|---|---|
| `bundleID` | String | Queryable — the app's bundle identifier |
| `platform` | String | Queryable — `iOS` / `macOS` / `watchOS` / `tvOS` / `visionOS` |
| `version` | String | The "current" version published by the running build |
| `build` | String | Build number (defaults to the same value as `version` — see below) |
| `minimumSupportedVersion` | String? | If the running app's version is below this, callers get `.mustUpdate` |
| `releaseNotes` | String? | Optional, for display in your update prompt |
| `updatedAt` | Date | Set automatically when published |

Record name is the deterministic string `"{bundleID}-{platform}"` so re-publishes upsert in place.

## How `version` is sourced

By default, `BundleInfo.main` reads `CFBundleVersion` (the build number from your Info.plist) and uses it as both the `version` and the `build` for comparison. Build numbers monotonically increase, which makes ordering unambiguous; semantic versions like `1.2.10` vs `1.2.3` need careful parsing (which `Version` does, but is easier to mis-input).

If you'd rather publish `CFBundleShortVersionString`, construct `BundleInfo` yourself:

```swift
let info = Bundle.main.infoDictionary ?? [:]
let bundle = BundleInfo(
    bundleID: Bundle.main.bundleIdentifier ?? "?",
    version: info["CFBundleShortVersionString"] as? String ?? "0.0.0",
    build: info["CFBundleVersion"] as? String ?? "0"
)
let result = try await CloudVersion.shared.check(bundle: bundle)
```

Version comparison is done by `Version`, which parses dot-separated integer components, treats missing trailing components as `0`, and ignores any `-prerelease` suffix.

## Publishing

`check(allowPublish:)` defaults to **read-only** behavior. Set `allowPublish: true` from a build that should advertise its version to other installations:

```swift
#if DEBUG
try await CloudVersion.shared.check(
    allowPublish: true,
    minimumSupportedVersion: "42",
    releaseNotes: "New onboarding flow"
)
#else
_ = try await CloudVersion.shared.check()
#endif
```

When `allowPublish == true`:
- If the running build's `version` is **greater than** the published one (or no record exists), CloudVersion writes a new record and returns `.publishedNewVersion`.
- Publishing requires the user to be signed into iCloud. If they aren't, you'll get `CloudVersionError.notSignedIn`.
- Reads do **not** require sign-in.

Typical pattern: gate `allowPublish: true` behind `#if DEBUG` or a TestFlight-only flag so only your own builds update the published "latest".

## Decision matrix

`CloudVersion.check(...)` runs this logic against the local `Version` and the published `VersionRecord`:

| Condition | Result (read-only) | Result (`allowPublish: true`) |
|---|---|---|
| No record exists | `.noPublishedRecord` | `.publishedNewVersion` |
| Local `<` `minimumSupportedVersion` | `.mustUpdate(minimum, latest)` | `.mustUpdate(minimum, latest)` |
| Local `<` published | `.updateAvailable(version, build, notes)` | `.updateAvailable(version, build, notes)` |
| Local `==` published | `.upToDate(version)` | `.upToDate(version)` |
| Local `>` published | `.updateAvailable(version, build, notes)` | `.publishedNewVersion(localVersion)` |

The decision logic is split into a pure function (`CheckDecision.decide`) so it's exercised in unit tests without CloudKit.

## Errors

```swift
public enum CloudVersionError: Error {
    case notSignedIn                       // publish attempted without iCloud sign-in
    case containerUnavailable(...)         // entitlement / dashboard misconfiguration
}
```

Each conforms to `CustomStringConvertible` with an actionable message — the `containerUnavailable` description tells the user exactly which container ID is missing and where to fix it.

## Multi-platform records

A single app's iOS, macOS, watchOS, tvOS, and visionOS builds each publish their own record. This lets versions diverge across platforms (common when one platform lags behind in a release). To check a *specific* platform programmatically, call `check(...)` on a device of that platform; cross-platform queries are not part of this framework's public API.

## Tests

```sh
swift test
```

There are no integration tests against live CloudKit — the network-bound code is behind a `VersionFetching` seam. Unit tests cover version parsing, CKRecord round-tripping, and the full decision matrix.
