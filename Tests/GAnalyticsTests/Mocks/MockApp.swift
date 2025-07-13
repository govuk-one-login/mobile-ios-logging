@testable import GAnalytics

final class MockApp: AnalyticsApp {
    private(set) static var calledConfigure = false
    
    static func configure() {
        calledConfigure = true
    }
    
    static func reset() {
        calledConfigure = false
    }
}
