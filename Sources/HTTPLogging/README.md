# HTTPLogging

A HTTPLogging module containing Types usable for HTTP logging.

## Installation

To use HTTPLogging in a project using Swift Package Manager:

1. Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/alphagov/di-mobile-ios-logging", from: "1.0.0"),
```

2. Add `HTTPLogging` as a dependency for your target:

```swift
.target(name: "MyTarget", dependencies: [
  .product(name: "HTTPLogging", package: "dcmaw-httplogging"),
  "AnotherModule"
]),
```

3. Add `import HTTPLogging` in your source code.

## Package description

The `HTTPLogging` module contains Types that can be used to build HTTP logging into an app. These Types serve as an interface between app business logic and a third-party analytics service.

> Within this directory exist the following Types for enabling events to be logged to a third-party service for app analytics.

`Logger` is usable for logging HTTP events through a HTTP network client.

`LogRequest` is usable as a model for passing logging events in JSON format.

## Example Implementation

#### Implementing concrete Types conforming to the above protocols:

Having access to values for event names loggable through a HTTP client, conforming to `LoggingEvent` is appropriate. However, this protocol exists in the `Logging` module, in order to conform to this protocol, ensure installation steps 2 and 3 are completed for that module.`Enums` are suitable for making concrete Types conforming to these protocols as they group related values.

```swift
enum MyAppEvents: String, LoggingEvent {
    case buttonTapped
    case linkAccessed
}
```

For larger apps, events can be name-spaced into different enumerations, as required.

#### Example of logging events with the above Types:

Within a UIKit application, initialising a custom class which subclasses `UIViewController` with a `Logger` property is appropriate.

Implementation:
```swift
final class MyViewController: UIViewController {
    let logger: Logger

    init(logger: Logger) {
        super.init()
        self.logger = logger
    }
    
    @IBAction private func didTapButton() {
        logger.logEvent(MyAppEvents.buttonTapped)
    }
}
```

Initialising:
```swift
let logger = Logger(sessionId: 22222222-2222-2222-0222-222222222222,
                    url: URL(string: "https://www.logging.co.uk/endpoint"))
let vc = MyViewController(logger: logger)
```
