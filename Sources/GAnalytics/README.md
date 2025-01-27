#  GAnalytics

A concrete implementation of the `AnalyticsService` protocol if the chosen analytics platform is Google's Firebase.

## Installation

To use GAnalytics in a project using Swift Package Manager:

1. Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/govuk-one-login/mobile-ios-logging", from: "1.0.0"),
```

2. Add `GAnalytics` as a dependency for your target:

```swift
.target(name: "MyTarget", dependencies: [
  .product(name: "GAnalytics", package: "di-mobile-ios-logging"),
  "AnotherModule"
]),
```

3. Add `import GAnalytics` in your source code.

## Package description

The `GAnalytics` module contains a concrete class implementation of the `AnalyticsService` protocol which specifically serves as an interface between app business logic and a third-party analytics service, in this case, Google's Firebase.

> Within this directory exists the following Type for enabling events to be logged to a third-party service for app analytics, in this case, Google's Firebase.

`GAnalytics` is usable for logging events and tracking screens to the `Firebase` module.

## Example Implementation

#### Using the concrete Type above conforming to the `AnalyticsService`:

 Initialising the `GAnalytics` class within the `AppDelegate`'s `application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool` method is appropriate.

```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    GAnalytics().configure()
    return true
}
```

