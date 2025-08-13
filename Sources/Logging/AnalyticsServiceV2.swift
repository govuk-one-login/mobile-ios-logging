import Foundation

/// AnalyticsServiceV2
///
/// A protocol for Types to log analytics to a third-party analytics service.
public protocol AnalyticsServiceV2: LoggingService {
    var analyticsPreferenceStore: AnalyticsPreferenceStore { get }
    
    var additionalParameters: [String: Any] { get set }
    func addingAdditionalParameters(_ additionalParameters: [String: Any]) -> Self
    
    @available(*, deprecated, renamed: "trackScreen", message: "Please use LoggableScreenV2")
    func trackScreen(_ screen: LoggableScreen)
    
    @available(*, deprecated, renamed: "trackScreen", message: "Please use LoggableScreenV2")
    func trackScreen(_ screen: LoggableScreen, parameters: [String: Any])
    
    func trackScreen(_ screen: any LoggableScreenV2, parameters: [String: Any])
    
    func logCrash(_ crash: NSError)
    func logCrash(_ crash: Error)
}

extension AnalyticsServiceV2 {
    /// Protocol method for screen tracking, calling the conforming type's method for adding screen tracking parameters.
    public func trackScreen(_ screen: LoggableScreen) {
        trackScreen(screen, parameters: [:])
    }
}
