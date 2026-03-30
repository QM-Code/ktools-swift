import Foundation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

public final class Parser {
    var positionalHandler: PositionalHandler?
    var aliases: [AliasBinding] = []
    var commands: [(String, CommandBinding)] = []
    var inlineParsers: [InlineParser] = []
    internal var io = ParserIO.standard

    public init() {}

    public func addAlias(_ alias: String,
                         target: String,
                         presetTokens: [String] = []) throws {
        let normalizedAlias = try normalizedAlias(alias)
        let normalizedTarget = try normalizedAliasTargetOption(target)
        let binding = AliasBinding(alias: normalizedAlias,
                                   targetToken: normalizedTarget,
                                   presetTokens: presetTokens)
        if let index = aliases.firstIndex(where: { $0.alias == normalizedAlias }) {
            aliases[index] = binding
            return
        }
        aliases.append(binding)
    }

    public func setHandler(_ option: String,
                           handler: @escaping FlagHandler,
                           description: String) throws {
        let command = try normalizedPrimaryHandlerOption(option)
        try upsertCommandBinding(&commands,
                                 command: command,
                                 binding: flagBinding(handler, description: description))
    }

    public func setHandler(_ option: String,
                           handler: @escaping ValueHandler,
                           description: String) throws {
        let command = try normalizedPrimaryHandlerOption(option)
        try upsertCommandBinding(&commands,
                                 command: command,
                                 binding: valueBinding(handler,
                                                       description: description,
                                                       arity: .required))
    }

    public func setOptionalValueHandler(_ option: String,
                                        handler: @escaping ValueHandler,
                                        description: String) throws {
        let command = try normalizedPrimaryHandlerOption(option)
        try upsertCommandBinding(&commands,
                                 command: command,
                                 binding: valueBinding(handler,
                                                       description: description,
                                                       arity: .optional))
    }

    public func setPositionalHandler(_ handler: @escaping PositionalHandler) throws {
        positionalHandler = handler
    }

    public func addInlineParser(_ parser: InlineParser) throws {
        if inlineParsers.contains(where: { $0.rootName == parser.rootName }) {
            throw CliConfigurationError("kcli inline parser root '--\(parser.rootName)' is already registered")
        }
        inlineParsers.append(parser)
    }

    public func parseOrExit(_ arguments: [String] = CommandLine.arguments) {
        do {
            try parse(arguments)
        } catch let error as CliError {
            io.stderr("[error] [cli] \(error.message)\n")
            exit(2)
        } catch {
            io.stderr("[error] [cli] \(String(describing: error))\n")
            exit(2)
        }
    }

    public func parse(_ arguments: [String] = CommandLine.arguments) throws {
        try runParse(self, arguments, io: io)
    }
}

internal struct ParserIO {
    var stdout: (String) -> Void
    var stderr: (String) -> Void

    static let standard = ParserIO(
        stdout: { message in
            FileHandle.standardOutput.write(Data(message.utf8))
        },
        stderr: { message in
            FileHandle.standardError.write(Data(message.utf8))
        }
    )
}
