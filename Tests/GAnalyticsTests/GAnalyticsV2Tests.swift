@testable import GAnalytics
import Logging
import XCTest

final class GAnalyticsTests: XCTestCase {
    private var app: MockApp.Type!
    private var preferenceStore: MockPreferenceStore!
    private var analyticsLogger: MockAnalyticsLogger.Type!
    private var crashLogger: MockCrashLogger!
    private var sut: GAnalytics!
    
    override func setUp() {
        super.setUp()
        
        app = MockApp.self
        preferenceStore = MockPreferenceStore()
        analyticsLogger = MockAnalyticsLogger.self
        crashLogger = MockCrashLogger()
        
        sut = GAnalytics(
            analyticsPreferenceStore: preferenceStore,
            analyticsLogger: analyticsLogger,
            crashLogger: crashLogger
        )
        GAnalytics.analyticsApp = app
    }
    
    override func tearDown() {
        app.reset()
        preferenceStore = nil
        analyticsLogger.reset()
        crashLogger = nil
        sut = nil
        
        super.tearDown()
    }
}

// MARK: - Adding Additional Parameters tests
extension GAnalyticsTests {
    func testAddingAdditionalParameters() {
        let initialType = sut.addingAdditionalParameters([
            "taxonomy_level1": "one login mobile application"
        ])
        
        let idCheckManager = initialType.addingAdditionalParameters([
            "taxonomy_level2": "document checking application"
        ])
        
        XCTAssertEqual(sut.additionalParameters.count, 0)
        XCTAssertEqual(initialType.additionalParameters.count, 1)
        XCTAssertEqual(idCheckManager.additionalParameters.count, 2)
    }
    
    func testOverwritingAdditionalParametersIsNotPossible() {
        let initialType = sut.addingAdditionalParameters([
            "taxonomy_level1": "one login mobile application"
        ])
        
        let idCheckManager = initialType.addingAdditionalParameters([
            "taxonomy_level1": "document checking application"
        ])
        
        XCTAssertEqual(idCheckManager.additionalParameters.count, 1)
        XCTAssertEqual(
            idCheckManager.additionalParameters["taxonomy_level1"] as? String,
            "one login mobile application"
        )
    }
}

// MARK: - User consent tests
extension GAnalyticsTests {
    func testConfiguration() {
        GAnalytics.configure()
        
        XCTAssertTrue(app.calledConfigure)
    }
}

// MARK: - User Consent Tests
extension GAnalyticsTests {
    func testNoTrackingWhenNoConsent() {
        preferenceStore.hasAcceptedAnalytics = nil
        
        sut.activate()
        
        XCTAssertEqual(analyticsLogger.isAnalyticsCollectionEnabled, false)
        XCTAssertEqual(crashLogger.isCollectionEnabled, true)
    }
    
    func testNoTrackingWhenConsentDenied() {
        preferenceStore.hasAcceptedAnalytics = false
        
        sut.activate()
        
        XCTAssertEqual(analyticsLogger.isAnalyticsCollectionEnabled, false)
        XCTAssertEqual(crashLogger.isCollectionEnabled, true)
    }
    
    func testTrackingEnabledWhenUserConsented() {
        preferenceStore.hasAcceptedAnalytics = true
        
        sut.activate()
        
        XCTAssertEqual(analyticsLogger.isAnalyticsCollectionEnabled, true)
        XCTAssertEqual(crashLogger.isCollectionEnabled, true)
    }
    
    func testSubscribesToPreferenceStore() {
        sut.activate()
        
        waitForSubscription()
    }
    
    func testStartsTrackingAnalyticsWhenConsentGiven() async throws {
        preferenceStore.hasAcceptedAnalytics = false
        
        sut.activate()
        waitForSubscription()
        
        // alert the AnalyticsService that consent is given:
        let continuation = try XCTUnwrap(preferenceStore.subscribers.first)
        continuation.yield(true)
        
        try await Task.sleep(seconds: 1)
        
        XCTAssertEqual(analyticsLogger.isAnalyticsCollectionEnabled, true)
        XCTAssertEqual(crashLogger.isCollectionEnabled, true)
    }
    
    func testStopsTrackingAnalyticsWhenConsentWithdrawn() async throws {
        preferenceStore.hasAcceptedAnalytics = true
        
        sut.activate()
        waitForSubscription()
        
        // alert the AnalyticsService that consent is withdrawn
        let continuation = try XCTUnwrap(preferenceStore.subscribers.first)
        continuation.yield(false)
        
        try await Task.sleep(seconds: 1)
        
        XCTAssertTrue(analyticsLogger.didResetAnalyticsData)
        XCTAssertEqual(analyticsLogger.isAnalyticsCollectionEnabled, false)
        XCTAssertEqual(crashLogger.isCollectionEnabled, true)
    }
    
    private func waitForSubscription() {
        let exp = expectation(for: .init { _, _ in
            self.preferenceStore.subscribers.count == 1
        }, evaluatedWith: nil)
        
        wait(for: [exp], timeout: 3)
    }
}

