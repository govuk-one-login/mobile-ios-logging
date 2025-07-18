import GDSAnalytics
import XCTest

final class ScreenViewTests: XCTestCase {
    func testInitialisation() {
        let view = ScreenView(screen: MockScreen.welcome,
                              titleKey: "Welcome to this app")
        
        XCTAssertEqual(view.screen, MockScreen.welcome)
        XCTAssertEqual(view.title, "welcome to this app")
    }
    
    func testParameters() {
        let uuid = UUID().uuidString.lowercased()

        let view = ScreenView(id: uuid,
                              screen: MockScreen.welcome,
                              titleKey: "welcome to this app")
        
        XCTAssertEqual(
            view.parameters, [
                "screen_id": uuid,
                "is_error": "false",
                "saved_doc_type": "undefined"
            ]
        )
    }
    
    
    func testParameterTruncation() {
        let view = ScreenView(
            screen: MockScreen.welcome,
            titleKey: "Welcome to this app with a really really really really really really really really really really long name"
        )

        XCTAssertEqual(view.title, "welcome to this app with a really really really really really really really really really really lon")
        
        XCTAssertEqual(
            view.parameters,
            [
                "is_error": "false",
                "saved_doc_type": "undefined"
            ]
        )
    }
    
    func testEquatableTrue() {
        let view1 = ScreenView(
            screen: MockScreen.welcome,
            titleKey: "Welcome to this app with a really really really really really really really really really really long name"
        )
        
        let view2 = ScreenView(
            screen: MockScreen.welcome,
            titleKey: "Welcome to this app with a really really really really really really really really really really long name"
        )
        
        XCTAssertEqual(view1, view2)
    }
    
    func testEquatableArray() {
        let view1 = ScreenView(
            screen: MockScreen.welcome,
            titleKey: "Welcome to this app with a really really really really really really really really really really long name"
        )
        
        let view2 = ScreenView(
            screen: MockScreen.welcome,
            titleKey: "Welcome to this app with a really really really really really really really really really really long name"
        )
        
        XCTAssertEqual([view1], [view2])
    }
    
    func testEquatableFalse() {
        let view1 = ScreenView(
            screen: MockScreen.welcome,
            titleKey: "Welcome to this app with a really really really really really really really really really really long name"
        )
        
        let view2 = ScreenView(
            screen: MockScreen.error,
            titleKey: "Welcome to this app with a really really really really really really really really really really long name"
        )
        
        XCTAssertNotEqual(view1, view2)
    }
    
    func testEquatableArrayFalse() {
        let view1 = ScreenView(
            screen: MockScreen.welcome,
            titleKey: "Welcome to this app with a really really really really really really really really really really long name"
        )
        
        let view2 = ScreenView(
            screen: MockScreen.error,
            titleKey: "Welcome to this app with a really really really really really really really really really really long name"
        )
        
        XCTAssertNotEqual([view1], [view2])
    }
}
