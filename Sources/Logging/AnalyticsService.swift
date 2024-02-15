import Foundation

/// AnalyticsService
///
/// A protocol for Types to log analytics to a third-party analytics service.
public protocol AnalyticsService: LoggingService {
    var additionalParameters: [String: Any] { get set }
    
    func trackScreen(_ screen: LoggableScreen)
    func trackScreen(_ screen: LoggableScreen, parameters: [String: Any])
    
    func logCrash(_ crash: NSError)
    func logCrash(_ crash: Error)
    
    func grantAnalyticsPermission()
    func denyAnalyticsPermission()
}

extension AnalyticsService {
    /// Protocol method for screen tracking, calling the conforming type's method for adding screen tracking parameters.
    public func trackScreen(_ screen: LoggableScreen) {
        trackScreen(screen, parameters: [:])
    }
    
    public func trackScreen(_ screen: LoggableScreen, parameters: [String: Any]) {
        trackScreen(screen, parameters: parameters)
    }
    /// Protocol method for crash logging, calling the conforming type's method for passing errors as `NSError`s.
    public func logCrash(_ crash: Error) {
        logCrash(crash as NSError)
    }
}
