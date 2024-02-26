@testable import GAnalytics
import Logging
import XCTest

final class GAnalyticsTests: XCTestCase {
    private var sut: GAnalytics!
    private var logger: MockAnalyticsLogger.Type!
    
    override func setUp() {
        super.setUp()
        
        logger = MockAnalyticsLogger.self
        sut = GAnalytics(analytics: logger)
    }
    
    override func tearDown() {
        sut = nil
        logger.reset()
        logger = nil
        super.tearDown()
    }
}

extension GAnalyticsTests {
    enum TestScreen: String, LoggableScreen {
        case welcome = "WELCOME_SCREEN"
    }
    
    func testTrackScreen() {
        sut.trackScreen(TestScreen.welcome,
                        parameters: ["additional_parameter": "testing"])
        
        XCTAssertEqual(
            logger.events,
            [.init(name: "screen_view", parameters: [
                "screen_class": "WELCOME_SCREEN",
                "screen_name": "WELCOME_SCREEN",
                "additional_parameter": "testing"
            ])]
        )
    }
    
    func testTrackScreenV2() {
        struct TestScreenV2: LoggableScreenV2 {
            let name: String = "Welcome to GOV.UK One Login"
            let type: ScreenType = TestScreen.welcome
        }
        
        sut.trackScreen(TestScreenV2(),
                        parameters: ["additional_parameter": "testing"])
        
        XCTAssertEqual(
            logger.events,
            [.init(name: "screen_view", parameters: [
                "screen_class": "WELCOME_SCREEN",
                "screen_name": "Welcome to GOV.UK One Login",
                "additional_parameter": "testing"
            ])]
        )
    }
}
