public protocol LoggableScreenV2 {
    associatedtype ScreenType: CustomStringConvertible

    var name: String { get }
    var type: ScreenType { get }
}
