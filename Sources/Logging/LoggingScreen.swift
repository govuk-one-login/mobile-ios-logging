/// LoggingScreen
///
/// A protocol for Types to hold a value for screen tracking.
public protocol LoggingScreen {
    var name: String { get }
}

extension LoggingScreen where Self: RawRepresentable,
                                Self.RawValue == String {
    
    /// Protocol method returning the string value from a Type's `name` property which conforms to this protocol.
    public var name: String {
        rawValue
    }
}
