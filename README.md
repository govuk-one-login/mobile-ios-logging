# Analytics

Implementation of Analytics.

## Installation

To use Analytics in a SwiftPM project:

1. Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/alphagov/di-ipv-dca-mob-ios", from: "1.0.0"),
```

2. Add `Analytics` as a dependency for your target:

```swift
.target(name: "MyTarget", dependencies: [
  .product(name: "Analytics", package: "dcmaw-analytics"),
  "AnotherModule"
]),
```

3. Add `import Analytics` in your source code.

## Package description

The main `Analytics` Package contains protocols and an empty implementation that can be used to build analytics into the app before a concrete implementation is known.

> Within Sources/Analytics exist the following protocols and Type for enabling screens and events being logged to a service for app analytics

`LoggingEvent` is usable for logging events to the `AnalyticsService`

`AnalyticsScreen` is usable for logging screens to the `AnalyticsService`

`AnalyticsService` is usable for passing events and screens to a cloud analytics package

`AnalyticsStatusProtocol` is usable for checking and setting device preferences on analytics permissions, applying the protocol on `UserDefaults` within the same file

`GAnalytics` is usable for a concrete implementation of `AnalyticsServide` which is explicitly tied to Google's Firebase analytics platform

## Example Implementation

#### Implementing concrete Types conforming to the above protocols:

Having access to values for screen names loggable in an analytics platform, conforming to `AnalyticsScreen` or `LoggingEvent` is appropriate. `Enums` are suitable for making concrete Types conforming to these protocols as they group related values.

```swift
enum MyAppScreens: String, AnalyticsScreen {
    case home
    case settings
}
```

```swift
enum MyAppEvents: String, LoggingEvent {
    case buttonTapped
    case linkAccessed
}
```

For larger apps, screens can be name-spaced into different enumerations, as required.

`GAnalytics` is an appropriate implementation of `AnalyticsService` if the chosen analytics platform is Google's Firebase, the below example will detail typical use based on the assumption of this choice

#### Example of logging analytic screens and events with the above Types:

Using the Coordinator pattern as detailed in the README.md file of the `Coordination` package in this repository, initialising the `GAnalytics` class is appropriate. Typically, initialising the `GAnalytics` class by deault when initialising a main coordinator. Alternatively, initialising the `GAnalytics` class within the `AppDelegate`'s `application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool` is appropriate.

```swift
final class MainCoordinator: NavigationCoordinator {
    let root: UINavigationController
    let analyticsService: AnalyticsService
    
    init(root: UINavigationController,
         analyticsService: AnalyticsService = GAnalytics()) {
         self.root = root
         self.analyticsService = analyticsService
    }
    
    func start() {
        ...
    }
}
```

OR

```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    GAnalytics().configure()
    return true
}
```

This instance of `GAnalytics` can then be injected into other Type instances through your main coodordinator. A common use case is creating a view controller (A vustom Type subclassing `UIViewController`). Implementing the required analytics calls within your view controller

```swift
final class ViewController: UIViewController {
    let analyticsService: AnalyticsService

    init(analyticsService: AnalyticsService = .none) {
        self.analyticsService = analyticsService
        super.init()
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
