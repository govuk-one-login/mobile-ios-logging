import FirebaseCrashlytics

protocol CrashLogger {
    func record(error: Error)
    func setCrashlyticsCollectionEnabled(_ value: Bool)
    func setCustomKeysAndValues(_ keysAndValues: [AnyHashable : Any])
    func setCustomValue(_ value: Any?, forKey: String)
}

extension Crashlytics: CrashLogger {}
