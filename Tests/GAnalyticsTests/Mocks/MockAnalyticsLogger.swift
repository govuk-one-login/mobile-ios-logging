import Foundation
@testable import GAnalytics

final class MockAnalyticsLogger: AnalyticsLogger {
    struct Event: Equatable {
        let name: String
        let parameters: [String: String]
    }
    
    nonisolated(unsafe) private static var _events: [Event] = []
    static var events: [Event] { workQueue.sync { _events } }
    nonisolated(unsafe) private static var _didResetAnalyticsData: Bool = false
    static var didResetAnalyticsData: Bool { workQueue.sync { _didResetAnalyticsData } }
    nonisolated(unsafe) private static var _isAnalyticsCollectionEnabled: Bool?
    static var isAnalyticsCollectionEnabled: Bool? { workQueue.sync { _isAnalyticsCollectionEnabled } }
    
    private static let workQueue = DispatchQueue(label: "mock-analytics-logger-queue")
    
    static func logEvent(_ name: String, parameters: [String: Any]?) {
        guard let parameters = parameters as? [String: String] else {
            preconditionFailure("Expected parameters dictionary to contain String values only.")
        }
        workQueue.sync { _events.append(.init(name: name, parameters: parameters)) }
    }
    
    static func setAnalyticsCollectionEnabled(_ value: Bool) {
        workQueue.sync { _isAnalyticsCollectionEnabled = value }
    }
    
    static func resetAnalyticsData() {
        workQueue.sync { _didResetAnalyticsData = true }
    }
    
    static func reset() {
        workQueue.sync { _events = [] }
    }
}
