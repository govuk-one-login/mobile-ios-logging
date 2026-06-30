import Foundation
import Networking

public protocol HTTPLoggingNetworkClient {
    func request(_ request: URLRequest) -> RequestBuilder
}
