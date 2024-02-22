@testable import Logging
import XCTest

class MockLoggingService: AnalyticsService {    
    var additionalParameters: [String: Any] = [:]
    
    var screensVisited: [String] = []
    var screenParamsLogged: [String: Any] = [:]
    var eventsLogged: [LoggableEvent] = []
    
    func logCrash(_ crash: NSError) { }
    func grantAnalyticsPermission() { }
    func denyAnalyticsPermission() { }
    
    func trackScreen(_ screen: LoggableScreen,
                     parameters: [String: Any]) {
        screensVisited.append(screen.name)
        screenParamsLogged = parameters
    }
    
    func trackScreen(_ screen: LoggableScreenV2,
                     parameters: [String : Any]) {
        
        screensVisited.append(screen.name)
        screenParamsLogged = parameters
    }
    
    func logEvent(_ event: LoggableEvent,
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
