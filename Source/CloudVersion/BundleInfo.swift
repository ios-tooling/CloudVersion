import Foundation

public struct BundleInfo: Sendable {
	public let bundleID: String
	public let version: String
	public let build: String

	public static var main: BundleInfo {
		let info = Bundle.main.infoDictionary ?? [:]
		let buildNumber = info["CFBundleVersion"] as? String ?? "0"
		return BundleInfo(
			bundleID: Bundle.main.bundleIdentifier ?? "unknown.bundle",
			version: buildNumber,
			build: buildNumber
		)
	}
}
