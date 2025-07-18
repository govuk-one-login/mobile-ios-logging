@testable import GAnalytics
import Logging
import XCTest

final class GAnalyticsTests: XCTestCase {
    private var sut: GAnalytics!
    
    private var app: MockApp.Type!
    private var analyticsLogger: MockAnalyticsLogger.Type!
    private var crashLogger: MockCrashLogger!
    private var preferenceStore: MockPreferenceStore!
    
    override func setUp() {
        super.setUp()
        
        app = MockApp.self
        analyticsLogger = MockAnalyticsLogger.self
        crashLogger = MockCrashLogger()
        preferenceStore = MockPreferenceStore()
        
        sut = GAnalytics(app: app,
                         analytics: analyticsLogger,
                         crashLogger: crashLogger,
                         preferenceStore: preferenceStore)
    }
    
    override func tearDown() {
        sut = nil
        analyticsLogger.reset()
        analyticsLogger = nil
        crashLogger = nil
        preferenceStore = nil
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
        sut.configure()
        
        XCTAssertTrue(app.calledConfigure)
        NotificationCenter.default.post(Notification(name: UserDefaults.didChangeNotification))
    }
}

// MARK: - User Consent Tests
extension GAnalyticsTests {
    func testNoTrackingWhenNoConsent() {
        preferenceStore.hasAcceptedAnalytics = nil
        
        sut.configure()
        
        XCTAssertEqual(analyticsLogger.isAnalyticsCollectionEnabled, false)
        XCTAssertEqual(crashLogger.isCollectionEnabled, false)
    }
    
    func testNoTrackingWhenConsentDenied() {
        preferenceStore.hasAcceptedAnalytics = false
        
        sut.configure()
        
        XCTAssertEqual(analyticsLogger.isAnalyticsCollectionEnabled, false)
        XCTAssertEqual(crashLogger.isCollectionEnabled, false)
    }
    
    func testTrackingEnabledWhenUserConsented() {
        preferenceStore.hasAcceptedAnalytics = true
        
        sut.configure()
        
        XCTAssertEqual(analyticsLogger.isAnalyticsCollectionEnabled, true)
        XCTAssertEqual(crashLogger.isCollectionEnabled, true)
    }
    
    func testSubscribesToPreferenceStore() {
        sut.configure()
        
        waitForSubscription()
    }
    
    func testStartsTrackingAnalyticsWhenConsentGiven() async throws {
        preferenceStore.hasAcceptedAnalytics = false
        
        sut.configure()
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
        
        sut.configure()
        waitForSubscription()
        
        // alert the AnalyticsService that consent is withdrawn
        let continuation = try XCTUnwrap(preferenceStore.subscribers.first)
        continuation.yield(false)
        
        try await Task.sleep(seconds: 1)
        
        XCTAssertTrue(analyticsLogger.didResetAnalyticsData)
        XCTAssertEqual(analyticsLogger.isAnalyticsCollectionEnabled, false)
        XCTAssertEqual(crashLogger.isCollectionEnabled, false)
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
    enum TestScreen: String, LoggableScreen, CustomStringConvertible {
        case welcome = "WELCOME_SCREEN"
        
        var name: String { rawValue }
        var description: String { rawValue }
    }
    
    func testTrackScreen() {
        sut.trackScreen(TestScreen.welcome,
                        parameters: ["additional_parameter": "testing"])
        
        XCTAssertEqual(
            analyticsLogger.events,
            [.init(name: "screen_view", parameters: [
                "screen_name": "WELCOME_SCREEN",
                "screen_class": "WELCOME_SCREEN",
                "additional_parameter": "testing"
            ])]
        )
    }
    
    func testTrackScreenAdditionalParameters() {
        sut.additionalParameters = [
            "journey": "id_verification"
        ]
        
        sut.trackScreen(TestScreen.welcome,
                        parameters: ["additional_parameter": "testing"])
        
        XCTAssertEqual(
            analyticsLogger.events,
            [.init(name: "screen_view", parameters: [
                "screen_name": "WELCOME_SCREEN",
                "screen_class": "WELCOME_SCREEN",
                "additional_parameter": "testing",
                "journey": "id_verification"
            ])]
        )
    }
    
    func testTrackScreenAdditionalParametersPrecedence() {
        sut.additionalParameters = [
            "journey": "id_verification"
        ]
        
        sut.trackScreen(
            TestScreen.welcome,
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
                        "screen_name": "WELCOME_SCREEN",
                        "screen_class": "WELCOME_SCREEN",
                        "additional_parameter": "testing",
                        "journey": "id_verification"
                    ]
                )
            ]
        )
    }
    
    func testTrackScreenV2() {
        struct TestScreenV2: LoggableScreenV2 {
            let name: String = "Welcome to GOV.UK One Login"
            let type: TestScreen = .welcome
        }
        
        sut.trackScreen(TestScreenV2(),
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
    
    func testGrantAnalyticsPermission() {
        sut.grantAnalyticsPermission()
        
        XCTAssertEqual(analyticsLogger.isAnalyticsCollectionEnabled, true)
        XCTAssertEqual(crashLogger.isCollectionEnabled, true)
    }
    
    func testDenyAnalyticsPermission() {
        sut.denyAnalyticsPermission()
        
        XCTAssertTrue(analyticsLogger.didResetAnalyticsData)
        
        XCTAssertEqual(analyticsLogger.isAnalyticsCollectionEnabled, false)
        XCTAssertEqual(crashLogger.isCollectionEnabled, false)
    }
}
