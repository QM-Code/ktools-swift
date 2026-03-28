import Kcli
import Ktrace
import KtraceDemoAlpha
import KtraceDemoBeta
import KtraceDemoGamma

public typealias DemoEmitter = (String) -> Void

public func defaultDemoEmit(_ text: String) {
    print(text, terminator: "")
}

private struct DemoChannelDefinition {
    let name: String
    let colorName: String?
}

public func runBootstrapDemo(emit: @escaping DemoEmitter = defaultDemoEmit) -> Int {
    runTraceDemo(emit: emit) {
        let logger = Logger(output: emit)
        let trace = try makeDemoTraceLogger(namespace: "bootstrap",
                                            channels: [DemoChannelDefinition(name: "app", colorName: nil)])
        try logger.addTraceLogger(trace)
        try logger.enableChannel(trace, ".app")
        try trace.trace("app", "ktrace Swift demo bootstrap import/integration check passed")
    }
}

public func runCoreDemo(arguments: [String] = CommandLine.arguments,
                        emit: @escaping DemoEmitter = defaultDemoEmit) -> Int {
    runTraceDemo(emit: emit) {
        let logger = Logger(output: emit)
        let trace = try makeDemoTraceLogger(namespace: "core",
                                            channels: [
                                                DemoChannelDefinition(name: "app", colorName: "BrightCyan"),
                                                DemoChannelDefinition(name: "startup", colorName: "BrightYellow"),
                                            ])

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
    }
}

public func runOmegaDemo(arguments: [String] = CommandLine.arguments,
                         emit: @escaping DemoEmitter = defaultDemoEmit) -> Int {
    runTraceDemo(emit: emit) {
        let logger = Logger(output: emit)
        let trace = try makeDemoTraceLogger(namespace: "omega",
                                            channels: [
                                                DemoChannelDefinition(name: "app", colorName: "BrightCyan"),
                                                DemoChannelDefinition(name: "orchestrator", colorName: "BrightYellow"),
                                                DemoChannelDefinition(name: "deep", colorName: nil),
                                                DemoChannelDefinition(name: "deep.branch", colorName: nil),
                                                DemoChannelDefinition(name: "deep.branch.leaf", colorName: "LightSalmon1"),
                                            ])

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
    }
}

private func runTraceDemo(emit: DemoEmitter, _ body: () throws -> Void) -> Int {
    do {
        try body()
        return 0
    } catch let error as CliError {
        emit("[error] [cli] \(error.message)\n")
        return 2
    } catch {
        emit("[fatal] \(String(describing: error))\n")
        return 1
    }
}

private func makeDemoTraceLogger(namespace: String,
                                 channels: [DemoChannelDefinition]) throws -> TraceLogger {
    let trace = try TraceLogger(namespace)
    for channel in channels {
        let color = try channel.colorName.map(TraceColors.color) ?? TraceColors.DEFAULT
        try trace.addChannel(channel.name, color: color)
    }
    return trace
}
