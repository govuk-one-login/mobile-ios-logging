import Firebase

protocol AnalyticsApp {
    static func configure()
}

extension FirebaseApp: AnalyticsApp { }
