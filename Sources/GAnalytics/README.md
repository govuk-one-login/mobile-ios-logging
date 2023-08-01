#  GAnalytics

A concrete class implementation of the `AnalyticsService` protocol if the chosen analytics platform is Google's Firebase.

## Installation

To use GAnalytics in a project using Swift Package Manager:

1. Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/alphagov/di-mobile-ios-logging", from: "1.0.0"),
```

2. Add `GAnalytics` as a dependency for your target:

```swift
.target(name: "MyTarget", dependencies: [
  .product(name: "GAnalytics", package: "dcmaw-ganalytics"),
  "AnotherModule"
]),
```

3. Add `import GAnalytics` in your source code.

## Package description

The `GAnalytics` module contains a concrete class implementation of the `AnalyticsService` protocol which specifically serves as an interface between app business logic and a third-party analytics service, in this case, Google's Firebase.

> Within this directory exists the following Type for enabling events to be logged to a third-party service for app analytics, in this case, Google's Firebase.

`GAnalytics` is usable for logging events to the `Analytics` module.

## Example Implementation

#### Using the concrete Type above conforming to the `AnalyticsService`:

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

This instance of `GAnalytics` can then be injected into other Type instances through your main coodordinator. A common use case is creating a view controller (A custom Type subclassing `UIViewController`). Implementing the required analytics calls within your view controller

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
