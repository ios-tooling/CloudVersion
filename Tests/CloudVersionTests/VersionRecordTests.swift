import CloudKit
import Testing
@testable import CloudVersion

struct VersionRecordTests {
	@Test func recordNameCombinesBundleAndPlatform() {
		let record = VersionRecord(bundleID: "com.acme.app", platform: .iOS, version: "1.0", build: "1")
		#expect(record.recordName == "com.acme.app-iOS")
	}

	@Test func roundTripsThroughCKRecord() {
		let original = VersionRecord(
			bundleID: "com.acme.app",
			platform: .macOS,
			version: "2.1.0",
			build: "210",
			minimumSupportedVersion: "2.0.0",
			releaseNotes: "Bug fixes",
			updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
		)
		let ckRecord = original.makeCKRecord()
		let decoded = VersionRecord(record: ckRecord)

		#expect(decoded == original)
	}

	@Test func rejectsRecordMissingRequiredFields() {
		let record = CKRecord(recordType: VersionRecord.recordType)
		record["bundleID"] = "com.acme.app"
		#expect(VersionRecord(record: record) == nil)
	}
}
