import CloudKit
import Foundation

@MainActor
public final class CloudVersion {
	public static let shared = CloudVersion()

	public static let defaultContainerID = "iCloud.com.standalone.cloudversion"

	public var containerID: String = CloudVersion.defaultContainerID {
		didSet { cachedContainer = nil }
	}
	private var cachedContainer: CKContainer?
	var fetcher: VersionFetching = DefaultVersionFetcher()

	private init() { }

	public var container: CKContainer {
		if let cachedContainer { return cachedContainer }
		let new = CKContainer(identifier: containerID)
		cachedContainer = new
		return new
	}

	var publicDatabase: CKDatabase { container.publicCloudDatabase }
}
