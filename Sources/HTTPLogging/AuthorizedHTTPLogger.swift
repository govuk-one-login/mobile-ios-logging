import Foundation
import Logging
import Networking

/// AuthorizedHTTPLogger
///
/// A struct for sending HTTP requests to endpoints secured with scoped access tokens.
/// This logger can be used to log user/journey specific insights for app metrics and performance.
public struct AuthorizedHTTPLogger {
    /// `NetworkClient` from the Networking package dependency to handle HTTP networking
    let networkClient: NetworkClient
    /// `URL` address for sending HTTP requests
    let loggingURL: URL
    /// Scope for service access token
    let scope: String
    /// callback to handle possible errors resulting from `NetworkClient`'s `makeRequest` method
    let handleError: ((Error) -> Void)?

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
    public func logEvent(requestBody: any Encodable) {
        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            assertionFailure("Failed to decode object")
            return
        }

        Task {
            var request = URLRequest(url: loggingURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

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
}
