/// LoggingScreen
///
/// A protocol for Types to hold a value for screen tracking.
public protocol LoggableScreen {
    var title: String { get }
    var type: String { get }
}

extension LoggableScreen where Self: RawRepresentable,
                                Self.RawValue == String {
    
    /// Protocol method returning the string value from a Type's `name` property which conforms to this protocol.
    public var title: String {
        rawValue
    }
    
    /// Protocol method returning the string value from a Type's `type` property which conforms to this protocol.
    public var type: String {
        rawValue
    }
}
