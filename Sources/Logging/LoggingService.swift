import Foundation

protocol LoggingService {
    func logEvent(_ event: LoggingEvent, parameters: [String: Any])
}

extension LoggingService {
    /// Protocol method for logging an analytics event, calling the conforming type's method for adding event logging parameters.
    public func logEvent(_ event: LoggingEvent) {
        logEvent(event, parameters: [:])
    }
}
