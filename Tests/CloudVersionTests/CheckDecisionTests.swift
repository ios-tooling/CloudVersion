import Foundation
import Testing
@testable import CloudVersion

struct CheckDecisionTests {
	private func makeRecord(version: String,
							build: String = "1",
							minimum: String? = nil,
							notes: String? = nil) -> VersionRecord {
		VersionRecord(bundleID: "x", platform: .iOS, version: version, build: build,
					  minimumSupportedVersion: minimum, releaseNotes: notes)
	}

	@Test func noRecordWithoutPublishGivesNoPublishedRecord() {
		let decision = CheckDecision.decide(local: Version("1.0"), published: nil,
											allowPublish: false, requestedMinimum: nil)
		#expect(decision == .result(.noPublishedRecord))
	}

	@Test func noRecordWithPublishRequestsPublish() {
		let decision = CheckDecision.decide(local: Version("1.0"), published: nil,
											allowPublish: true, requestedMinimum: "0.9")
		#expect(decision == .publish(alsoUsingMinimum: "0.9"))
	}

	@Test func belowMinimumReturnsMustUpdate() {
		let published = makeRecord(version: "2.0.0", minimum: "1.5.0")
		let decision = CheckDecision.decide(local: Version("1.4.9"), published: published,
											allowPublish: false, requestedMinimum: nil)
		#expect(decision == .result(.mustUpdate(minimumSupportedVersion: "1.5.0", latest: "2.0.0")))
	}

	@Test func olderLocalReturnsUpdateAvailable() {
		let published = makeRecord(version: "2.0.0", build: "200", notes: "New!")
		let decision = CheckDecision.decide(local: Version("1.9.0"), published: published,
											allowPublish: false, requestedMinimum: nil)
		#expect(decision == .result(.updateAvailable(version: "2.0.0", build: "200", releaseNotes: "New!")))
	}

	@Test func equalLocalReturnsUpToDate() {
		let published = makeRecord(version: "1.2.3")
		let decision = CheckDecision.decide(local: Version("1.2.3"), published: published,
											allowPublish: false, requestedMinimum: nil)
		#expect(decision == .result(.upToDate(version: "1.2.3")))
	}

	@Test func newerLocalWithPublishFiresPublish() {
		let published = makeRecord(version: "1.0.0", minimum: "0.9")
		let decision = CheckDecision.decide(local: Version("1.1.0"), published: published,
											allowPublish: true, requestedMinimum: nil)
		#expect(decision == .publish(alsoUsingMinimum: "0.9"))
	}

	@Test func newerLocalWithoutPublishFallsBackToUpdateAvailable() {
		let published = makeRecord(version: "1.0.0")
		let decision = CheckDecision.decide(local: Version("1.1.0"), published: published,
											allowPublish: false, requestedMinimum: nil)
		#expect(decision == .result(.updateAvailable(version: "1.0.0", build: "1", releaseNotes: nil)))
	}

	@Test func requestedMinimumOverridesPublishedMinimumOnRepublish() {
		let published = makeRecord(version: "1.0.0", minimum: "0.9")
		let decision = CheckDecision.decide(local: Version("1.1.0"), published: published,
											allowPublish: true, requestedMinimum: "1.0.0")
		#expect(decision == .publish(alsoUsingMinimum: "1.0.0"))
	}
}
