import Foundation
import Networking

public protocol HTTPLoggingNetworkClient {
    func request(_ request: URLRequest) -> RequestBuilder
    func makeRequest(_ request: NetworkRequest) async throws -> Data
    
    // TODO: DCMAW-20368 Remove these
    @available(*, deprecated, message: "use .request().execute() instead")
    func makeRequest(_ request: URLRequest) async throws -> Data
    
    @available(*, deprecated, message: "use .request().withAuthentication().execute() instead")
    func makeAuthorizedRequest(
        scope: String,
        request: URLRequest
    ) async throws -> Data
}
