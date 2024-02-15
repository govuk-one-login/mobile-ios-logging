/// LoggingScreen
///
/// A protocol for Types to hold a value for screen tracking.
public protocol LoggableScreen {
    var title: String { get }
    var type: String { get }
    var screenID: String { get }
}
