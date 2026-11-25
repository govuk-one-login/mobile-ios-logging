import Foundation
import Logging

final class MockPreferenceStore: AnalyticsPreferenceStore {
    private let workQueue = DispatchQueue(label: "mock-preference-store-queue")
    
    nonisolated(unsafe) private var _subscribers = [AsyncStream<Bool>.Continuation]()
    var subscribers: [AsyncStream<Bool>.Continuation] {
        get { workQueue.sync { _subscribers } }
    }
    
    nonisolated(unsafe) private var _hasAcceptedAnalytics: Bool?
    var hasAcceptedAnalytics: Bool? {
        get { workQueue.sync { _hasAcceptedAnalytics } }
        set { workQueue.sync { _hasAcceptedAnalytics = newValue } }
    }
    
    func stream() -> AsyncStream<Bool> {
        AsyncStream { x in
            workQueue.sync { _subscribers.append(x) }
        }
    }
}
