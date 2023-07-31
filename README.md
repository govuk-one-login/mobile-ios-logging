# Logging

A Swift Package usable for HTTP logging and passing analytics to a third-party SDK, also included is an abstraction class for using Google's Firebase analytics platform.

## Installation

To use this Logging package in a project using Swift Package Manager:

1. Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/alphagov/di-mobile-ios-logging", from: "1.0.0"),
```

2. Add any of `Logging`, `Analytics` and/or `GAnalytics` as a dependencies for your target:

```swift
.target(name: "MyTarget", dependencies: [
  .product(name: "Logging", package: "dcmaw-logging"),
  .product(name: "Analytics", package: "dcmaw-logging"),
  .product(name: "GAnalytics", package: "dcmaw-logging"),
]),
```

3. Add `import Logging`, `import Analytics` and/or `import GAnalytics` into your source codewhere necessary.

## Package description

For individual descriptions of the modules in this package, head to the README files for each:

[Logging](./Sources/Logging/README.md)

[Analytics](./Sources/Analytics/README.md)

[GAnalytics](./Sources/GAnalytics/README.md)
