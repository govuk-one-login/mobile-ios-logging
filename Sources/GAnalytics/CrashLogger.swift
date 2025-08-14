import FirebaseCrashlytics

protocol CrashLogger {
    func record(error: Error, userInfo: [String : Any]?)
    func setCrashlyticsCollectionEnabled(_ value: Bool)
}

extension Crashlytics: CrashLogger {}
