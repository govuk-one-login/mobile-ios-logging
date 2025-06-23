import Firebase
import FirebaseAnalytics
import FirebaseCrashlytics
import Logging

/// GAnalytics
///
/// An abstraction class for bringing Google Analytics (Firebase and Crashlytics) into the app from the Firebase package.
/// To provide user-specific insights for logging app metrics and performance.
public struct GAnalyticsV2 {
    let analyticsLogger: AnalyticsLogger.Type
    let crashLogger: CrashLogger
    public let preferenceStore: AnalyticsPreferenceStore
    
    /// Additional parameters for the application
    public var additionalParameters = [String: Any]()
    
    /// Initialises the Firebase instance when launching the app.
    public static func configure() {
        configure(app: FirebaseApp.self)
    }
    
    static func configure(app: AnalyticsApp.Type) {
        app.configure()
    }
    
    init(analyticsLogger: AnalyticsLogger.Type,
         crashLogger: CrashLogger,
         preferenceStore: AnalyticsPreferenceStore) {
        self.analyticsLogger = analyticsLogger
        self.crashLogger = crashLogger
        self.preferenceStore = preferenceStore
    }
    
    public init() {
        self.init(analyticsLogger: Analytics.self,
                  crashLogger: Crashlytics.crashlytics(),
                  preferenceStore: UserDefaultsPreferenceStore())
    }
    
    public func start() {
        updateAnalyticsPreference(preferenceStore.hasAcceptedAnalytics)
        subscribeToPreferenceStore()
    }
    
    func subscribeToPreferenceStore() {
        Task {
            for await value in preferenceStore.stream() {
                updateAnalyticsPreference(value)
            }
        }
    }
    
    func updateAnalyticsPreference(_ preference: Bool?) {
        switch preference {
        case true:
            grantAnalyticsPermission()
        default:
            denyAnalyticsPermission()
        }
    }
    
    /// Merging `parameters` dictionary parameter with `additionalParameters` property
    private func mergeAdditionalParameters(_ parameters: [String: Any]) -> [String: Any] {
        additionalParameters.merging(parameters) { $1 }
    }
}

extension GAnalyticsV2: AnalyticsServiceV2 {
    public func addingAdditionalParameters(
        _ additionalParameters: [String: Any]
    ) -> Self {
        var newCopy = self
        newCopy.additionalParameters = self.additionalParameters
            .merging(additionalParameters) { lhs, _ in
                lhs
            }
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
        crashLogger.record(error: error)
    }
    
    /// Granting analytics and crashlytics permissions in Firebase package.
    func grantAnalyticsPermission() {
        analyticsLogger.setAnalyticsCollectionEnabled(true)
        crashLogger.setCrashlyticsCollectionEnabled(true)
    }
    
    /// Denying analytics and crashlytics permissions in Firebase package.
    func denyAnalyticsPermission() {
        analyticsLogger.setAnalyticsCollectionEnabled(false)
        analyticsLogger.resetAnalyticsData()
        
        crashLogger.setCrashlyticsCollectionEnabled(false)
    }
}
