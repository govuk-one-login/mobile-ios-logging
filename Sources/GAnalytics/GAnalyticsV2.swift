import Firebase
import FirebaseAnalytics
import FirebaseCrashlytics
import Logging

/// GAnalyticsV2
///
/// An abstraction class for bringing Google Analytics (Firebase and Crashlytics) into the app from the Firebase package.
/// To provide user-specific insights for logging app metrics and performance.
public struct GAnalyticsV2 {
    static var analyticsApp: AnalyticsApp.Type = FirebaseApp.self
    public let analyticsPreferenceStore: AnalyticsPreferenceStore
    private let analyticsLogger: AnalyticsLogger.Type
    private let crashLogger: CrashLogger
    
    /// Additional parameters for the application
    public var additionalParameters = [String: Any]()
    
    init(analyticsPreferenceStore: AnalyticsPreferenceStore,
         analyticsLogger: AnalyticsLogger.Type,
         crashLogger: CrashLogger) {
        self.analyticsPreferenceStore = analyticsPreferenceStore
        self.analyticsLogger = analyticsLogger
        self.crashLogger = crashLogger
        
        crashLogger.setCrashlyticsCollectionEnabled(true)
    }
    
    public init(analyticsPreferenceStore: AnalyticsPreferenceStore) {
        self.init(analyticsPreferenceStore: analyticsPreferenceStore,
                  analyticsLogger: Analytics.self,
                  crashLogger: Crashlytics.crashlytics())
    }
    
    /// Initialises the Firebase instance when launching the app.
    public static func configure() {
        analyticsApp.configure()
    }
    
    /// Activates subscription to preference store events and updates based on existing preference.
    public func activate() {
        subscribeToPreferenceStore()
        updateAnalyticsPreference(analyticsPreferenceStore.hasAcceptedAnalytics)
    }
    
    private func subscribeToPreferenceStore() {
        Task {
            for await value in analyticsPreferenceStore.stream() {
                updateAnalyticsPreference(value)
            }
        }
    }
    
    private func updateAnalyticsPreference(_ preference: Bool?) {
        switch preference {
        case true:
            grantAnalyticsPermission()
        default:
            denyAnalyticsPermission()
        }
    }
    
    /// Merging `parameters` dictionary parameter with `additionalParameters` property
    private func mergeAdditionalParameters(_ parameters: [String: Any]) -> [String: Any] {
        additionalParameters.merging(parameters) { lhs, _ in
            lhs
        }
    }
}

extension GAnalyticsV2: AnalyticsServiceV2 {
    public func addingAdditionalParameters(
        _ additionalParameters: [String: Any]
    ) -> Self {
        var newCopy = self
        newCopy.additionalParameters = self.mergeAdditionalParameters(additionalParameters)
        return newCopy
    }
    
    /// Tracks screens adding screen tracking parameters in Firebase package.
    public func trackScreen(_ screen: LoggableScreen,
                            parameters params: [String: Any] = [:]) {
        var parameters = mergeAdditionalParameters(params)
        
        parameters[AnalyticsParameterScreenName] = screen.name
        parameters[AnalyticsParameterScreenClass] = screen.name
        
        analyticsLogger.logEvent(AnalyticsEventScreenView,
                                 parameters: parameters)
    }
    
    public func trackScreen(_ screen: any LoggableScreenV2,
                            parameters params: [String: Any]) {
        var parameters = mergeAdditionalParameters(params)
        
        parameters[AnalyticsParameterScreenName] = screen.name
        parameters[AnalyticsParameterScreenClass] = screen.type.description
        
        analyticsLogger.logEvent(AnalyticsEventScreenView,
                                 parameters: parameters)
    }
    
    /// Logs events accepting the event name and parameters in Firebase package.
    public func logEvent(_ event: LoggableEvent, parameters params: [String: Any]) {
        let parameters = mergeAdditionalParameters(params)
        analyticsLogger.logEvent(event.name, parameters: parameters)
    }
    
    /// Logs crashes accepting an error in Firebase package.
    public func logCrash(_ error: NSError) {
        crashLogger.record(error: error, userInfo: nil)
    }
    
    public func logCrash(_ crash: Error) {
        let errorUserInfo = (crash as? CustomNSError)?.errorUserInfo ?? [:]
        
        let paramsToLog = additionalParameters.merging(errorUserInfo) { lhs, _ in
            lhs
        }

        crashLogger.record(error: crash, userInfo: paramsToLog)
    }
    
    /// Granting analytics and crashlytics permissions in Firebase package.
    func grantAnalyticsPermission() {
        analyticsLogger.setAnalyticsCollectionEnabled(true)
    }
    
    /// Denying analytics and crashlytics permissions in Firebase package.
    func denyAnalyticsPermission() {
        analyticsLogger.setAnalyticsCollectionEnabled(false)
        analyticsLogger.resetAnalyticsData()
    }
}
