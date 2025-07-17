import Foundation

public struct ErrorScreenView<Screen: ScreenType>: ScreenViewProtocol, LoggableError {
    public let id: String?
    public let title: String
    public let screen: Screen
    public let reason: String?
    public let endpoint: String?
    public let statusCode: String?
    public let hash: String?
    
    public var parameters: [String: String] {
        [
            ScreenParameter.id.rawValue: id,
            ScreenParameter.reason.rawValue: reason,
            ScreenParameter.endpoint.rawValue: endpoint,
            ScreenParameter.hash.rawValue: hash,
            ScreenParameter.status.rawValue: statusCode,
            ScreenParameter.isError.rawValue: "true"
        ]
        .compactMapValues(\.?.formattedAsParameter)
    }
    
    public init(id: String? = nil,
                screen: Screen,
                titleKey: String,
                reason: String? = nil,
                endpoint: String? = nil,
                statusCode: String? = nil,
                hash: String? = nil,
                bundle: Bundle = .main) {
        self.screen = screen
        self.title = titleKey.englishString(bundle: bundle).formattedAsParameter
        self.id = id
        self.reason = reason
        self.endpoint = endpoint
        self.statusCode = statusCode
        self.hash = hash
    }
    
    public init(id: String? = nil,
                screen: Screen,
                titleKey: String,
                error: LoggableError,
                bundle: Bundle = .main) {
        self.id = id
        self.screen = screen
        title = titleKey.englishString(bundle: bundle).formattedAsParameter
        reason = error.reason
        endpoint = error.endpoint
        statusCode = error.statusCode
        hash = error.hash
    }
}

extension ErrorScreenView: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return (
            type(of: lhs) == type(of: rhs) &&
            lhs.id == rhs.id &&
            lhs.screen.name == rhs.screen.name &&
            lhs.title == rhs.title &&
            lhs.parameters == rhs.parameters
        )
    }
}
