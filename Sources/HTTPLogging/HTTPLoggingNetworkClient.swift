import Foundation

public protocol HTTPLoggingNetworkClient {
    func makeRequest(_ request: URLRequest) async throws -> Data
    
    func makeAuthorizedRequest(
        scope: String,
        request: URLRequest
    ) async throws -> Data
}
