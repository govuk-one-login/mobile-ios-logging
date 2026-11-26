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
        
        // Should this be replaces by a key value observation on the
        // actual value? This fires if an unrelated UserDefaults
        // value is updated.
        // Martin Nygren, November 2026
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(valueDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    public var hasAcceptedAnalytics: Bool? {
        get { workQueue.sync { readValue() } }
        set { workQueue.sync { writeValue(newValue) } }
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
    
    @objc private func valueDidChange() {
        workQueue.async { [weak self] in
            guard let self, let newValue = self.readValue() else { return }
            
            self.subscribers.forEach {
                $0.yield(newValue)
            }
        }
    }
    
    private func readValue() -> Bool? {
        guard defaults.bool(forKey: DefaultsKey.hasAskedForAnalyticsPermissions.rawValue) else {
            return nil
        }
        return defaults.bool(forKey: DefaultsKey.hasAcceptedAnalytics.rawValue)
    }
    
    private func writeValue(_ newValue: Bool?) {
        if let newValue {
            defaults.set(true, forKey: DefaultsKey.hasAskedForAnalyticsPermissions.rawValue)
            defaults.set(newValue, forKey: DefaultsKey.hasAcceptedAnalytics.rawValue)
        } else {
            defaults.set(false, forKey: DefaultsKey.hasAskedForAnalyticsPermissions.rawValue)
            defaults.set(false, forKey: DefaultsKey.hasAcceptedAnalytics.rawValue)
        }
    }
    
    private enum DefaultsKey: String {
        case hasAskedForAnalyticsPermissions
        case hasAcceptedAnalytics
    }
}
