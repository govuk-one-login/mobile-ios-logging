@testable import Logging
import XCTest

final class LoggingServiceTests: XCTestCase {
    enum TestScreen: String, ScreenType, CustomStringConvertible {
        case welcome = "WELCOME_SCREEN"
        
        var name: String { rawValue }
        var description: String { rawValue }
    }
    
    struct TestScreenV2: LoggableScreenV2 {
        let name: String = "Welcome to GOV.UK One Login"
        let type: TestScreen = .welcome
    }
    
    func testAnalyticsService() {
        let service = MockLoggingService()
        service.logEvent(MockAnalyticsEvent.completedIDCheck, parameters: [:])
        XCTAssertEqual(service.eventsLogged.count, 1)

        service.trackScreen(TestScreenV2(), parameters: [:])
        XCTAssertEqual(service.screensVisited.count, 1)
        
        service.logEvent(MockAnalyticsEvent.completedIDCheck)
        XCTAssertEqual(service.eventsLogged.count, 2)
        
        service.trackScreen(TestScreenV2(), parameters: [:])
        XCTAssertEqual(service.screensVisited.count, 2)
    }
    
    func testTrackScreenV2() {
        let service = MockLoggingService()
        service.trackScreen(TestScreenV2(), parameters: [:])
        
        XCTAssertEqual(
            service.screensVisited,
            [
                MockScreen(name: "Welcome to GOV.UK One Login", class: "WELCOME_SCREEN")
            ]
        )
    }
}
