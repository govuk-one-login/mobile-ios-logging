import Foundation
@testable import GAnalytics

final class MockCrashLogger: CrashLogger {
    nonisolated(unsafe) private var _errors: [Error] = []
    var errors: [Error] {
        workQueue.sync { _errors }
    }
    nonisolated(unsafe) private var _isCollectionEnabled: Bool?
    var isCollectionEnabled: Bool? {
        workQueue.sync { _isCollectionEnabled }
    }
    nonisolated(unsafe) private var _loggedParams: [AnyHashable: Any]? = [:]
    var loggedParams: [AnyHashable: Any]? {
        workQueue.sync { _loggedParams }
    }
    private let workQueue = DispatchQueue(label: "mock-analytics-logger-queue")
    
    func record(error: Error, userInfo: [String: Any]?) {
        workQueue.sync {
            _errors.append(error)
            _loggedParams = userInfo
        }
    }
    
    func setCrashlyticsCollectionEnabled(_ value: Bool) {
        workQueue.sync {
            _isCollectionEnabled = value
        }
    }
}
