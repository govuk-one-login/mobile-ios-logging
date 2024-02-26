@testable import GAnalytics

final class MockAnalyticsLogger: AnalyticsLogger {
    struct Event: Equatable {
        let name: String
        let parameters: [String: String]
    }
    
    private(set) static var events: [Event] = []
    private(set) static var didResetAnalyticsData: Bool = false
    private(set) static var isAnalyticsCollectionEnabled: Bool? = nil
    
    static func logEvent(_ name: String, parameters: [String: Any]?) {
        guard let parameters = parameters as? [String: String] else {
            preconditionFailure("Expected parameters dictionary to contain String values only.")
        }
        events.append(Event(name: name, parameters: parameters))
    }
    
    static func setAnalyticsCollectionEnabled(_ value: Bool) {
        isAnalyticsCollectionEnabled = value
    }
    
    static func resetAnalyticsData() {
        didResetAnalyticsData = true
    }
    
    static func reset() {
        events = []
    }
}
