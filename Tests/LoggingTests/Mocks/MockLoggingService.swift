import Foundation
import Logging

struct MockScreen: Equatable {
    let name: String
    let `class`: String
}

final class MockLoggingService: AnalyticsService {
    private let workQueue = DispatchQueue(label: "mock-logging-servic-queue")
    
    let analyticsPreferenceStore: any Logging.AnalyticsPreferenceStore = UserDefaultsPreferenceStore()
    
    nonisolated(unsafe) private var _additionalParameters: [String: Any] = [:]
    var additionalParameters: [String : Any] {
        get { workQueue.sync { _additionalParameters } }
        set { workQueue.sync { _additionalParameters = newValue } }
    }
    
    nonisolated(unsafe) private var _screensVisited: [MockScreen] = []
    var screensVisited: [MockScreen] { workQueue.sync { _screensVisited } }
    nonisolated(unsafe) private var _screenParamsLogged: [String: Any] = [:]
    var screenParamsLogged: [String: Any] { workQueue.sync { _screenParamsLogged } }
    nonisolated(unsafe) private var _eventsLogged: [LoggableEvent] = []
    var eventsLogged: [LoggableEvent] { workQueue.sync { _eventsLogged } }
    
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
        workQueue.sync {
            _screensVisited.append(
                MockScreen(name: screen.name, class: screen.type.description)
            )
            _screenParamsLogged = parameters
        }
    }
    
    func logEvent(_ event: LoggableEvent, parameters: [String: Any]) {
        workQueue.sync { _eventsLogged.append(event) }
    }
}
