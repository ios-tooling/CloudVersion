import CloudKit

extension CloudVersion {
	func verifyContainer() async throws {
		guard let container else { throw CloudVersionError.notConfigured }
		do {
			_ = try await container.accountStatus()
		} catch {
			throw CloudVersionError.containerUnavailable(
				containerID: container.containerIdentifier ?? "?",
				underlying: error
			)
		}
	}
}
