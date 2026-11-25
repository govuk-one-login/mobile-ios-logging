import FirebaseAnalytics

extension Analytics: @retroactive @unchecked Sendable { }

protocol AnalyticsLogger: Sendable {
    static func logEvent(_ name: String, parameters: [String: Any]?)
    
    static func setAnalyticsCollectionEnabled(_ value: Bool)
    static func resetAnalyticsData()
}

extension Analytics: AnalyticsLogger { }
