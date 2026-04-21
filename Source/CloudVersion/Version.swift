import Foundation

public struct Version: Sendable, Comparable, CustomStringConvertible {
	public let components: [Int]

	public init(_ string: String) {
		let trimmed = string.split(separator: "-", maxSplits: 1).first.map(String.init) ?? string
		self.components = trimmed
			.split(separator: ".")
			.map { Int($0) ?? 0 }
	}

	public init(components: [Int]) {
		self.components = components
	}

	public var description: String {
		components.map(String.init).joined(separator: ".")
	}

	public static func < (lhs: Version, rhs: Version) -> Bool {
		let count = max(lhs.components.count, rhs.components.count)
		for index in 0..<count {
			let l = index < lhs.components.count ? lhs.components[index] : 0
			let r = index < rhs.components.count ? rhs.components[index] : 0
			if l != r { return l < r }
		}
		return false
	}

	public static func == (lhs: Version, rhs: Version) -> Bool {
		let count = max(lhs.components.count, rhs.components.count)
		for index in 0..<count {
			let l = index < lhs.components.count ? lhs.components[index] : 0
			let r = index < rhs.components.count ? rhs.components[index] : 0
			if l != r { return false }
		}
		return true
	}
}
