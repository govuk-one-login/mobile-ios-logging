# Analytics

An Analytics module containing protocols usable for conforming Types to pass analytics data to a third-party SDK.

## Installation

To use Analytics in a project using Swift Package Manager:

1. Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/alphagov/di-mobile-ios-logging", from: "1.0.0"),
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

The `Analytics` module contains protocols that can be used for conforming Types to build analytics into an app.

> Within this directory exist the following protocols and Types for enabling screens and events being logged to a third-party service for app analytics.

`AnalyticsEvent` is usable for logging events to the `AnalyticsService`.

`AnalyticsScreen` is usable for logging screens to the `AnalyticsService`.

`AnalyticsService` is usable for conforming Types to pass events and screens to a cloud analytics package.

`AnalyticsStatusProtocol` is usable for checking and setting device preferences on analytics permissions, applying the protocol on `UserDefaults` within the same file.

## Example Implementation

#### Implementing concrete Types conforming to the above protocols:

Having access to values for screen or event names loggable in an analytics platform, conforming to `AnalyticsScreen` or `AnalyticsEvent` is appropriate. `Enums` are suitable for making concrete Types conforming to these protocols as they group related values.

```swift
enum MyAppScreens: String, AnalyticsScreen {
    case home
    case settings
}
```

```swift
enum MyAppEvents: String, AnalyticsEvent {
    case buttonTapped
    case linkAccessed
}
```

For larger apps, screens can be name-spaced into different enumerations, as required.

`GAnalytics` is an appropriate implementation of `AnalyticsService` if the chosen analytics platform is Google's Firebase, the below example will detail typical use based on the assumption of this choice.

#### Example of logging analytic screens and events with the above Types:

Using the Coordinator pattern as detailed in the README.md file of this [Coordination](https://github.com/alphagov/di-mobile-ios-coordination) package, initialising a concrete class implementation of `AnalyticsService` is appropriate. Typically, initialising the concrete implementation of `AnalyticsService`  by default when initialising a main coordinator. Alternatively, initialising the concrete implementation of `AnalyticsService` within the `AppDelegate`'s `application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool` is appropriate.

```swift
final class MainCoordinator: NavigationCoordinator {
    let root: UINavigationController
    let analyticsService: AnalyticsService
    
    init(root: UINavigationController,
         analyticsService: AnalyticsService = MyAnalyticsClass()) {
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
    MyAnalyticsClass().configure()
    return true
}
```

This instance of `MyAnalyticsClass` can then be injected into other Type instances through your main coordinator. A common use case is creating a view controller (a custom Type subclassing `UIViewController`). Implementing the required analytics calls within your view controller.

```swift
final class MyViewController: UIViewController {
    let analyticsService: AnalyticsService

    init(analyticsService: AnalyticsService = .none) {
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
