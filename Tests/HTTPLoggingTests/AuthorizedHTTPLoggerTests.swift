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
    private var error: ServerError?
    
    override func setUp() async throws  {
        try await super.setUp()
        
        let testConfiguration = URLSessionConfiguration.ephemeral
        configuration = testConfiguration
        configuration.protocolClasses = [MockURLProtocol.self]
        let mockTokenHolder = MockTokenHolder()
        var networkClient = await MainActor.run { NetworkClient(configuration: testConfiguration) }
        networkClient.authorizationProvider = mockTokenHolder
        
        sut = AuthorizedHTTPLogger(
            url: URL(string: "https://example.com/dev")!,
            networkClient: networkClient,
            scope: "this.is.scoped"
        )
        client = networkClient
    }
    
    override func tearDown() async throws {
        sut = nil
        client = nil
        await MainActor.run { MockURLProtocol.clear() }
        configuration = nil
        try await super.tearDown()
    }
}

extension AuthorizedHTTPLoggerTests {
    func test_successfulTXMAEventLog() async throws {
        // GIVEN network client returns 200
        await MainActor.run {
            MockURLProtocol.handler = { (Data(), HTTPURLResponse(statusCode: 200)) }
        }

        // WHEN an event is logged
        let requestBody = MockAuthorizedRequestBody()
        await sut.logEvent(requestBody: requestBody)
        
        // THEN the request succeeds
        let requests = await MainActor.run { MockURLProtocol.requests }
        let request = try XCTUnwrap(requests.first)
        XCTAssertEqual(requests.count, 1)
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
        await MainActor.run {
            MockURLProtocol.handler = { (Data(), HTTPURLResponse(statusCode: 200)) }
        }
        
        // WHEN an event is logged
        let requestBody = MockAuthorizedRequestBody()
        await sut.logEvent(requestBody: requestBody)

        // THEN the request succeeds
        let requests = await MainActor.run { MockURLProtocol.requests }
        let request = try XCTUnwrap(requests.first)
        XCTAssertEqual(requests.count, 1)
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
    
    func test_TXMAEventLog_throwsError() async throws {
        let errorExpectation = XCTestExpectation(description: "error closure called")
        
        sut = AuthorizedHTTPLogger(
            url: URL(string: "https://example.com/dev")!,
            networkClient: client,
            scope: "this.is.scoped",
            handleError: { receivedError in
                if
                    let serverError = receivedError as? ServerError,
                    serverError.errorCode == 401
                {
                    errorExpectation.fulfill()
                }
            }
        )
        
        // GIVEN network client returns 401 error
        await MainActor.run {
            MockURLProtocol.handler = { (Data(), HTTPURLResponse(statusCode: 401)) }
        }
        
        // WHEN a TXMA event is logged
        let requestBody = MockAuthorizedRequestBody()
        await sut.logEvent(requestBody: requestBody)
        
        await fulfillment(of: [errorExpectation], timeout: 3)

        let requests = await MainActor.run { MockURLProtocol.requests }
        XCTAssertEqual(requests.count, 1)
    }
}
