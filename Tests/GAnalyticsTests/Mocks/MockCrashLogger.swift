@testable import GAnalytics

final class MockCrashLogger: CrashLogger {
    private(set) var errors: [Error] = []
    private(set) var isCollectionEnabled: Bool?
    
    var paramsToLog: [AnyHashable: Any] = [:]
    var loggedParams: [AnyHashable: Any] = [:]
    
    func record(error: Error) {
        errors.append(error)
        loggedParams = paramsToLog
        paramsToLog = [:]
    }
    
    func setCrashlyticsCollectionEnabled(_ value: Bool) {
        isCollectionEnabled = value
    }
    
    func setCustomKeysAndValues(_ keysAndValues: [AnyHashable: Any]) {
        paramsToLog = keysAndValues
    }
}
