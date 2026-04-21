import Foundation

enum CheckDecision: Equatable {
	case result(CheckResult)
	case publish(alsoUsingMinimum: String?)

	static func decide(local: Version,
					   published: VersionRecord?,
					   allowPublish: Bool,
					   requestedMinimum: String?) -> CheckDecision {
		guard let published else {
			return allowPublish ? .publish(alsoUsingMinimum: requestedMinimum) : .result(.noPublishedRecord)
		}

		if let minimum = published.minimumSupportedVersion, local < Version(minimum) {
			return .result(.mustUpdate(minimumSupportedVersion: minimum, latest: published.version))
		}

		let publishedVersion = Version(published.version)
		if local > publishedVersion {
			return allowPublish
				? .publish(alsoUsingMinimum: requestedMinimum ?? published.minimumSupportedVersion)
				: .result(.updateAvailable(version: published.version, build: published.build, releaseNotes: published.releaseNotes))
		}
		if local < publishedVersion {
			return .result(.updateAvailable(version: published.version, build: published.build, releaseNotes: published.releaseNotes))
		}
		return .result(.upToDate(version: published.version))
	}
}