// MARK: - Logging Tests
extension GAnalyticsTests {
    enum TestScreenType: String, ScreenType, CustomStringConvertible {
        case welcome = "WELCOME_SCREEN"
        
        var name: String { rawValue }
        var description: String { rawValue }
    }
    
    func testTrackScreenAdditionalParameters() {
        struct TestScreen: LoggableScreen {
            let name: String = "Welcome to GOV.UK One Login"
            let type: TestScreenType = .welcome
        }
        
        sut.additionalParameters = [
            "journey": "id_verification"
        ]
        
        sut.trackScreen(TestScreen(),
                        parameters: ["additional_parameter": "testing"])
        
        XCTAssertEqual(
            analyticsLogger.events,
            [.init(name: "screen_view", parameters: [
                "screen_name": "Welcome to GOV.UK One Login",
                "screen_class": "WELCOME_SCREEN",
                "additional_parameter": "testing",
                "journey": "id_verification"
            ])]
        )
    }
    
    func testTrackScreenAdditionalParametersPrecedence() {
        struct TestScreen: LoggableScreen {
            let name: String = "Welcome to GOV.UK One Login"
            let type: TestScreenType = .welcome
        }
        
        sut.additionalParameters = [
            "journey": "id_verification"
        ]
        
        sut.trackScreen(
            TestScreen(),
            parameters: [
                "additional_parameter": "testing",
                "journey": "something_else"
            ]
        )
        
        XCTAssertEqual(
            analyticsLogger.events,
            [
                .init(
                    name: "screen_view",
                    parameters: [
                        "screen_name": "Welcome to GOV.UK One Login",
                        "screen_class": "WELCOME_SCREEN",
                        "additional_parameter": "testing",
                        "journey": "id_verification"
                    ]
                )
            ]
        )
    }
    
    func testTrackScreen() {
        struct TestScreen: LoggableScreen {
            let name: String = "Welcome to GOV.UK One Login"
            let type: TestScreenType = .welcome
        }
        
        sut.trackScreen(TestScreen(),
                        parameters: ["additional_parameter": "testing"])
        
        XCTAssertEqual(
            analyticsLogger.events,
            [.init(name: "screen_view", parameters: [
                "screen_name": "Welcome to GOV.UK One Login",
                "screen_class": "WELCOME_SCREEN",
                "additional_parameter": "testing"
            ])]
        )
    }
    
    func testTrackEvent() {
        enum MyAppEvents: String, LoggableEvent {
            case buttonPress
        }
        
        sut.logEvent(MyAppEvents.buttonPress)
        
        XCTAssertEqual(
            analyticsLogger.events,
            [.init(name: "buttonPress", parameters: [:])]
        )
    }
    
    func testLogCrash() {
        enum MyAppError: Error, Equatable {
            case unknownFailure
        }
        
        sut.logCrash(MyAppError.unknownFailure)
        
        XCTAssertEqual(crashLogger.errors.count, 1)
        XCTAssertEqual(
            crashLogger.errors.compactMap { $0 as? MyAppError },
            [MyAppError.unknownFailure]
        )
    }
    
    func testLogCrashCustomNSError() {
        let error = MockCustomNSError(kind: "testError1")
        
        sut.additionalParameters = ["additionalParameter": "param"]
        sut.logCrash(error)
        
        XCTAssertEqual(crashLogger.errors.count, 1)
        XCTAssertEqual(crashLogger.loggedParams?["kind"] as? String, "testError1")
        XCTAssertEqual(crashLogger.loggedParams?["testString"] as? String, "stringValue")
        XCTAssertEqual(crashLogger.loggedParams?["testInt"] as? Int, 123)
        
        XCTAssertEqual(crashLogger.loggedParams?["additionalParameter"] as? String, "param")
    }
    
    func testLogCrashCustomNSErrorNotOverwritingParam() {
        let error = MockCustomNSError(kind: "testError1")
        
        sut.additionalParameters = ["testString": "CorrectStringValue"]
        sut.logCrash(error)
        
        XCTAssertEqual(crashLogger.errors.count, 1)
        XCTAssertEqual(crashLogger.loggedParams?["kind"] as? String, "testError1")
        XCTAssertEqual(crashLogger.loggedParams?["testString"] as? String, "CorrectStringValue")
        XCTAssertEqual(crashLogger.loggedParams?["testInt"] as? Int, 123)
        
        XCTAssertNotEqual(crashLogger.loggedParams?["testString"] as? String, "stringValue")
    }
    
    func testGrantAnalyticsPermission() {
        sut.grantAnalyticsPermission()
        
        XCTAssertEqual(analyticsLogger.isAnalyticsCollectionEnabled, true)
        XCTAssertEqual(crashLogger.isCollectionEnabled, true)
    }
    
    func testDenyAnalyticsPermission() {
        sut.denyAnalyticsPermission()
        
        XCTAssertTrue(analyticsLogger.didResetAnalyticsData)
        
        XCTAssertEqual(analyticsLogger.isAnalyticsCollectionEnabled, false)
        XCTAssertEqual(crashLogger.isCollectionEnabled, true)
    }
}
