import Foundation
import Kcli

public typealias DemoEmitter = (String) -> Void

public struct DemoRuntimeError: Error, CustomStringConvertible, LocalizedError, Equatable {
    public let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var description: String {
        message
    }

    public var errorDescription: String? {
        message
    }
}

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

public func runCoreDemo(arguments: [String] = CommandLine.arguments,
                        emit: @escaping DemoEmitter = defaultDemoEmit) -> Int {
    do {
        let exeName = executableName(arguments.first)
        let parser = Parser()
        try parser.addInlineParser(makeAlphaInlineParser(emit: emit))

        try parser.addAlias("-v", target: "--verbose")
        try parser.addAlias("-out", target: "--output")
        try parser.addAlias("-a", target: "--alpha-enable")

        try parser.setHandler("--verbose", handler: handleVerbose, description: "Enable verbose app logging.")
        try parser.setHandler("--output", handler: handleOutput, description: "Set app output target.")
        parser.parseOrExit(arguments)

        emit("\nKCLI Swift demo core import/integration check passed\n\n")
        emit("Usage:\n")
        emit("  \(exeName) --alpha\n")
        emit("  \(exeName) --output stdout\n\n")
        emit("Enabled inline roots:\n")
        emit("  --alpha\n\n")
        return 0
    } catch {
        emit("[fatal] \(String(describing: error))\n")
        return 1
    }
}

public func runOmegaDemo(arguments: [String] = CommandLine.arguments,
                         emit: @escaping DemoEmitter = defaultDemoEmit) -> Int {
    do {
        let parser = Parser()
        try parser.addInlineParser(makeAlphaInlineParser(emit: emit))
        try parser.addInlineParser(makeBetaInlineParser(emit: emit))

        var gammaParser = try makeGammaInlineParser(emit: emit)
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

        parser.parseOrExit(arguments)

        emit("\nUsage:\n")
        emit("  kcli_demo_omega --<root>\n\n")
        emit("Enabled --<root> prefixes:\n")
        emit("  --alpha\n")
        emit("  --beta\n")
        emit("  --newgamma (gamma override)\n\n")
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

private func printProcessingLine(_ context: HandlerContext,
                                 value: String,
                                 emit: DemoEmitter = defaultDemoEmit) {
    if context.valueTokens.isEmpty {
        emit("Processing \(context.option)\n")
        return
    }

    if context.valueTokens.count == 1 {
        emit("Processing \(context.option) with value \"\(value)\"\n")
        return
    }

    let joined = context.valueTokens.map { "\"\($0)\"" }.joined(separator: ",")
    emit("Processing \(context.option) with values [\(joined)]\n")
}

private func handleMessage(_ context: HandlerContext,
                           _ value: String,
                           emit: DemoEmitter) throws {
    printProcessingLine(context, value: value, emit: emit)
}

private func handleEnable(_ context: HandlerContext,
                          _ value: String,
                          emit: DemoEmitter) throws {
    printProcessingLine(context, value: value, emit: emit)
}

private func handleProfile(_ context: HandlerContext,
                           _ value: String,
                           emit: DemoEmitter) throws {
    printProcessingLine(context, value: value, emit: emit)
}

private func handleWorkers(_ context: HandlerContext,
                           _ value: String,
                           emit: DemoEmitter) throws {
    if !value.isEmpty && Int(value) == nil {
        throw DemoRuntimeError("expected an integer")
    }
    printProcessingLine(context, value: value, emit: emit)
}

private func handleStrict(_ context: HandlerContext,
                          _ value: String,
                          emit: DemoEmitter) throws {
    printProcessingLine(context, value: value, emit: emit)
}

private func handleTag(_ context: HandlerContext,
                       _ value: String,
                       emit: DemoEmitter) throws {
    printProcessingLine(context, value: value, emit: emit)
}

private func handleBuildProfile(_ context: HandlerContext, _ value: String) throws {}
private func handleBuildClean(_ context: HandlerContext) throws {}
private func handleVerbose(_ context: HandlerContext) throws {}
private func handleOutput(_ context: HandlerContext, _ value: String) throws {}
private func handleArgs(_ context: HandlerContext) throws {}
