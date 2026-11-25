import Foundation

public protocol AnalyticsPreferenceStore: Sendable {
    var hasAcceptedAnalytics: Bool? { get set }
    func stream() -> AsyncStream<Bool>
}

public final class UserDefaultsPreferenceStore: AnalyticsPreferenceStore {
    nonisolated(unsafe) private let defaults: UserDefaults
    nonisolated(unsafe) private var subscribers = [AsyncStream<Bool>.Continuation]()
    private let workQueue = DispatchQueue(label: "user-defaults-preference-store-work-queue")
    
    init(defaults: UserDefaults) {
        self.defaults = defaults
    }
    
    public var hasAcceptedAnalytics: Bool? {
        get {
            workQueue.sync {
                guard defaults.bool(forKey: DefaultsKey.hasAskedForAnalyticsPermissions.rawValue) else {
                    return nil
                }
                return defaults.bool(forKey: DefaultsKey.hasAcceptedAnalytics.rawValue)
            }
        }
        set {
            let currentValue = self.hasAcceptedAnalytics
            workQueue.sync {
                if let newValue {
                    defaults.set(true, forKey: DefaultsKey.hasAskedForAnalyticsPermissions.rawValue)
                    defaults.set(newValue, forKey: DefaultsKey.hasAcceptedAnalytics.rawValue)
                } else {
                    defaults.set(false, forKey: DefaultsKey.hasAskedForAnalyticsPermissions.rawValue)
                    defaults.set(false, forKey: DefaultsKey.hasAcceptedAnalytics.rawValue)
                }
            }
            
            if
                let updatedValue = self.hasAcceptedAnalytics,
                updatedValue != currentValue
            {
                let localSubscribers = workQueue.sync { subscribers }
                localSubscribers.forEach {
                    $0.yield(updatedValue)
                }
            }
        }
    }
    
    public convenience init() {
        self.init(defaults: .standard)
    }
    
    public func stream() -> AsyncStream<Bool> {
        workQueue.sync {
            AsyncStream { subscriber in
                subscribers.append(subscriber)
            }
        }
    }
    
    private enum DefaultsKey: String {
        case hasAskedForAnalyticsPermissions
        case hasAcceptedAnalytics
    }
}
