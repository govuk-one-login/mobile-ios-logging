import FirebaseAnalytics

protocol AnalyticsLogger {
    static func logEvent(_ name: String, parameters: [String: Any]?)
}

extension Analytics: AnalyticsLogger { }
