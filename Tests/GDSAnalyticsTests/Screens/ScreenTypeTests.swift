@testable import GDSAnalytics
import XCTest

final class ScreenTypeTests: XCTestCase {
    func testNameConformance() {
        XCTAssertEqual(
            MockScreenType.drivingLicenceFrontInstructions.name,
            "drivingLicenceFrontInstructions"
        )
        XCTAssertEqual(
            MockScreenType.drivingLicenceFrontInstructions.description,
            "drivingLicenceFrontInstructions"
        )
    }
}

enum MockScreenType: String, ScreenType {
    case drivingLicenceFrontInstructions
}
