import Firebase

extension FirebaseApp: @retroactive @unchecked Sendable { }

protocol AnalyticsApp: Sendable {
    static func configure()
}

extension FirebaseApp: AnalyticsApp { }
