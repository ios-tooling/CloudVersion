import CloudKit

extension CloudVersionError {
	static func wrap(_ error: Error, containerID: String) -> Error {
		guard let ckError = error as? CKError else { return error }
		switch ckError.code {
		case .badContainer, .missingEntitlement, .incompatibleVersion:
			return CloudVersionError.containerUnavailable(containerID: containerID, underlying: ckError)
		default:
			return error
		}
	}
}
