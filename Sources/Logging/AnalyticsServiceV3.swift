import Foundation

/// AnalyticsServiceV3
///
/// A protocol for Types to log analytics to a third-party analytics service.
public protocol AnalyticsServiceV3: LoggingService {
    var performanceLogger: PerformanceLogger { get }
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

extension AnalyticsServiceV3 {
    /// Protocol method for screen tracking, calling the conforming type's method for adding screen tracking parameters.
    public func trackScreen(_ screen: LoggableScreen) {
        trackScreen(screen, parameters: [:])
    }
}


public protocol PerformanceLogger {
    var isEnabled: Bool { get }
    
    func enable()
    func disable()
    
    func startTrace(name: String) -> PerformanceTrace
    func startHTTPMetric(url: URL, method: RequestType) -> PerformanceMetric
}

public protocol PerformanceTrace {
    func start()
    func stop()
    func incrementMetric(_ name: String, by: Int64)
    func setValue(_ value: Int64, forMetric metricName: String)
    func setValue(_ value: String, forAttribute attribute: String)
    func setValuesForKeys(for keyedValues: [String: any Sendable])
}

public protocol PerformanceMetric {
    var responseCode: Int { get set }
    
    func start()
    func stop()
    func setValue(value: String, forAttribute: String)
}

public enum RequestType: String {
    case get
    case put
    case post
    case delete
    case head
    case patch
    case options
    case trace
    case connect
}
