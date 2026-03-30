import Kcli
import Ktrace
import KtraceDemoAlpha

public func runCoreDemo(arguments: [String] = CommandLine.arguments,
                        emit: @escaping (String) -> Void = defaultCoreDemoEmit) -> Int {
    runCoreTraceDemo(emit: emit) {
        let logger = Logger(output: emit)
        let trace = try makeCoreDemoTraceLogger()

        try logger.attach(trace)
        try logger.attach(AlphaSdk.traceLogger)

        try logger.enableChannel(".app", in: trace)
        try trace.trace("app", "core initialized local trace channels")

        let parser = Parser()
        try parser.addInlineParser(logger.inlineParser(for: trace))
        try parser.parse(arguments)

        try trace.trace("app", "cli processing enabled, use --trace for options")
        try trace.trace("startup", "testing imported tracing, use --trace '*.*' to view imported channels")
        try AlphaSdk.testTraceLoggingChannels()
    }
}

public func defaultCoreDemoEmit(_ text: String) {
    print(text, terminator: "")
}

private func runCoreTraceDemo(emit: (String) -> Void, _ body: () throws -> Void) -> Int {
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

private func makeCoreDemoTraceLogger() throws -> TraceLogger {
    let trace = try TraceLogger("core")
    try trace.addChannel("app", color: try TraceColors.named("BrightCyan"))
    try trace.addChannel("startup", color: try TraceColors.named("BrightYellow"))
    return trace
}
