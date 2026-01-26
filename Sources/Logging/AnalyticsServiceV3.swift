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
    associatedtype Trace: PerformanceTrace
    associatedtype Metric: PerformanceMetric
    
    var isEnabled: Bool { get }
    
    func enable()
    func disable()
    func startTrace(name: String) -> Trace
    func startHTTPMetric(url: URL, method: String) -> Metric
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

//public enum RequestType: String, RequestProtocol {
//    case get
//    case put
//    case post
//    case delete
//    case head
//    case patch
//    case options
//    case trace
//    case connect
//}

//public protocol RequestType: RawRepresentable, Equatable {
//    static var get: Self { get }
//    static var put: Self { get }
//    static var post: Self { get }
//    static var delete: Self { get }
//    static var head: Self { get }
//    static var patch: Self { get }
//    static var options: Self { get }
//    static var trace: Self { get }
//    static var connect: Self { get }
//}
