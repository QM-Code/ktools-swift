import Kcli
import Ktrace
import KtraceDemoAlpha
import KtraceDemoBeta
import KtraceDemoGamma

public typealias DemoEmitter = (String) -> Void

public func defaultDemoEmit(_ text: String) {
    print(text, terminator: "")
}

public func runBootstrapDemo(emit: @escaping DemoEmitter = defaultDemoEmit) -> Int {
    do {
        let logger = Logger(output: emit)
        let trace = try TraceLogger("bootstrap")
        try trace.addChannel("app")
        try logger.addTraceLogger(trace)
        try logger.enableChannel(trace, ".app")
        try trace.trace("app", "ktrace Swift demo bootstrap import/integration check passed")
        return 0
    } catch {
        emit("[fatal] \(String(describing: error))\n")
        return 1
    }
}

public func runCoreDemo(arguments: [String] = CommandLine.arguments,
                        emit: @escaping DemoEmitter = defaultDemoEmit) -> Int {
    do {
        let logger = Logger(output: emit)
        let trace = try TraceLogger("core")
        try trace.addChannel("app", color: try TraceColors.color("BrightCyan"))
        try trace.addChannel("startup", color: try TraceColors.color("BrightYellow"))

        try logger.addTraceLogger(trace)
        try logger.addTraceLogger(AlphaSdk.getTraceLogger())

        try logger.enableChannel(trace, ".app")
        try trace.trace("app", "core initialized local trace channels")

        let parser = Parser()
        try parser.addInlineParser(logger.makeInlineParser(trace))
        try parser.parseOrThrow(arguments)

        try trace.trace("app", "cli processing enabled, use --trace for options")
        try trace.trace("startup", "testing imported tracing, use --trace '*.*' to view imported channels")
        try AlphaSdk.testTraceLoggingChannels()
        return 0
    } catch let error as CliError {
        emit("[error] [cli] \(error.message)\n")
        return 2
    } catch {
        emit("[fatal] \(String(describing: error))\n")
        return 1
    }
}

public func runOmegaDemo(arguments: [String] = CommandLine.arguments,
                         emit: @escaping DemoEmitter = defaultDemoEmit) -> Int {
    do {
        let logger = Logger(output: emit)
        let trace = try TraceLogger("omega")
        try trace.addChannel("app", color: try TraceColors.color("BrightCyan"))
        try trace.addChannel("orchestrator", color: try TraceColors.color("BrightYellow"))
        try trace.addChannel("deep")
        try trace.addChannel("deep.branch")
        try trace.addChannel("deep.branch.leaf", color: try TraceColors.color("LightSalmon1"))

        try logger.addTraceLogger(trace)
        try logger.addTraceLogger(AlphaSdk.getTraceLogger())
        try logger.addTraceLogger(BetaSdk.getTraceLogger())
        try logger.addTraceLogger(GammaSdk.getTraceLogger())

        try logger.enableChannel(trace, ".app")
        try trace.trace("app", "omega initialized local trace channels")
        try logger.disableChannel(trace, ".app")

        let parser = Parser()
        try parser.addInlineParser(logger.makeInlineParser(trace))
        try parser.parseOrThrow(arguments)

        try trace.trace("app", "cli processing enabled, use --trace for options")
        try trace.trace("app", "testing external tracing, use --trace '*.*' to view top-level channels")
        try trace.trace("deep.branch.leaf", "omega trace test on channel 'deep.branch.leaf'")
        try AlphaSdk.testTraceLoggingChannels()
        try BetaSdk.testTraceLoggingChannels()
        try GammaSdk.testTraceLoggingChannels()
        try AlphaSdk.testStandardLoggingChannels()
        try trace.trace("orchestrator", "omega completed imported SDK trace checks")
        try trace.info("testing...")
        try trace.warn("testing...")
        try trace.error("testing...")
        return 0
    } catch let error as CliError {
        emit("[error] [cli] \(error.message)\n")
        return 2
    } catch {
        emit("[fatal] \(String(describing: error))\n")
        return 1
    }
}
