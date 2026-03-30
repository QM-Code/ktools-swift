import Ktrace

public enum AlphaSdk {
    public static var traceLogger: TraceLogger {
        Holder.traceLogger
    }

    public static func testTraceLoggingChannels() throws {
        let trace = traceLogger
        try trace.trace("net", "testing...")
        try trace.trace("net.alpha", "testing...")
        try trace.trace("net.beta", "testing...")
        try trace.trace("net.gamma", "testing...")
        try trace.trace("net.gamma.deep", "testing...")
        try trace.trace("cache", "testing...")
        try trace.trace("cache.gamma", "testing...")
        try trace.trace("cache.delta", "testing...")
        try trace.trace("cache.special", "testing...")
    }

    public static func testStandardLoggingChannels() throws {
        let trace = traceLogger
        try trace.info("testing...")
        try trace.warn("testing...")
        try trace.error("testing...")
    }
}

private enum Holder {
    static let traceLogger: TraceLogger = {
        let logger = try! TraceLogger("alpha")
        try! logger.addChannel("net", color: (try? TraceColors.named("DeepSkyBlue1")) ?? TraceColors.defaultColor)
        try! logger.addChannel("net.alpha")
        try! logger.addChannel("net.beta")
        try! logger.addChannel("net.gamma")
        try! logger.addChannel("net.gamma.deep")
        try! logger.addChannel("cache", color: (try? TraceColors.named("Gold3")) ?? TraceColors.defaultColor)
        try! logger.addChannel("cache.gamma", color: (try? TraceColors.named("Gold3")) ?? TraceColors.defaultColor)
        try! logger.addChannel("cache.delta")
        try! logger.addChannel("cache.special", color: (try? TraceColors.named("Red")) ?? TraceColors.defaultColor)
        return logger
    }()
}
