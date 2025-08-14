@testable import GAnalytics

final class MockCrashLogger: CrashLogger {
    private(set) var errors: [Error] = []
    private(set) var isCollectionEnabled: Bool?

    var loggedParams: [AnyHashable: Any]? = [:]
    
    func record(error: Error, userInfo: [String : Any]?) {
        errors.append(error)
        loggedParams = userInfo
    }
    
    func setCrashlyticsCollectionEnabled(_ value: Bool) {
        isCollectionEnabled = value
    }
}
