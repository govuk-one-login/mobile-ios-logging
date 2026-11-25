@testable import HTTPLogging
import Logging
import MockNetworking
@testable import Networking
import XCTest

enum MockEvent: String, LoggableEvent {
    case testEvent
}

final class HTTPLoggingTests: XCTestCase {
    private var sessionID: String!
    private var sut: HTTPLogger!
    private var mockRequest: String!
    private var client: NetworkClient!
    private var configuration: URLSessionConfiguration!
    
    override func setUp() async throws {
        try await super.setUp()
        var testConfiguration = URLSessionConfiguration.ephemeral
        testConfiguration = URLSessionConfiguration.ephemeral
        testConfiguration.protocolClasses = [MockURLProtocol.self]
        configuration = testConfiguration
        client = await MainActor.run { NetworkClient(configuration: testConfiguration) }
        
        sessionID = UUID().uuidString
        
        sut = .init(sessionID: sessionID,
                    url: URL(string: "https://example.com/dev")!,
                    networkClient: client)
        
        mockRequest =
        """
         {
          "sessionId": "\(sessionID!)",
          "eventName": "\(MockEvent.testEvent.rawValue)"
         }
        """
    }
    
    override func tearDown() async throws {
        sessionID = nil
        sut = nil
        mockRequest = nil
        client = nil
        await MainActor.run { MockURLProtocol.clear() }
        configuration = nil
        
        try await super.tearDown()
    }
}

extension HTTPLoggingTests {
    func test_successfulTXMAEventLog() async throws {
        // GIVEN network client returns 200
        await MainActor.run {
            MockURLProtocol.handler = { (Data(), HTTPURLResponse(statusCode: 200)) }
        }
        
        // WHEN an event is logged
        sut.logEvent(MockEvent.testEvent)
        
        await fulfillment(of: [
            XCTNSPredicateExpectation(predicate: .init(block: { _, _ in
                MockURLProtocol.requests.count == 1
            }), object: nil)
        ], timeout: 3)
        
        // THEN the request succeeds
        let requests = await MainActor.run { MockURLProtocol.requests }
        let request = try XCTUnwrap(requests.first)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "example.com")
        XCTAssertEqual(request.url?.path, "/dev")

        let httpData = try XCTUnwrap(request.httpBodyData())
        let decoder = JSONDecoder()
        let httpBody = try decoder.decode([String: String].self, from: httpData)

        let ID = try XCTUnwrap(httpBody["sessionId"])
        XCTAssertEqual(sessionID, ID)
        
        let eventName = try XCTUnwrap(httpBody["eventName"])
        XCTAssertEqual(MockEvent.testEvent.rawValue, eventName)
    }
    
    func test_TXMAEventLog_throwsError() async throws {
        // GIVEN network client returns 401 error
        await MainActor.run {
            MockURLProtocol.handler = { (Data(), HTTPURLResponse(statusCode: 401)) }
        }
        
        // WHEN a TXMA event is logged
        sut.logEvent(MockEvent.testEvent)
        await fulfillment(of: [
            XCTNSPredicateExpectation(predicate: .init(block: { _, _ in
                MockURLProtocol.requests.count == 1
            }), object: nil)
        ], timeout: 3)
        // XCTAssertEqual(error.errorCode, 401)
        
        let requests = await MainActor.run { MockURLProtocol.requests }
        let request = try XCTUnwrap(requests.first)
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "example.com")
        XCTAssertEqual(request.url?.path, "/dev")

        let httpData = try XCTUnwrap(request.httpBodyData())
        let decoder = JSONDecoder()
        let httpBody = try decoder.decode([String: String].self, from: httpData)

        let ID = try XCTUnwrap(httpBody["sessionId"])
        XCTAssertEqual(sessionID, ID)
        
        let eventName = try XCTUnwrap(httpBody["eventName"])
        XCTAssertEqual(MockEvent.testEvent.rawValue, eventName)
    }
}


private struct HTTPLogRequest: Codable {
    let sessionID: String
    let eventName: String
    
    init(authSessionID: String, event: LoggableEvent) {
        self.sessionID = authSessionID
        self.eventName = event.name
    }
    
    enum CodingKeys: String, CodingKey {
        case sessionID = "sessionId"
        case eventName
    }
}
