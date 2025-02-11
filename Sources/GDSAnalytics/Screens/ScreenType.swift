@available(*, deprecated, renamed: "ScreenType")
public typealias NamedScreen = ScreenType

public protocol ScreenType: CustomStringConvertible {
    var name: String { get }
}

extension ScreenType {
    public var description: String {
        name
    }
}

extension ScreenType where Self: RawRepresentable,
                           Self.RawValue == String {
    
    /// Protocol method returning the string value from a Type's `name` property which conforms to this protocol.
    public var name: String {
        rawValue
    }
}
