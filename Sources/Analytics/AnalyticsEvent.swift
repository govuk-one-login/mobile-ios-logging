/// AnalyticsEvent
///
/// A protocol for Types to hold a value for analytics event logging.
public protocol AnalyticsEvent {
    var name: String { get }
}

extension AnalyticsEvent where Self: RawRepresentable,
                                Self.RawValue == String {
    
    /// Protocol method returning the string value from a Type's `name` property which conforms to this protocol.
    public var name: String {
        rawValue
    }
}
