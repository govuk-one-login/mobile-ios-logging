@testable import GAnalytics

final class MockApp: AnalyticsApp {
    private(set) static var calledConfigure: Bool = false
    
    static func configure() {
        calledConfigure = true
    }
}
