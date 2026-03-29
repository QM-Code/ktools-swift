import Kcli
import KcliDemoAlpha
import KcliDemoBeta
import KcliDemoGamma

public func runOmegaDemo(arguments: [String] = CommandLine.arguments,
                         emit: @escaping (String) -> Void = defaultDemoEmit) -> Int {
    do {
        let parser = try makeOmegaDemoParser(emit: emit)
        parser.parseOrExit(arguments)

        emitOmegaSummary(emit: emit)
        return 0
    } catch {
        emit("[fatal] \(String(describing: error))\n")
        return 1
    }
}

public func defaultDemoEmit(_ text: String) {
    print(text, terminator: "")
}

private func makeOmegaDemoParser(emit: @escaping (String) -> Void) throws -> Parser {
    let parser = Parser()
    try parser.addInlineParser(makeKcliDemoAlphaParser(emit: emit))
    try parser.addInlineParser(makeKcliDemoBetaParser(emit: emit))

    var gammaParser = try makeKcliDemoGammaParser(emit: emit)
    try gammaParser.setRoot("--newgamma")
    try parser.addInlineParser(gammaParser)

    var buildParser = try InlineParser("--build")
    try buildParser.setHandler("-profile", handler: handleBuildProfile, description: "Set build profile.")
    try buildParser.setHandler("-clean", handler: handleBuildClean, description: "Enable clean build.")
    try parser.addInlineParser(buildParser)

    try parser.addAlias("-v", target: "--verbose")
    try parser.addAlias("-out", target: "--output")
    try parser.addAlias("-a", target: "--alpha-enable")
    try parser.addAlias("-b", target: "--build-profile")

    try parser.setHandler("--verbose", handler: handleVerbose, description: "Enable verbose app logging.")
    try parser.setHandler("--output", handler: handleOutput, description: "Set app output target.")
    try parser.setPositionalHandler(handleArgs)
    return parser
}

private func emitOmegaSummary(emit: (String) -> Void) {
    emit("\nUsage:\n")
    emit("  kcli_demo_omega --<root>\n\n")
    emit("Enabled --<root> prefixes:\n")
    emit("  --alpha\n")
    emit("  --beta\n")
    emit("  --newgamma (gamma override)\n\n")
}

private func handleBuildProfile(_ context: HandlerContext, _ value: String) throws {}
private func handleBuildClean(_ context: HandlerContext) throws {}
private func handleVerbose(_ context: HandlerContext) throws {}
private func handleOutput(_ context: HandlerContext, _ value: String) throws {}
private func handleArgs(_ context: HandlerContext) throws {}
