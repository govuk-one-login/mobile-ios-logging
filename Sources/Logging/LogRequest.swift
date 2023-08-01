import Foundation

struct LogRequest: Encodable {
    let sessionID: String
    let eventName: String
    
    init(authSessionID: String, event: LoggingEvent) {
        self.sessionID = authSessionID
        self.eventName = event.name
    }
    
    enum CodingKeys: String, CodingKey {
        case sessionID = "sessionId"
        case eventName
    }
}
