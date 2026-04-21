import CloudKit

extension CloudVersion {
	func publish(bundle: BundleInfo,
				 minimumSupportedVersion: String?,
				 releaseNotes: String?,
				 to database: CKDatabase) async throws {
		guard let container else { throw CloudVersionError.notConfigured }
		let status = try await container.accountStatus()
		guard status == .available else { throw CloudVersionError.notSignedIn }

		let record = VersionRecord(
			bundleID: bundle.bundleID,
			platform: .current,
			version: bundle.version,
			build: bundle.build,
			minimumSupportedVersion: minimumSupportedVersion,
			releaseNotes: releaseNotes
		)
		try await fetcher.publish(record, to: database)
	}
}
