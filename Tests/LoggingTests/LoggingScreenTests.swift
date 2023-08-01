@testable import Logging
import XCTest

final class LoggingScreenTests: XCTestCase {
    func testNameConformance() {
        XCTAssertEqual(MockAnalyticsScreen.drivingLicenceFrontInstructions.name,
                       "drivingLicenceFrontInstructions")
    }
}

enum MockAnalyticsScreen: String, LoggingScreen {
    case drivingLicenceFrontInstructions
}
