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
  .product(name: "Logging", package: "di-mobile-ios-logging"),
  "AnotherModule"
]),
```

3. Add `import Logging` in your source code.

## Package description

The `Logging` module contains protocols that can be used for conforming Types to build analytics and logging into an app.

> Within this directory exist the following protocols for conforming Types to enable screens and events to be logged to a third-party service for app analytics and HTTP logging.

`LoggingScreen` is usable for logging screens to the `AnalyticsService`.

`LoggingEvent` is usable for logging events to the `AnalyticsService` and `LoggingService`.

`AnalyticsService` is usable for conforming Types to pass `LoggableEvent`s and `LoggableScreen`s to a cloud analytics package.

`LoggingService` is usable for conforming Types to pass `LoggableEvent`s through a HTTP client.

`AnalyticsStatusProtocol` is usable for checking and setting device preferences on analytics permissions, having conformance on `UserDefaults` within the same file.

## Example Implementation

#### Implementing concrete Types conforming to the above protocols and an a navigation pattern to use them:

Having access to values for screen and event names loggable through a third-party analytics service, conforming to `LoggableScreen` and `LoggableEvent` is appropriate. 

`Enums` are suitable for making concrete Types conforming to these protocols as they group related values.

```swift
enum MyAppScreens: String, LoggableScreen {
    case home
    case settings
}
```

```swift
enum MyAppEvents: String, LoggableEvent {
    case buttonTapped
    case linkAccessed
}
```

#### Using the `AnalyticsService` or `LoggingService` within a UIKit application, injecting when initialising a custom class which subclasses `UIViewController`.

```swift
final class MyViewController: UIViewController {
    let logger: LoggingService

    init(logger: LoggingService) {
        super.init()
        self.logger = logger
    }
    
    @IBAction private func didTapButton() {
        logger.logEvent(MyAppEvents.buttonTapped)
    }
}
```

When the UI calls `didTapButton()` a JSON would be posted in the format:

```
{
    "sessionId" : "22222222-2222-2222-0222-222222222222",
    "eventName" : "buttonTapped"
}
```

#### Using the `AnalyticsService` or `LoggingService` within a UIKit application which conforms to the the Coordinator pattern.

> Using the Coordinator pattern as detailed in the README.md file of the [Coordination](https://github.com/alphagov/di-mobile-ios-coordination) package.

```swift
final class MyCoordinator: NavigationCoordinator {
    let root: UINavigationController
    let analyticsService: AnalyticsService
    
    init(root: UINavigationController,
         analyticsService: AnalyticsService) {
         self.root = root
         self.analyticsService = analyticsService
    }
    
    func start() {
        ...
    }
}
```

This instance of AnalyticsService can then be injected into other Type instances through your coordinator. A common use case is creating a custom class which subclasses `UIViewController`. Implementing the required analytics calls within your view controller.

```swift
final class MyViewController: UIViewController {
    let analyticsService: AnalyticsService

    init(analyticsService: AnalyticsService) {
        super.init()
        self.analyticsService = analyticsService
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.trackScreen(MyAppScreens.home)
    }
    
    @IBAction private func didTapButton() {
        analyticsService.logEvent(MyAppEvents.buttonTapped)
    }
}
```

Example implementations for the protocols in this module can be seen in the files of the [HTTPLogging](../HTTPLogging) and [GAnalytics](../GAnalytics) directories in this package.
