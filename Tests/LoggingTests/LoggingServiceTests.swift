@testable import Logging
import XCTest

class MockLoggingService: AnalyticsService {
    var additionalParameters: [String: Any] = [:]
    
    var screensVisited: [String] = []
    var screenParamsLogged: [String: Any] = [:]
    var eventsLogged: [LoggingEvent] = []
    
    func logCrash(_ crash: NSError) { }
    func grantAnalyticsPermission() { }
    func denyAnalyticsPermission() { }
    
    func trackScreen(_ screen: Logging.LoggingScreen,
                     parameters: [String: Any]) {
        screensVisited.append(screen.name)
        screenParamsLogged = parameters
    }
    
    func logEvent(_ event: Logging.LoggingEvent,
                  parameters: [String: Any]) {
        eventsLogged.append(event)
    }
}

final class LoggingServiceTests: XCTestCase {
    func testAnalyticsService() {
        let service = MockLoggingService()
        service.logEvent(MockAnalyticsEvent.completedIDCheck, parameters: [:])
        XCTAssertEqual(service.eventsLogged.count, 1)
        
        service.trackScreen(MockAnalyticsScreen.drivingLicenceFrontInstructions)
        XCTAssertEqual(service.screensVisited.count, 1)
        
        service.logEvent(MockAnalyticsEvent.completedIDCheck)
        XCTAssertEqual(service.eventsLogged.count, 2)
        
        service.trackScreen(MockAnalyticsScreen.drivingLicenceFrontInstructions)
        XCTAssertEqual(service.screensVisited.count, 2)
    }
}
