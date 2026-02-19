@available(*, deprecated, renamed: "LoggableScreen")
public typealias LoggableScreenV2 = LoggableScreen

public protocol LoggableScreen {
    associatedtype ScreenType: CustomStringConvertible

    var name: String { get }
    var type: ScreenType { get }
}
