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

//extension RequestProtocol {
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
//        default:
//                .get
//        }
//    }
//    
//    public static func requestTypeFrom(_ string: String) -> RequestType {
//        return switch string {
//        case "get": RequestType.get
//        case "put": RequestType.put
//        case "post": RequestType.put
//        case "delete": RequestType.delete
//        case "head": RequestType.head
//        case "patch": RequestType.patch
//        case "options": RequestType.options
//        case "trace": RequestType.trace
//        case "connect": RequestType.connect
//        default: .get
//        }
//    }
//}

extension HTTPMethod {
    static func httpMethodFrom(string: String) -> Self {
        return switch string {
        case "get": Self.get
        case "put": Self.put
        case "post": Self.put
        case "delete": Self.delete
        case "head": Self.head
        case "patch": Self.patch
        case "options": Self.options
        case "trace": Self.trace
        case "connect": Self.connect
        default: Self.get
        }
    }
}

public final class PerformanceMonitor: PerformanceLogger {
    public typealias Trace = GDSTrace
    public typealias Metric = GDSHTTPMetric
    
    public var isEnabled: Bool {
        Performance.sharedInstance().isDataCollectionEnabled
        && Performance.sharedInstance().isInstrumentationEnabled
    }
    
    init() {
        self.disable()
    }
    
    public func enable() {
        Performance.sharedInstance().isDataCollectionEnabled = true
        Performance.sharedInstance().isInstrumentationEnabled = true
    }
    
    public func disable() {
        Performance.sharedInstance().isDataCollectionEnabled = false
        Performance.sharedInstance().isInstrumentationEnabled = false
    }
    
    public func startTrace(name: String) -> GDSTrace {
        let trace = Performance.startTrace(name: name)
        return GDSTrace(trace)
    }
    
    public func startHTTPMetric(url: URL, method: String) -> GDSHTTPMetric {
        let metric = HTTPMetric(url: url, httpMethod: HTTPMethod.httpMethodFrom(string: method))
        return GDSHTTPMetric(metric)
    }
}

public final class GDSTrace: PerformanceTrace {
    private let trace: Trace?
    
    init(_ trace: Trace?) {
        self.trace = trace
    }
    
    public func start() {
        trace?.start()
    }
    
    public func stop() {
        trace?.stop()
    }
    
    public func incrementMetric(_ name: String, by amount: Int64) {
        trace?.incrementMetric(name, by: amount)
    }
    
    public func setValue(_ value: Int64, forMetric metricName: String) {
        trace?.setValue(value, forMetric: metricName)
    }
    
    public func setValue(_ value: String, forAttribute attribute: String) {
        trace?.setValue(value, forAttribute: attribute)
    }
    
    public func setValuesForKeys(for keyedValues: [String: any Sendable]) {
        trace?.setValuesForKeys(keyedValues)
    }
}

public final class GDSHTTPMetric: PerformanceMetric {
    private let metric: HTTPMetric?
    
    public var responseCode: Int = 0 {
        didSet {
            metric?.responseCode = responseCode
        }
    }
    
    init(_ metric: HTTPMetric?) {
        self.metric = metric
    }
    
    public func start() {
        metric?.start()
    }
    
    public func stop() {
        metric?.stop()
    }
    
    public func setValue(value: String, forAttribute: String) {
        metric?.setValue(value, forAttribute: forAttribute)
    }
}
