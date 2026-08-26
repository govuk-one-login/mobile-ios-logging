import Foundation
import FirebaseAnalytics

public struct SystemEvent: Event {
    public let name = EventName.systemEvent
    public let type = EventType.systemEvent
    public let systemEventType: String
    public let reason: String?
    public let isError: Bool
    public let firebaseScreen: String
    
    public let text: String
    
    public var parameters: [String: String] {
        var parameters: [String: String] = [
            AnalyticsParameterScreenName: firebaseScreen,
            EventParameter.type.rawValue: systemEventType,
            EventParameter.text.rawValue: text,
            EventParameter.isError.rawValue : isError ? "true" : "false"
        ]
        
        if let reason {
            parameters[EventParameter.reason.rawValue] = reason
        }
        
        return parameters.mapValues(\.formattedAsParameter)
    }
    
    public init(
        textKey: String,
        _ variableKeys: String...,
        bundle: Bundle = .main,
        firebaseScreen: String,
        systemEventType: String,
        reason: String? = nil,
        isError: Bool = false
    ) {
        self.init(
            textKey: textKey,
            variableKeys: variableKeys,
            bundle: bundle,
            firebaseScreen: firebaseScreen,
            systemEventType: systemEventType,
            reason: reason,
            isError: isError
        )
    }
    
    public init(
        textKey: String,
        variableKeys: [String],
        bundle: Bundle = .main,
        firebaseScreen: String,
        systemEventType: String,
        reason: String? = nil,
        isError: Bool = false
    ) {
        self.text = textKey.englishString(variableKeys, bundle: bundle)
        self.firebaseScreen = firebaseScreen
        self.systemEventType = systemEventType
        self.reason = reason
        self.isError = isError
    }
}
