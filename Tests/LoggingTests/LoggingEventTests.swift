@testable import Logging
import XCTest

final class LoggingEventTests: XCTestCase {
    func testNameConformance() {
        XCTAssertEqual(MockAnalyticsEvent.completedIDCheck.name,
                       "completedIDCheck")
    }
}

enum MockAnalyticsEvent: String, LoggingEvent {
    case completedIDCheck
}
