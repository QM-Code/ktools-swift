import Ktrace

public enum GammaSdk {
    public static func getTraceLogger() -> TraceLogger {
        Holder.traceLogger
    }

    public static func testTraceLoggingChannels() throws {
        let trace = getTraceLogger()
        try trace.trace("physics", "gamma trace test on channel 'physics'")
        try trace.trace("metrics", "gamma trace test on channel 'metrics'")
    }
}

private enum Holder {
    static let traceLogger: TraceLogger = {
        let logger = try! TraceLogger("gamma")
        try! logger.addChannel("physics", color: (try? TraceColors.color("MediumOrchid1")) ?? TraceColors.DEFAULT)
        try! logger.addChannel("metrics", color: (try? TraceColors.color("LightSkyBlue1")) ?? TraceColors.DEFAULT)
        return logger
    }()
}
