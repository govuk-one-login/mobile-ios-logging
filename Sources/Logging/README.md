# Logging

A Logging module containing protocols usable for conforming Types to pass analytics data to a third-party SDK and HTTP logging.

## Installation

To use Logging in a project using Swift Package Manager:

1. Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/alphagov/di-mobile-ios-logging", from: "1.0.0"),
```

2. Add `Logging` as a dependency for your target:

```swift
.target(name: "MyTarget", dependencies: [
  .product(name: "Logging", package: "dcmaw-logging"),
  "AnotherModule"
]),
```

3. Add `import Logging` in your source code.

## Package description

The `Logging` module contains protocols that can be used for conforming Types to build analytics and logging into an app.

> Within this directory exist the following protocols and Types for enabling screens and events being logged to a third-party service for app analytics and HTTP logging.

`LoggingEvent` is usable for logging events to the `AnalyticsService`.

`LoggingScreen` is usable for logging screens to the `AnalyticsService`.

`LoggingService` is usable for conforming Types to pass `LoggingEvent`s through a HTTP client.

`AnalyticsService` is usable for conforming Types to pass `LoggingEvent`s and `LoggingScreen`s to a cloud analytics package.

`AnalyticsStatusProtocol` is usable for checking and setting device preferences on analytics permissions, having conformance on `UserDefaults` within the same file.

## Example Implementation

Example implementations for the protocols in this module can be seen in the files and `README`s of the [HTTPLogging](../HTTPLogging) and [GAnalytics](../GAnalytics) directories in this package.
