import FirebasePerformance
import Logging

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

public final class GAPerformanceLogger: PerformanceLogger {
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
    
    public func startTrace(name: String) -> PerformanceTrace {
        let trace = Performance.startTrace(name: name)
        return GATrace(trace)
    }
    
    public func startHTTPMetric(url: URL, method: RequestMethod) -> PerformanceMetric {
        let metric = HTTPMetric(url: url, httpMethod: HTTPMethod.httpMethodFrom(string: method.rawValue))
        return GAHTTPMetric(metric)
    }
}

public final class GATrace: PerformanceTrace {
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

public final class GAHTTPMetric: PerformanceMetric {
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
