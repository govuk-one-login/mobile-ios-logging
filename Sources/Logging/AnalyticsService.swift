import Foundation

@available(*, deprecated, renamed: "AnalyticsService")
public typealias AnalyticsServiceV2 = AnalyticsService

/// AnalyticsService
///
/// A protocol for Types to log analytics to a third-party analytics service.
public protocol AnalyticsService: LoggingService {
    var analyticsPreferenceStore: AnalyticsPreferenceStore { get }
    
    var additionalParameters: [String: Any] { get set }
    func addingAdditionalParameters(_ additionalParameters: [String: Any]) -> Self
 
    func trackScreen(_ screen: any LoggableScreen, parameters: [String: Any])
    
    func logCrash(_ crash: NSError)
    func logCrash(_ crash: Error)
}
