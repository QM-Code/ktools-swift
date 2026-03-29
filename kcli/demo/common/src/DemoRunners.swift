import Kcli

public func runCoreDemo(arguments: [String] = CommandLine.arguments,
                        emit: @escaping DemoEmitter = defaultDemoEmit) -> Int {
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

public func runOmegaDemo(arguments: [String] = CommandLine.arguments,
                         emit: @escaping DemoEmitter = defaultDemoEmit) -> Int {
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

func makeCoreDemoParser(emit: @escaping DemoEmitter) throws -> Parser {
    let parser = Parser()
    try parser.addInlineParser(makeAlphaInlineParser(emit: emit))
    try addCommonAliases(to: parser)
    try addCommonTopLevelHandlers(to: parser)
    return parser
}

func makeOmegaDemoParser(emit: @escaping DemoEmitter) throws -> Parser {
    let parser = Parser()
    try parser.addInlineParser(makeAlphaInlineParser(emit: emit))
    try parser.addInlineParser(makeBetaInlineParser(emit: emit))

    var gammaParser = try makeGammaInlineParser(emit: emit)
    try gammaParser.setRoot("--newgamma")
    try parser.addInlineParser(gammaParser)
    try parser.addInlineParser(makeBuildInlineParser())

    try addCommonAliases(to: parser)
    try parser.addAlias("-b", target: "--build-profile")
    try addCommonTopLevelHandlers(to: parser)
    try parser.setPositionalHandler(handleArgs)
    return parser
}
