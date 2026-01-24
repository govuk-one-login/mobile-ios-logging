import FirebasePerformance
import Logging

//protocol PerformanceLogger {
//    var isEnabled: Bool { get }
//    
//    func enable()
//    func disable()
//    
//    func startTrace(name: String) -> PerformanceTrace
//    func startHTTPMetric(url: URL, method: RequestType) -> PerformanceMetric
//}
//
//protocol PerformanceTrace {
//    func start()
//    func stop()
//    func incrementMetric(_ name: String, by: Int64)
//    func setValue(_ value: Int64, forMetric metricName: String)
//    func setValue(_ value: String, forAttribute attribute: String)
//    func setValuesForKeys(for keyedValues: [String: any Sendable])
//}
//
//protocol PerformanceMetric {
//    var responseCode: Int { get set }
//    
//    func start()
//    func stop()
//    func setValue(value: String, forAttribute: String)
//}

//enum RequestType: String {
//    case get
//    case put
//    case post
//    case delete
//    case head
//    case patch
//    case options
//    case trace
//    case connect
//    
//    var firebaseRequestType: HTTPMethod {
//        switch self {
//        case .get: .get
//        case .put: .put
//        case .post: .put
//        case .delete: .delete
//        case .head: .head
//        case .patch: .patch
//        case .options: .options
//        case .trace: .trace
//        case .connect: .connect
//        }
//    }
//}

extension RequestType {
    var firebaseRequestType: HTTPMethod {
        switch self {
        case .get: .get
        case .put: .put
        case .post: .put
        case .delete: .delete
        case .head: .head
        case .patch: .patch
        case .options: .options
        case .trace: .trace
        case .connect: .connect
        }
    }
}


final class PerformanceMonitor: PerformanceLogger {
    var isEnabled: Bool {
        Performance.sharedInstance().isDataCollectionEnabled
        && Performance.sharedInstance().isInstrumentationEnabled
    }
    
    init() {
        self.disable()
    }
    
    func enable() {
        Performance.sharedInstance().isDataCollectionEnabled = true
        Performance.sharedInstance().isInstrumentationEnabled = true
    }
    
    func disable() {
        Performance.sharedInstance().isDataCollectionEnabled = false
        Performance.sharedInstance().isInstrumentationEnabled = false
    }
    
    func startTrace(name: String) -> any PerformanceTrace {
        let trace = Performance.startTrace(name: name)
        return GDSTrace(trace)
    }
    
    func startHTTPMetric(url: URL, method: RequestType) -> any PerformanceMetric {
        let metric = HTTPMetric(url: url, httpMethod: method.firebaseRequestType)
        return GDSHTTPMetric(metric)
    }
}

final class GDSTrace: PerformanceTrace {
    private let trace: Trace?
    
    init(_ trace: Trace?) {
        self.trace = trace
    }
    
    func start() {
        trace?.start()
    }
    
    func stop() {
        trace?.stop()
    }
    
    func incrementMetric(_ name: String, by amount: Int64) {
        trace?.incrementMetric(name, by: amount)
    }
    
    func setValue(_ value: Int64, forMetric metricName: String) {
        trace?.setValue(value, forMetric: metricName)
    }
    
    func setValue(_ value: String, forAttribute metricName: String) {
        trace?.setValue(value, forAttribute: metricName)
    }
    
    func setValuesForKeys(for keyedValues: [String: any Sendable]) {
        trace?.setValuesForKeys(keyedValues)
    }
}

final class GDSHTTPMetric: PerformanceMetric {
    private let metric: HTTPMetric?
    
    var responseCode: Int = 0 {
        didSet {
            metric?.responseCode = responseCode
        }
    }
    
    init(_ metric: HTTPMetric?) {
        self.metric = metric
    }
    
    func start() {
        metric?.start()
    }
    
    func stop() {
        metric?.stop()
    }
    
    func setValue(value: String, forAttribute: String) {
        metric?.setValue(value, forAttribute: forAttribute)
    }
}
