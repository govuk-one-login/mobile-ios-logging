import Foundation

struct MockCustomNSError: CustomNSError {
    let kind: String
    
    var errorUserInfo: [String: Any] {
        [
            "kind": kind,
            "testString": "stringValue",
            "testInt": 123
        ]
    }
}
