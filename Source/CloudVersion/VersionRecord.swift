import CloudKit
import Foundation

public struct VersionRecord: Sendable, Equatable {
	public static let recordType: CKRecord.RecordType = "AppVersion"

	public var bundleID: String
	public var platform: Platform
	public var version: String
	public var build: String
	public var minimumSupportedVersion: String?
	public var releaseNotes: String?
	public var updatedAt: Date

	public var recordName: String { "\(bundleID)-\(platform.rawValue)" }

	public init(bundleID: String,
				platform: Platform,
				version: String,
				build: String,
				minimumSupportedVersion: String? = nil,
				releaseNotes: String? = nil,
				updatedAt: Date = .init()) {
		self.bundleID = bundleID
		self.platform = platform
		self.version = version
		self.build = build
		self.minimumSupportedVersion = minimumSupportedVersion
		self.releaseNotes = releaseNotes
		self.updatedAt = updatedAt
	}

	public init?(record: CKRecord) {
		guard let bundleID = record["bundleID"] as? String,
			  let platformRaw = record["platform"] as? String,
			  let platform = Platform(rawValue: platformRaw),
			  let version = record["version"] as? String,
			  let build = record["build"] as? String else { return nil }
		self.bundleID = bundleID
		self.platform = platform
		self.version = version
		self.build = build
		self.minimumSupportedVersion = record["minimumSupportedVersion"] as? String
		self.releaseNotes = record["releaseNotes"] as? String
		self.updatedAt = record["updatedAt"] as? Date ?? .init()
	}

	public func populate(_ record: CKRecord) {
		record["bundleID"] = bundleID
		record["platform"] = platform.rawValue
		record["version"] = version
		record["build"] = build
		record["minimumSupportedVersion"] = minimumSupportedVersion
		record["releaseNotes"] = releaseNotes
		record["updatedAt"] = updatedAt
	}

	public func makeCKRecord(in zone: CKRecordZone.ID = CKRecordZone.default().zoneID) -> CKRecord {
		let id = CKRecord.ID(recordName: recordName, zoneID: zone)
		let record = CKRecord(recordType: Self.recordType, recordID: id)
		populate(record)
		return record
	}
}
