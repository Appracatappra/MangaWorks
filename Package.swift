// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MangaWorks",
    platforms: [.iOS(.v17), .tvOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MangaWorks",
            targets: ["MangaWorks"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Appracatappra/LogManager", .upToNextMajor(from: "1.0.1")),
        .package(url: "https://github.com/Appracatappra/SwiftletUtilities", .upToNextMajor(from: "1.1.1")),
        .package(url: "https://github.com/Appracatappra/SoundManager", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/Appracatappra/SimpleSerializer", .upToNextMajor(from: "1.0.5")),
        .package(url: "https://github.com/Appracatappra/GraceLanguage", .upToNextMajor(from: "1.0.3")),
        .package(url: "https://github.com/Appracatappra/SwiftUIKit.git", .upToNextMajor(from: "1.0.11")),
        .package(url: "https://github.com/Appracatappra/SpeechManager", .upToNextMajor(from: "1.0.4")),
        .package(url: "https://github.com/Appracatappra/SwiftUIGamepad.git", .upToNextMajor(from: "1.0.3")),
        .package(url: "https://github.com/Appracatappra/SwiftUIPanoramaViewer.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MangaWorks",
            dependencies: ["LogManager", "SwiftletUtilities", "SoundManager", "SimpleSerializer", "GraceLanguage", "SwiftUIKit", "SpeechManager", "SwiftUIGamepad", "SwiftUIPanoramaViewer"],
            resources: [.process("Resources"), .process("Fonts")]
        ),
        .testTarget(
            name: "MangaWorksTests",
            dependencies: ["MangaWorks"]),
    ]
)
