import Foundation

public enum Platform: String, Sendable, CaseIterable {
	case iOS, macOS, watchOS, tvOS, visionOS

	public static var current: Platform {
		#if os(macOS)
		return .macOS
		#elseif os(watchOS)
		return .watchOS
		#elseif os(tvOS)
		return .tvOS
		#elseif os(visionOS)
		return .visionOS
		#else
		return .iOS
		#endif
	}
}
