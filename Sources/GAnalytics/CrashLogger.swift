import FirebaseCrashlytics

protocol CrashLogger {
    func record(error: Error)
    func setCrashlyticsCollectionEnabled(_ value: Bool)
}

extension Crashlytics: CrashLogger { }
