# HTTPLogging

A HTTPLogging module containing Types usable for HTTP logging.

## Installation

To use HTTPLogging in a project using Swift Package Manager:

1. Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/govuk-one-login/mobile-ios-logging", from: "1.0.0"),
```

2. Add `HTTPLogging` as a dependency for your target:

```swift
.target(name: "MyTarget", dependencies: [
  .product(name: "HTTPLogging", package: "di-mobile-ios-logging"),
  "AnotherModule"
]),
```

3. Add `import HTTPLogging` in your source code.

## Package description

The `HTTPLogging` module contains Types that can be used to build HTTP logging into an app. These Types serve as an interface between app business logic and a third-party analytics service.

> Within this directory exist the following Types for enabling events to be logged to a third-party service for app analytics.

`HTTPLogger` is usable for logging HTTP events through a HTTP network client.

`HTTPLogRequest` is usable as a model for posting `LoggableEvent`s in JSON format.

`AuthorizedHTTPLogger` is similar to `HTTPLogger` but it makes authorized requests.
