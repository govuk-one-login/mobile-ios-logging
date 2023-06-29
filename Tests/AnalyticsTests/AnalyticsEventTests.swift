@testable import Analytics
import XCTest

final class AnalyticsEventTests: XCTestCase {
    func testNameConformance() {
        XCTAssertEqual(MockAnalyticsEvent.completedIDCheck.name,
                       "completedIDCheck")
    }
}

enum MockAnalyticsEvent: String, LoggingEvent {
    case completedIDCheck
}
