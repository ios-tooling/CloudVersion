import Testing
@testable import CloudVersion

struct VersionTests {
	@Test func parsesSimpleDotted() {
		#expect(Version("1.2.3").components == [1, 2, 3])
	}

	@Test func comparesLexicographicallyByComponent() {
		#expect(Version("1.2.10") > Version("1.2.3"))
		#expect(Version("1.10") > Version("1.2"))
		#expect(Version("2.0") > Version("1.99"))
	}

	@Test func treatsMissingTrailingAsZero() {
		#expect(Version("1.2") == Version("1.2.0"))
		#expect(Version("1.2.0.0") == Version("1.2"))
	}

	@Test func stripsPrereleaseSuffix() {
		#expect(Version("1.2.3-beta").components == [1, 2, 3])
	}

	@Test func equalityIsReflexive() {
		#expect(Version("3.1.4") == Version("3.1.4"))
	}
}
