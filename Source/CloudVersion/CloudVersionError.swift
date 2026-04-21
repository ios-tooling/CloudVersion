import Foundation

public enum CloudVersionError: Error, CustomStringConvertible {
	case notConfigured
	case notSignedIn
	case containerUnavailable(containerID: String, underlying: Error?)

	public var description: String {
		switch self {
		case .notConfigured:
			return "CloudVersion.shared.setup() has not been called."
		case .notSignedIn:
			return "Publishing requires the user to be signed in to iCloud."
		case .containerUnavailable(let id, let underlying):
			var message = "CloudKit container \"\(id)\" is not available. "
			message += "Open CloudKit Dashboard and confirm the container exists, "
			message += "then enable it in the app's Signing & Capabilities → iCloud → Containers."
			if let underlying { message += "\nUnderlying error: \(underlying)" }
			return message
		}
	}
}
