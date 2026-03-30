import Ktrace

public enum BetaSdk {
    public static var traceLogger: TraceLogger {
        Holder.traceLogger
    }

    public static func testTraceLoggingChannels() throws {
        let trace = traceLogger
        try trace.trace("io", "beta trace test on channel 'io'")
        try trace.trace("scheduler", "beta trace test on channel 'scheduler'")
    }
}

private enum Holder {
    static let traceLogger: TraceLogger = {
        let logger = try! TraceLogger("beta")
        try! logger.addChannel("io", color: (try? TraceColors.named("MediumSpringGreen")) ?? TraceColors.defaultColor)
        try! logger.addChannel("scheduler", color: (try? TraceColors.named("Orange3")) ?? TraceColors.defaultColor)
        return logger
    }()
}
