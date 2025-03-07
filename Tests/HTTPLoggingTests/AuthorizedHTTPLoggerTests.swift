@testable import HTTPLogging
import Logging
import MockNetworking
@testable import Networking
import XCTest

struct MockAuthorizedRequestBody: Codable {
    struct MockSubType: Codable {
        let specialInfo: String
        
        init(specialInfo: String = "special info") {
            self.specialInfo = specialInfo
        }
    }
    
    let name: String
    let timestamp: Int
    
    let subType: MockSubType
    

    init(
        name: String = "mock request name",
        timestamp: Int = 123456789012,
        subType: MockSubType = MockSubType()
    ) {
        self.name = name
        self.timestamp = timestamp
        self.subType = subType
    }
}

struct MockTokenHolder: AuthorizationProvider {
    func fetchToken(withScope scope: String) async throws -> String {
        "mockToken"
    }
}

final class AuthorizedHTTPLoggerTests: XCTestCase {
    private var sut: AuthorizedHTTPLogger!
    private var client: NetworkClient!
    private var configuration: URLSessionConfiguration!
    
    override func setUp() {
        super.setUp()
        configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let mockTokenHolder = MockTokenHolder()
        client = NetworkClient(configuration: configuration)
        client.authorizationProvider = mockTokenHolder
        
        sut = AuthorizedHTTPLogger(
            url: URL(string: "https://example.com/dev")!,
            networkClient: client,
            scope: "this.is.scoped"
        )
    }
    
    override func tearDown() {
        sut = nil
        client = nil
        MockURLProtocol.clear()
        configuration = nil
        super.tearDown()
    }
}

extension AuthorizedHTTPLoggerTests {
    func test_successfulTXMAEventLog() throws {
        // GIVEN network client returns 200
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 200))
        }

        // WHEN an event is logged
        let requestBody = MockAuthorizedRequestBody()
        let task = try sut.logEvent(requestBody: requestBody)
        
        wait(for: [
            XCTNSPredicateExpectation(
                predicate: .init(
                    block: { _, _ in
                        MockURLProtocol.requests.count == 1
                    }
                ),
                object: nil
            )
        ], timeout: 3)
        
        task.cancel()
        
        XCTAssertEqual(task.isCancelled, true)
        
        // THEN the request succeeds
        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "example.com")
        XCTAssertEqual(request.url?.path, "/dev")

        let httpData = try XCTUnwrap(request.httpBodyData())
        let decoder = JSONDecoder()
        let httpBody = try decoder.decode(MockAuthorizedRequestBody.self, from: httpData)

        XCTAssertEqual(httpBody.name, "mock request name")
        XCTAssertEqual(httpBody.timestamp, 123456789012)
        XCTAssertEqual(httpBody.subType.specialInfo, "special info")
    }
    
    func test_successfulTXMAEventLogAsync() async throws {
        // GIVEN network client returns 200
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 200))
        }
        
        // WHEN an event is logged
        let requestBody = MockAuthorizedRequestBody()
        await sut.logEvent(requestBody: requestBody)
        
        let exp = expectation(description: "awaiting request count")
        
        if MockURLProtocol.requests.count == 1 {
            exp.fulfill()
        }
        
        await fulfillment(of: [exp], timeout: 3)

        // THEN the request succeeds
        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "example.com")
        XCTAssertEqual(request.url?.path, "/dev")
        
        let httpData = try XCTUnwrap(request.httpBodyData())
        let decoder = JSONDecoder()
        let httpBody = try decoder.decode(MockAuthorizedRequestBody.self, from: httpData)
        
        XCTAssertEqual(httpBody.name, "mock request name")
        XCTAssertEqual(httpBody.timestamp, 123456789012)
        XCTAssertEqual(httpBody.subType.specialInfo, "special info")
    }
    
    func test_TXMAEventLog_throwsError() throws {
        var error: ServerError?
        
        sut = AuthorizedHTTPLogger(
            url: URL(string: "https://example.com/dev")!,
            networkClient: client,
            scope: "this.is.scoped",
            handleError: { receivedError in
                error = receivedError as? ServerError
            }
        )
        
        // GIVEN network client returns 401 error
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 401))
        }
        
        // WHEN a TXMA event is logged
        let requestBody = MockAuthorizedRequestBody()
        try sut.logEvent(requestBody: requestBody)
        wait(for: [
            XCTNSPredicateExpectation(predicate: .init(block: { _, _ in
                MockURLProtocol.requests.count == 1
            }), object: nil)
        ], timeout: 3)
        
        // THEN a 401 error is received in response
        XCTAssertEqual(error?.errorCode, 401)
    }
}
