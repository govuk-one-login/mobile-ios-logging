import Foundation
import Logging

struct MockScreen: Equatable {
    let name: String
    let `class`: String
}

final class MockLoggingService: AnalyticsService {
    var analyticsPreferenceStore: any Logging.AnalyticsPreferenceStore = UserDefaultsPreferenceStore()
    
    var additionalParameters: [String: Any] = [:]
    
    var screensVisited: [MockScreen] = []
    var screenParamsLogged: [String: Any] = [:]
    var eventsLogged: [LoggableEvent] = []
    
    func logCrash(_ crash: any Error) {}
    func logCrash(_ crash: NSError) { }
    func grantAnalyticsPermission() { }
    func denyAnalyticsPermission() { }
    
    func addingAdditionalParameters(
        _ additionalParameters: [String: Any]
    ) -> Self {
        self
    }
    
    func trackScreen(_ screen: any LoggableScreen, parameters: [String: Any]) {
        screensVisited.append(
            MockScreen(name: screen.name, class: screen.type.description)
        )
        screenParamsLogged = parameters
    }
    
    func logEvent(_ event: LoggableEvent,
                  parameters: [String: Any]) {
        eventsLogged.append(event)
    }
}
