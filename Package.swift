// swift-tools-version: 6.2

import PackageDescription

let package = Package(
	name: "CloudVersion",
	platforms: [
		.macOS(.v14),
		.iOS(.v17),
		.watchOS(.v10),
		.tvOS(.v17),
		.visionOS(.v1),
	],
	products: [
		.library(name: "CloudVersion", targets: ["CloudVersion"]),
	],
	dependencies: [
	],
	targets: [
		.target(name: "CloudVersion", dependencies: [
		]),
		.testTarget(name: "CloudVersionTests", dependencies: ["CloudVersion"]),
	]
)
