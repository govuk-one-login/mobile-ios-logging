// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Logging",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "Analytics", targets: ["Analytics"]),
        .library(name: "Logging", targets: ["Logging"]),
        .library(name: "GAnalytics", targets: ["GAnalytics"])
    ],
    dependencies: [
      .package(
        url: "https://github.com/firebase/firebase-ios-sdk.git",
        .upToNextMajor(from: "9.4.1")
      ),
      .package(
        url: "https://github.com/alphagov/di-mobile-ios-networking.git",
        .upToNextMajor(from: "1.0.0")
      )
    ],
    targets: [
        .target(name: "Analytics",
                swiftSettings: [
                    .define("DEBUG", .when(configuration: .debug))
                ]),
        .testTarget(name: "AnalyticsTests", dependencies: ["Analytics"]),
        
        .target(
            name: "Logging",
            dependencies: ["Analytics", .product(name: "Networking",
                                                 package: "di-mobile-ios-networking")],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ]),
        .testTarget(name: "LoggingTests", dependencies: [
            "Logging",
            .product(name: "MockNetworking", package: "di-mobile-ios-networking")
        ]),
        
        .target(name: "GAnalytics", dependencies: [
            "Analytics",
            .product(name: "FirebaseAnalyticsWithoutAdIdSupport", package: "firebase-ios-sdk"),
            .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
        ], swiftSettings: [
            .define("DEBUG", .when(configuration: .debug))
        ])
    ]
)
