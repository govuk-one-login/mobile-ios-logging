/// AnalyticsScreen
///
/// A protocol for Types to hold a value for screen tracking.
public protocol AnalyticsScreen {
    var name: String { get }
}

extension AnalyticsScreen where Self: RawRepresentable,
                                Self.RawValue == String {
    
    /// Protocol method returning the string value from a Type's `name` property which conforms to this protocol.
    public var name: String {
        rawValue
    }
}
