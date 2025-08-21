import GDSAnalytics
import XCTest

final class FormCTAEventTests: XCTestCase {
    func testInitialisation() {
        let event = FormCTAEvent(textKey: "Continue", responseKey: "Yes")
        
        XCTAssertEqual(event.name, .formResponse)
        XCTAssertEqual(event.type, .callToAction)
        XCTAssertEqual(event.text, "Continue")
        XCTAssertEqual(event.response, "Yes")
    }
    
    func testParameters() {
        let event = FormCTAEvent(textKey: "Continue", responseKey: "Yes")
        
        XCTAssertEqual(event.parameters, [
            "text": "continue",
            "type": "call to action",
            "response": "yes"
        ])
    }
}
