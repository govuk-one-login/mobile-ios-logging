import Foundation

public protocol ScreenViewProtocol: Equatable {
    associatedtype Screen: ScreenType
    var id: String? { get }
    var screen: Screen { get }
    var title: String { get }
    var parameters: [String: String] { get }
}

public struct ScreenView<Screen: ScreenType>: ScreenViewProtocol {
    public let id: String?
    public let screen: Screen
    public let title: String
    
    public var parameters: [String: String] {
        [
            ScreenParameter.id.rawValue: id,
            ScreenParameter.isError.rawValue: "false"
        ].compactMapValues(\.?.formattedAsParameter)
    }
    
    public init(id: String? = nil,
                screen: Screen,
                titleKey: String,
                variableKeys: [String] = [],
                bundle: Bundle = .main) {
        self.id = id
        self.screen = screen
        self.title = titleKey.englishString(variableKeys, bundle: bundle).formattedAsParameter
    }
}

extension ScreenView: Equatable {
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
