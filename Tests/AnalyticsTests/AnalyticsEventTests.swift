@testable import Analytics
import XCTest

final class AnalyticsEventTests: XCTestCase {
    func testNameConformance() {
        XCTAssertEqual(MockAnalyticsEvent.completedIDCheck.name,
                       "completedIDCheck")
    }
}

enum MockAnalyticsEvent: String, AnalyticsEvent {
    case completedIDCheck
}
