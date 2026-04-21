import Foundation

public enum CheckResult: Sendable, Equatable {
	case upToDate(version: String)
	case updateAvailable(version: String, build: String, releaseNotes: String?)
	case mustUpdate(minimumSupportedVersion: String, latest: String)
	case publishedNewVersion(version: String)
	case noPublishedRecord
}
