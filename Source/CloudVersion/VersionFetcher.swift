import CloudKit

protocol VersionFetching: Sendable {
	func fetch(bundleID: String, platform: Platform, in database: CKDatabase) async throws -> VersionRecord?
	func publish(_ record: VersionRecord, to database: CKDatabase) async throws
}

struct DefaultVersionFetcher: VersionFetching {
	func fetch(bundleID: String, platform: Platform, in database: CKDatabase) async throws -> VersionRecord? {
		let recordName = "\(bundleID)-\(platform.rawValue)"
		let id = CKRecord.ID(recordName: recordName, zoneID: CKRecordZone.default().zoneID)
		do {
			let record = try await database.record(for: id)
			return VersionRecord(record: record)
		} catch let error as CKError where error.code == .unknownItem {
			return nil
		}
	}

	func publish(_ record: VersionRecord, to database: CKDatabase) async throws {
		let ckRecord = record.makeCKRecord()
		do {
			_ = try await database.save(ckRecord)
		} catch let error as CKError where error.code == .serverRecordChanged {
			guard let server = error.userInfo[CKRecordChangedErrorServerRecordKey] as? CKRecord else { throw error }
			record.populate(server)
			_ = try await database.save(server)
		}
	}
}
