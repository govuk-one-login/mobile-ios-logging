import FirebaseAnalytics

protocol AnalyticsLogger {
    static func logEvent(_ name: String, parameters: [String: Any]?)
    
    static func setAnalyticsCollectionEnabled(_ value: Bool)
    static func resetAnalyticsData()
}

extension Analytics: AnalyticsLogger { }
