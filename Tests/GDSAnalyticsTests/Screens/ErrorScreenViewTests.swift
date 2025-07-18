import GDSAnalytics
import XCTest

final class ErrorScreenViewTests: XCTestCase {
    func testInitialisation() {
        let view = ErrorScreenView(screen: MockScreen.error,
                                   titleKey: "Something went wrong")
        
        XCTAssertEqual(view.screen, MockScreen.error)
        XCTAssertEqual(view.title, "something went wrong")
    }
    
    func testEmptyParametersAreRemoved() {
        let uuid = UUID().uuidString.lowercased()
        
        let view = ErrorScreenView(id: uuid,
                                   screen: MockScreen.error,
                                   titleKey: "Something went wrong")
        
        XCTAssertEqual(
            view.parameters,
            [
                "screen_id": uuid,
                "is_error": "true",
                "saved_doc_type": "undefined"
            ]
        )
    }
    
    struct MockError: LoggableError {
        let reason: String? = "server"
        let endpoint: String? = "fetchBiometricToken"
        let hash: String? = "83766358f64858b51afb745bbdde91bb"
        let statusCode: String? = "429"
    }
    
    func testParametersForError() {
        let uuid = UUID().uuidString.lowercased()
        let view = ErrorScreenView(
            id: uuid,
            screen: MockScreen.error,
            titleKey: "Something went wrong",
            error: MockError()
        )
        
        XCTAssertEqual(view.title, "something went wrong")
        XCTAssertEqual(
            view.parameters,
            [
                "screen_id": uuid,
                "hash": "83766358f64858b51afb745bbdde91bb",
                "reason": "server",
                "endpoint": "fetchbiometrictoken",
                "status": "429",
                "is_error": "true",
                "saved_doc_type": "undefined"
            ]
        )
    }
    
    func testParametersForValues() {
        let uuid = UUID().uuidString.lowercased()
        
        let view = ErrorScreenView(
            id: uuid,
            screen: MockScreen.error,
            titleKey: "Something went wrong",
            reason: "network",
            endpoint: "appInfo",
            statusCode: "401",
            hash: "83766358f64858b51afb745bbdde91bb"
        )
        
        XCTAssertEqual(
            view.parameters,
            [
                "screen_id": uuid,
                "reason": "network",
                "endpoint": "appinfo",
                "status": "401",
                "hash": "83766358f64858b51afb745bbdde91bb",
                "is_error": "true",
                "saved_doc_type": "undefined"
            ]
        )
    }
    
    func testEquatableTrue() {
        let uuid = UUID().uuidString.lowercased()
        
        let view1 = ErrorScreenView(
            id: uuid,
            screen: MockScreen.error,
            titleKey: "Something went wrong",
            reason: "network",
            endpoint: "appInfo",
            statusCode: "401",
            hash: "83766358f64858b51afb745bbdde91bb"
        )
        
        let view2 = ErrorScreenView(
            id: uuid,
            screen: MockScreen.error,
            titleKey: "Something went wrong",
            reason: "network",
            endpoint: "appInfo",
            statusCode: "401",
            hash: "83766358f64858b51afb745bbdde91bb"
        )
        
        XCTAssertEqual(view1, view2)
    }
    
    func testEquatableFalse() {
        let uuid = UUID().uuidString.lowercased()
        
        let view1 = ErrorScreenView(
            id: uuid,
            screen: MockScreen.error,
            titleKey: "Something went wrong",
            reason: "network",
            endpoint: "appInfo",
            statusCode: "401",
            hash: "83766358f64858b51afb745bbdde91bb"
        )
        
        let view2 = ErrorScreenView(
            id: uuid,
            screen: MockScreen.error,
            titleKey: "Went wrong",
            reason: "network",
            endpoint: "appInfo",
            statusCode: "401",
            hash: "83766358f64858b51afb745bbdde91bb"
        )
        
        XCTAssertNotEqual(view1, view2)
    }
}
