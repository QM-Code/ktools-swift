import Kcli

public func makeAlphaInlineParser(emit: @escaping DemoEmitter = defaultDemoEmit) throws -> InlineParser {
    var parser = try InlineParser("--alpha")
    try parser.setHandler("-message",
                          handler: { context, value in
                              try handleMessage(context, value, emit: emit)
                          },
                          description: "Set alpha message label.")
    try parser.setOptionalValueHandler("-enable",
                                       handler: { context, value in
                                           try handleEnable(context, value, emit: emit)
                                       },
                                       description: "Enable alpha processing.")
    return parser
}

public func makeBetaInlineParser(emit: @escaping DemoEmitter = defaultDemoEmit) throws -> InlineParser {
    var parser = try InlineParser("--beta")
    try parser.setHandler("-profile",
                          handler: { context, value in
                              try handleProfile(context, value, emit: emit)
                          },
                          description: "Select beta runtime profile.")
    try parser.setHandler("-workers",
                          handler: { context, value in
                              try handleWorkers(context, value, emit: emit)
                          },
                          description: "Set beta worker count.")
    return parser
}

public func makeGammaInlineParser(emit: @escaping DemoEmitter = defaultDemoEmit) throws -> InlineParser {
    var parser = try InlineParser("--gamma")
    try parser.setOptionalValueHandler("-strict",
                                       handler: { context, value in
                                           try handleStrict(context, value, emit: emit)
                                       },
                                       description: "Enable strict gamma mode.")
    try parser.setHandler("-tag",
                          handler: { context, value in
                              try handleTag(context, value, emit: emit)
                          },
                          description: "Set a gamma tag label.")
    return parser
}

func makeBuildInlineParser() throws -> InlineParser {
    var buildParser = try InlineParser("--build")
    try buildParser.setHandler("-profile", handler: handleBuildProfile, description: "Set build profile.")
    try buildParser.setHandler("-clean", handler: handleBuildClean, description: "Enable clean build.")
    return buildParser
}

func addCommonAliases(to parser: Parser) throws {
    try parser.addAlias("-v", target: "--verbose")
    try parser.addAlias("-out", target: "--output")
    try parser.addAlias("-a", target: "--alpha-enable")
}

func addCommonTopLevelHandlers(to parser: Parser) throws {
    try parser.setHandler("--verbose", handler: handleVerbose, description: "Enable verbose app logging.")
    try parser.setHandler("--output", handler: handleOutput, description: "Set app output target.")
}
