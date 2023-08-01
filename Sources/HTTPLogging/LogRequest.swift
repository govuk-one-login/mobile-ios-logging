import Logging
import Foundation

/// LogRequest
///
/// A struct to model HTTP event logging data
struct LogRequest: Encodable {
    /// sessionID for user/journey identication
    let sessionID: String
    /// event name taken from `LoggingEvent` protocol extension property, `name`
    let eventName: String
    /// Initialiser for properties `sessionID` and `eventName`
    init(authSessionID: String, event: LoggingEvent) {
        self.sessionID = authSessionID
        self.eventName = event.name
    }
    
    /// Creating CodingKeys for inconsistent property `sessionID`
    enum CodingKeys: String, CodingKey {
        case sessionID = "sessionId"
        case eventName
    }
}
