import Foundation

/// AnalyticsService
///
/// A protocol for Types to write to Google's cloud analytics service, Firebase.
public protocol AnalyticsService: LoggingService {
    var additionalParameters: [String: Any] { get set }
    
    func trackScreen(_ screen: LoggingScreen)
    func trackScreen(_ screen: LoggingScreen, parameters: [String: Any])
    
    func logCrash(_ crash: NSError)
    func logCrash(_ crash: Error)
    
    func grantAnalyticsPermission()
    func denyAnalyticsPermission()
}

extension AnalyticsService {
    /// Protocol method for screen tracking, calling the conforming type's method for adding screen tracking parameters.
    public func trackScreen(_ screen: LoggingScreen) {
        trackScreen(screen, parameters: [:])
    }
    
    public func logCrash(_ crash: Error) {
        logCrash(crash as NSError)
    }
}
