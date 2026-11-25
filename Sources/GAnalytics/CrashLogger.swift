import FirebaseCrashlytics

extension Crashlytics: @retroactive @unchecked Sendable { }

protocol CrashLogger: Sendable {
    func record(error: Error, userInfo: [String: Any]?)
    func setCrashlyticsCollectionEnabled(_ value: Bool)
}

extension Crashlytics: CrashLogger {}
