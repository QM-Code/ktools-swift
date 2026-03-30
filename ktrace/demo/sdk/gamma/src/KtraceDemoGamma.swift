import Ktrace

public enum GammaSdk {
    public static var traceLogger: TraceLogger {
        Holder.traceLogger
    }

    public static func testTraceLoggingChannels() throws {
        let trace = traceLogger
        try trace.trace("physics", "gamma trace test on channel 'physics'")
        try trace.trace("metrics", "gamma trace test on channel 'metrics'")
    }
}

private enum Holder {
    static let traceLogger: TraceLogger = {
        let logger = try! TraceLogger("gamma")
        try! logger.addChannel("physics", color: (try? TraceColors.named("MediumOrchid1")) ?? TraceColors.defaultColor)
        try! logger.addChannel("metrics", color: (try? TraceColors.named("LightSkyBlue1")) ?? TraceColors.defaultColor)
        return logger
    }()
}
