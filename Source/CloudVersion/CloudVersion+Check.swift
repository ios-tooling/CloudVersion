import CloudKit
import Foundation

extension CloudVersion {
	public func check(allowPublish: Bool = false,
					  minimumSupportedVersion: String? = nil,
					  releaseNotes: String? = nil,
					  bundle: BundleInfo = .main) async throws -> CheckResult {
		guard container != nil else { throw CloudVersionError.notConfigured }
		let database = try publicDatabase

		let published = try await fetcher.fetch(bundleID: bundle.bundleID, platform: .current, in: database)
		let decision = CheckDecision.decide(
			local: Version(bundle.version),
			published: published,
			allowPublish: allowPublish,
			requestedMinimum: minimumSupportedVersion
		)

		switch decision {
		case .result(let result):
			return result
		case .publish(let minimum):
			try await publish(bundle: bundle,
							  minimumSupportedVersion: minimum,
							  releaseNotes: releaseNotes,
							  to: database)
			return .publishedNewVersion(version: bundle.version)
		}
	}
}
