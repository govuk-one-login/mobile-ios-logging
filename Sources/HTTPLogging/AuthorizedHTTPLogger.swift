import Foundation
import Networking

/// AuthorizedHTTPLogger
///
/// A struct for sending HTTP requests to endpoints secured with scoped access tokens.
/// This logger can be used to log user/journey specific insights for app metrics and performance.
public struct AuthorizedHTTPLogger {
    /// `URL` address for sending HTTP requests
    let loggingURL: URL
    /// `NetworkClient` from the Networking package dependency to handle HTTP networking
    let networkClient: NetworkClient
    /// Scope for service access token
    let scope: String
    /// callback to handle possible errors resulting from `NetworkClient`'s `makeRequest` method
    let handleError: ((Error) -> Void)?
    /// Task stored to enable cancellation with the `cancelTask` method
    var task: Task<Void, Never>?

    /// Initialiser for class with default methods for `networkClient` and `handleError` parameters
    public init(
        url: URL,
        networkClient: NetworkClient,
        scope: String,
        handleError: ((Error) -> Void)? = nil
    ) {
        loggingURL = url
        self.scope = scope
        self.networkClient = networkClient
        self.handleError = handleError
    }

    /// Sends HTTP POST request to designated URL, handling errors received back from `NetworkClient`'s `makeAuthorizedRequest` method
    /// - Parameters:
    ///     - event: the encodable object to be logged in the request body as JSON
    public mutating func logEvent(requestBody: any Encodable) {
        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            assertionFailure("Failed to encode object")
            return
        }

        task = Task { [self] in
            await createAndMakeRequest(data: jsonData)
        }
    }
    
    /// Method to cancel task created by non-async `logEvent` method
    public mutating func cancelTask() {
        task?.cancel()
    }
    
    public func logEvent(requestBody: any Encodable) async {
        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            assertionFailure("Failed to encode object")
            return
        }
        
        await createAndMakeRequest(data: jsonData)
    }
    
    private func createAndMakeRequest(data: Data) async {
        var request = URLRequest(url: loggingURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        do {
            _ = try await networkClient.makeAuthorizedRequest(
                scope: scope,
                request: request
            )
        } catch {
            handleError?(error)
        }
    }
}
