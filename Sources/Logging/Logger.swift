import Analytics
import Foundation
import Networking

public struct Logger: LoggingService {
    let networkClient: NetworkClient
    let loggingURL: URL
    let sessionID: String
    let handleError: ((Error) -> Void)?
    
    public func logEvent(_ event: LoggingEvent,
                         parameters: [String: Any]) {
        let logRequest = LogRequest(authSessionID: sessionID, event: event)
        guard let jsonData = try? JSONEncoder().encode(logRequest) else {
            assertionFailure("Failed to decode object")
            return
        }
        
        Task {
            var request = URLRequest(url: loggingURL)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            
            do {
                _ = try await networkClient.makeRequest(request)
            } catch {
                handleError?(error)
            }
        }
    }
    
    public init(sessionID: String,
                url: URL,
                networkClient: NetworkClient = NetworkClient(),
                handleError: ((Error) -> Void)? = nil) {
        loggingURL = url
        self.sessionID = sessionID
        self.networkClient = networkClient
        self.handleError = handleError
    }
}
