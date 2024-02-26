@testable import GAnalytics

final class MockCrashLogger: CrashLogger {
    private(set) var errors: [Error] = []
    private(set) var isCollectionEnabled: Bool?
    
    func record(error: Error) {
        errors.append(error)
    }
    
    func setCrashlyticsCollectionEnabled(_ value: Bool) {
        isCollectionEnabled = value
    }
}
