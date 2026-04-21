import CloudKit
import Foundation

@MainActor
public final class CloudVersion {
	public static let shared = CloudVersion()

	public static let defaultContainerID = "iCloud.com.standalone.cloudversion"

	public private(set) var container: CKContainer?
	var fetcher: VersionFetching = DefaultVersionFetcher()

	private init() { }

	public func setup(containerID: String = CloudVersion.defaultContainerID) async throws {
		container = CKContainer(identifier: containerID)
		try await verifyContainer()
	}

	var publicDatabase: CKDatabase {
		get throws {
			guard let container else { throw CloudVersionError.notConfigured }
			return container.publicCloudDatabase
		}
	}
}
