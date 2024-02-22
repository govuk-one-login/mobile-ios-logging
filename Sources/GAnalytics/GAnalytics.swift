import Firebase
import FirebaseAnalytics
import FirebaseCrashlytics
import Logging

/// GAnalytics
///
/// An abstraction class for bringing Google Analytics (Firebase and Crashlytics) into the app from the Firebase package.
/// To provide user-specific insights for logging app metrics and performance.
public class GAnalytics: AnalyticsService {
    /// Additional parameters for the application
    public var additionalParameters = [String: Any]()
    
    /// Initialises the Firebase instance when launching the app.
    public func configure() {
        FirebaseApp.configure()
        bundleDataObserver()
        fetchSettingBundleData()
    }
    
    /// Creates Notification Center Observer for user's analytics permissions for the app.
    private func bundleDataObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(fetchSettingBundleData), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    /// Fetches permissions for analytics from User Defaults.
    /// Checks if analytics permissions have been set, if they are, sets permissions saved in User Defaults.
    @objc private func fetchSettingBundleData() {
        guard let hasAcceptedAnalytics = UserDefaults.standard.hasAcceptedAnalytics else { return }
        if hasAcceptedAnalytics {
            grantAnalyticsPermission()
        } else {
            denyAnalyticsPermission()
        }
    }
    
    /// Tracks screens adding screen tracking parameters in Firebase package.
    public func trackScreen(_ screen: LoggableScreen,
                            parameters params: [String: Any] = [:]) {
        var parameters = mergeAdditionalParameters(params)
        
        parameters[AnalyticsParameterScreenName] = screen.name
        parameters[AnalyticsParameterScreenClass] = screen.name
        
        Analytics.logEvent(AnalyticsEventScreenView,
                           parameters: parameters)
    }
    
    public func trackScreen(_ screen: LoggableScreenV2,
                            parameters params: [String : Any]) {
        var parameters = mergeAdditionalParameters(params)
        
        parameters[AnalyticsParameterScreenClass] = screen.type.name
        parameters[AnalyticsParameterScreenName] = screen.name
        
        Analytics.logEvent(AnalyticsEventScreenView,
                           parameters: parameters)
    }
    
    /// Logs events accepting the event name and parameters in Firebase package.
    public func logEvent(_ event: LoggableEvent, parameters params: [String: Any]) {
        let parameters = mergeAdditionalParameters(params)
        Analytics.logEvent(event.name, parameters: parameters)
    }
    
    /// Logs crashes accepting an error in Firebase package.
    public func logCrash(_ error: NSError) {
        Crashlytics.crashlytics().record(error: error)
    }
    
    /// Granting analytics and crashlytics permissions in Firebase package.
    public func grantAnalyticsPermission() {
        Analytics.setAnalyticsCollectionEnabled(true)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
    }
    
    /// Denying analytics and crashlytics permissions in Firebase package.
    public func denyAnalyticsPermission() {
        Analytics.setAnalyticsCollectionEnabled(false)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
        Analytics.resetAnalyticsData()
    }
    
    public init() {
        // this is empty because there are no properties to initialise but
        // it is required to initialise this outside of the package
    }
    
    /// Merging `parameters` dictionary parameter with `additionalParameters` property
    private func mergeAdditionalParameters(_ parameters: [String: Any]) -> [String: Any] {
        additionalParameters.merging(parameters) { $1 }
    }
}
