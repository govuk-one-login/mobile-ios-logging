public protocol LoggableScreen {
    associatedtype ScreenType: CustomStringConvertible

    var name: String { get }
    var type: ScreenType { get }
}
