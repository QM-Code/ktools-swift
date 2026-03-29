import Kcli
import KcliDemoAlpha

public func runCoreDemo(arguments: [String] = CommandLine.arguments,
                        emit: @escaping (String) -> Void = defaultDemoEmit) -> Int {
    do {
        let exeName = executableName(arguments.first)
        let parser = try makeCoreDemoParser(emit: emit)
        parser.parseOrExit(arguments)

        emitCoreSummary(exeName: exeName, emit: emit)
        return 0
    } catch {
        emit("[fatal] \(String(describing: error))\n")
        return 1
    }
}

public func defaultDemoEmit(_ text: String) {
    print(text, terminator: "")
}

private func executableName(_ path: String?) -> String {
    if let path, !path.isEmpty {
        return path
    }
    return "app"
}

private func makeCoreDemoParser(emit: @escaping (String) -> Void) throws -> Parser {
    let parser = Parser()
    try parser.addInlineParser(makeKcliDemoAlphaParser(emit: emit))

    try parser.addAlias("-v", target: "--verbose")
    try parser.addAlias("-out", target: "--output")
    try parser.addAlias("-a", target: "--alpha-enable")

    try parser.setHandler("--verbose", handler: handleVerbose, description: "Enable verbose app logging.")
    try parser.setHandler("--output", handler: handleOutput, description: "Set app output target.")
    return parser
}

private func emitCoreSummary(exeName: String, emit: (String) -> Void) {
    emit("\nKCLI Swift demo core import/integration check passed\n\n")
    emit("Usage:\n")
    emit("  \(exeName) --alpha\n")
    emit("  \(exeName) --output stdout\n\n")
    emit("Enabled inline roots:\n")
    emit("  --alpha\n\n")
}

private func handleVerbose(_ context: HandlerContext) throws {}
private func handleOutput(_ context: HandlerContext, _ value: String) throws {}
