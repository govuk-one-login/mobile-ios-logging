import Foundation
import Networking

public protocol HTTPLoggingNetworkClient: Sendable {
    func request(_ request: URLRequest) -> RequestBuilder
}
