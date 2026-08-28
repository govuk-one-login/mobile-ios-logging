import GDSAnalytics
import Testing

struct SystemEventTests {
    @Test
    func initialisation() {
        let event = SystemEvent(
            textKey: "Document Saved",
            screenName: "home_screen",
            systemEventType: "save"
        )
        
        #expect(event.name == .systemEvent)
        #expect(event.type == .systemEvent)
        #expect(event.text == "Document Saved")
        #expect(event.screenName == "home_screen")
        #expect(event.systemEventType == "save")
        #expect(event.isError == false)
        #expect(event.reason == nil)
    }
    
    @Test
    func initialisationWithAllParameters() {
        let event = SystemEvent(
            textKey: "Upload Failed",
            screenName: "upload_screen",
            systemEventType: "upload",
            reason: "network timeout",
            isError: true
        )
        
        #expect(event.text == "Upload Failed")
        #expect(event.screenName == "upload_screen")
        #expect(event.systemEventType == "upload")
        #expect(event.reason == "network timeout")
        #expect(event.isError == true)
    }
    
    @Test
    func parameters() {
        let event = SystemEvent(
            textKey: "Document Saved",
            screenName: "home_screen",
            systemEventType: "save"
        )
        
        #expect(event.parameters == [
            "screen_name": "home_screen",
            "type": "save",
            "text": "document saved",
            "is_error": "false"
        ])
    }
    
    @Test
    func parametersWithReason() {
        let event = SystemEvent(
            textKey: "Upload Failed",
            screenName: "upload_screen",
            systemEventType: "upload",
            reason: "Network Timeout",
            isError: true
        )
        
        #expect(event.parameters == [
            "screen_name": "upload_screen",
            "type": "upload",
            "text": "upload failed",
            "is_error": "true",
            "reason": "network timeout"
        ])
    }
    
    @Test
    func parametersWithoutReasonExcludesReasonKey() {
        let event = SystemEvent(
            textKey: "Document Saved",
            screenName: "home_screen",
            systemEventType: "save"
        )
        
        #expect(event.parameters["reason"] == nil)
    }
    
    @Test
    func parameterFormattingConvertsToLowercase() {
        let event = SystemEvent(
            textKey: "DOCUMENT SAVED",
            screenName: "Home_Screen",
            systemEventType: "Save",
            reason: "SOME REASON"
        )
        
        #expect(event.parameters["text"] == "document saved")
        #expect(event.parameters["screen_name"] == "home_screen")
        #expect(event.parameters["type"] == "save")
        #expect(event.parameters["reason"] == "some reason")
    }
    
    @Test
    func parameterFormattingTruncatesTo100Characters() {
        let longString = String(repeating: "a", count: 150)
        let event = SystemEvent(
            textKey: longString,
            screenName: "home_screen",
            systemEventType: "save"
        )
        
        #expect(event.parameters["text"]?.count == 100)
    }
}
