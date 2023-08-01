@testable import Analytics
import XCTest

class MockAnalyticsService: AnalyticsService {
    var additionalParameters: [String: Any] = [:]
    
    var screensVisited: [String] = []
    var screenParamsLogged: [String: Any] = [:]
    var eventsLogged: [AnalyticsEvent] = []
    
    func logCrash(_ crash: NSError) { }
    func grantAnalyticsPermission() { }
    func denyAnalyticsPermission() { }
    
    func trackScreen(_ screen: Analytics.AnalyticsScreen,
                     parameters: [String: Any]) {
        screensVisited.append(screen.name)
        screenParamsLogged = parameters
    }
    
    func logEvent(_ event: Analytics.AnalyticsEvent,
                  parameters: [String: Any]) {
        eventsLogged.append(event)
    }
}

final class AnalyticsServiceTests: XCTestCase {
    func testAnalyticsService() {
        let service = MockAnalyticsService()
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
