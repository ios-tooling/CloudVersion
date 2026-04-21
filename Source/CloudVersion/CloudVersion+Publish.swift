import CloudKit

extension CloudVersion {
	func publish(bundle: BundleInfo,
				 minimumSupportedVersion: String?,
				 releaseNotes: String?,
				 to database: CKDatabase) async throws {
		let status: CKAccountStatus
		do {
			status = try await container.accountStatus()
		} catch {
			throw CloudVersionError.wrap(error, containerID: containerID)
		}
		guard status == .available else { throw CloudVersionError.notSignedIn }

		let record = VersionRecord(
			bundleID: bundle.bundleID,
			platform: .current,
			version: bundle.version,
			build: bundle.build,
			minimumSupportedVersion: minimumSupportedVersion,
			releaseNotes: releaseNotes
		)
		do {
			try await fetcher.publish(record, to: database)
		} catch {
			throw CloudVersionError.wrap(error, containerID: containerID)
		}
	}
}
