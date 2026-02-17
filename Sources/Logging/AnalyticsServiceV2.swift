import Foundation

/// AnalyticsServiceV2
///
/// A protocol for Types to log analytics to a third-party analytics service.
public protocol AnalyticsServiceV2: LoggingService {
    var analyticsPreferenceStore: AnalyticsPreferenceStore { get }
    
    var additionalParameters: [String: Any] { get set }
    func addingAdditionalParameters(_ additionalParameters: [String: Any]) -> Self
 
    func trackScreen(_ screen: any LoggableScreenV2, parameters: [String: Any])
    
    func logCrash(_ crash: NSError)
    func logCrash(_ crash: Error)
}
