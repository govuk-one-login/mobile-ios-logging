// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Logging",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "Logging", targets: ["Logging"]),
        .library(name: "HTTPLogging", targets: ["HTTPLogging"]),
        .library(name: "GAnalytics", targets: ["GAnalytics"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "10.14.0")
        ),
        .package(
            url: "https://github.com/alphagov/di-mobile-ios-networking.git",
            branch: "main"
        )
    ],
    targets: [
        .target(name: "Logging",
                exclude: ["README.md"],
                swiftSettings: [
                    .define("DEBUG", .when(configuration: .debug))
                ]),
        .testTarget(name: "LoggingTests",
                    dependencies: ["Logging"]),
        
        .target(name: "HTTPLogging",
                dependencies: ["Logging", .product(name: "Networking", package: "di-mobile-ios-networking")],
                exclude: ["README.md"],
                swiftSettings: [
                    .define("DEBUG", .when(configuration: .debug))
                ]),
        .testTarget(name: "HTTPLoggingTests",
                    dependencies: [
                        "HTTPLogging",
                        .product(name: "MockNetworking", package: "di-mobile-ios-networking")
                    ]),
        
        .target(name: "GAnalytics",
                dependencies: [
                    "Logging",
                    .product(name: "FirebaseAnalyticsWithoutAdIdSupport", package: "firebase-ios-sdk"),
                    .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
                ],
                exclude: ["README.md"],
                swiftSettings: [
                    .define("DEBUG", .when(configuration: .debug))
                ])
    ]
)
