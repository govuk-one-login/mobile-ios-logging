import Foundation

/// AnalyticsService
///
/// A protocol for Types to write to Google's cloud analytics service, Firebase.
public protocol AnalyticsService {
    var additionalParameters: [String: Any] { get set }
    
    func trackScreen(_ screen: AnalyticsScreen)
    func trackScreen(_ screen: AnalyticsScreen, parameters: [String: Any])
    
    func logEvent(_ event: AnalyticsEvent)
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any])
    
    func logCrash(_ crash: Error)
    
    func grantAnalyticsPermission()
    func denyAnalyticsPermission()
}

extension AnalyticsService {
    /// Protocol method for screen tracking, calling the conforming type's method for adding screen tracking parameters.
    public func trackScreen(_ screen: AnalyticsScreen) {
        trackScreen(screen, parameters: [:])
    }
    
    public func logEvent(_ event: AnalyticsEvent) {
        logEvent(event, parameters: [:])
    }
    
    public func logCrash(_ crash: Error) {
        logCrash(crash as NSError)
    }
}
