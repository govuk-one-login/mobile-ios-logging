@testable import Analytics
import XCTest

final class AnalyticsScreenTests: XCTestCase {
    func testNameConformance() {
        XCTAssertEqual(MockAnalyticsScreen.drivingLicenceFrontInstructions.name,
                       "drivingLicenceFrontInstructions")
    }
}

enum MockAnalyticsScreen: String, AnalyticsScreen {
    case drivingLicenceFrontInstructions
}
