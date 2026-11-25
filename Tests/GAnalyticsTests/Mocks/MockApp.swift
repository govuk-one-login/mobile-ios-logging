import Foundation
@testable import GAnalytics

final class MockApp: AnalyticsApp {
    nonisolated(unsafe) private(set) static var calledConfigure = false
    static let workQueue = DispatchQueue(label: "mock-analytics-app-queue")
    
    static func configure() {
        workQueue.sync { calledConfigure = true }
    }
    
    static func reset() {
        workQueue.sync { calledConfigure = false }
    }
}
