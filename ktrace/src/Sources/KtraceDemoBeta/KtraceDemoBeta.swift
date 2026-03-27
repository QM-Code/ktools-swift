import Ktrace

public enum BetaSdk {
    public static func getTraceLogger() -> TraceLogger {
        Holder.traceLogger
    }

    public static func testTraceLoggingChannels() throws {
        let trace = getTraceLogger()
        try trace.trace("io", "beta trace test on channel 'io'")
        try trace.trace("scheduler", "beta trace test on channel 'scheduler'")
    }
}

private enum Holder {
    static let traceLogger: TraceLogger = {
        let logger = try! TraceLogger("beta")
        try! logger.addChannel("io", color: (try? TraceColors.color("MediumSpringGreen")) ?? TraceColors.DEFAULT)
        try! logger.addChannel("scheduler", color: (try? TraceColors.color("Orange3")) ?? TraceColors.DEFAULT)
        return logger
    }()
}
