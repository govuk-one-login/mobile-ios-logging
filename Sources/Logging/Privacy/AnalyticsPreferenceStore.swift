import Foundation

@available(macOS 10.15, *)
public protocol AnalyticsPreferenceStore {
    var hasAcceptedAnalytics: Bool? { get set }
    func stream() -> AsyncStream<Bool>
}

@available(macOS 10.15, *)
public final class UserDefaultsPreferenceStore: AnalyticsPreferenceStore {
    private let defaults: UserDefaults
    private var subscribers: [AsyncStream<Bool>.Continuation] = []
    
    init(defaults: UserDefaults) {
        self.defaults = defaults
        
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(valueDidChange),
                         name: UserDefaults.didChangeNotification,
                         object: nil)
    }
    
    public var hasAcceptedAnalytics: Bool? {
        get {
            return value(for: .hasAcceptedAnalytics)
        }
        set {
            guard let newValue else { return }
            defaults.set(newValue, forKey: DefaultsKey.hasAcceptedAnalytics.rawValue)
        }
    }
    
    public convenience init() {
        self.init(defaults: .standard)
    }
    
    @objc private func valueDidChange() {
        guard let newValue = hasAcceptedAnalytics else { return }
        subscribers.forEach {
            $0.yield(newValue)
        }
    }
    
    private func value(for key: DefaultsKey) -> Bool {
        defaults.bool(forKey: key.rawValue)
    }
    
    public func stream() -> AsyncStream<Bool> {
        AsyncStream { subscriber in
            subscribers.append(subscriber)
        }
    }
    
    private enum DefaultsKey: String {
        case hasAcceptedAnalytics
    }
}
