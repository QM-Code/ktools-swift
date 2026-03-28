import Foundation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

public struct HandlerContext: Equatable {
    public var root: String
    public var option: String
    public var command: String
    public var valueTokens: [String]

    public init(root: String = "",
                option: String = "",
                command: String = "",
                valueTokens: [String] = []) {
        self.root = root
        self.option = option
        self.command = command
        self.valueTokens = valueTokens
    }
}

public typealias FlagHandler = (HandlerContext) throws -> Void
public typealias ValueHandler = (HandlerContext, String) throws -> Void
public typealias PositionalHandler = (HandlerContext) throws -> Void

public struct CliConfigurationError: Error, CustomStringConvertible, LocalizedError, Equatable {
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

public struct CliError: Error, CustomStringConvertible, LocalizedError, Equatable {
    private let optionToken: String
    public let message: String

    public init(option: String = "", message: String) {
        self.optionToken = option
        self.message = message.isEmpty ? "kcli parse failed" : message
    }

    public func option() -> String {
        optionToken
    }

    public var description: String {
        message
    }

    public var errorDescription: String? {
        message
    }
}

public struct InlineParser {
    fileprivate var rootName: String
    fileprivate var rootValueHandler: ValueHandler?
    fileprivate var rootValuePlaceholder = ""
    fileprivate var rootValueDescription = ""
    fileprivate var commands: [(String, CommandBinding)] = []

    public init(_ root: String) throws {
        rootName = try normalizeInlineRootOptionOrThrow(root)
    }

    public mutating func setRoot(_ root: String) throws {
        rootName = try normalizeInlineRootOptionOrThrow(root)
    }

    public mutating func setRootValueHandler(_ handler: @escaping ValueHandler) throws {
        rootValueHandler = handler
        rootValuePlaceholder = ""
        rootValueDescription = ""
    }

    public mutating func setRootValueHandler(_ handler: @escaping ValueHandler,
                                             valuePlaceholder: String,
                                             description: String) throws {
        rootValueHandler = handler
        rootValuePlaceholder = try normalizeHelpPlaceholderOrThrow(valuePlaceholder)
        rootValueDescription = try normalizeDescriptionOrThrow(description)
    }

    public mutating func setHandler(_ option: String,
                                    handler: @escaping FlagHandler,
                                    description: String) throws {
        let command = try normalizeInlineHandlerOptionOrThrow(option, rootName: rootName)
        try upsertCommand(&commands,
                          command: command,
                          binding: makeFlagBinding(handler, description: description))
    }

    public mutating func setHandler(_ option: String,
                                    handler: @escaping ValueHandler,
                                    description: String) throws {
        let command = try normalizeInlineHandlerOptionOrThrow(option, rootName: rootName)
        try upsertCommand(&commands,
                          command: command,
                          binding: makeValueBinding(handler,
                                                    description: description,
                                                    arity: .required))
    }

    public mutating func setOptionalValueHandler(_ option: String,
                                                 handler: @escaping ValueHandler,
                                                 description: String) throws {
        let command = try normalizeInlineHandlerOptionOrThrow(option, rootName: rootName)
        try upsertCommand(&commands,
                          command: command,
                          binding: makeValueBinding(handler,
                                                    description: description,
                                                    arity: .optional))
    }
}

public final class Parser {
    fileprivate var positionalHandler: PositionalHandler?
    fileprivate var aliases: [AliasBinding] = []
    fileprivate var commands: [(String, CommandBinding)] = []
    fileprivate var inlineParsers: [InlineParser] = []
    internal var io = ParserIO.standard

    public init() {}

    public func addAlias(_ alias: String,
                         target: String,
                         presetTokens: [String] = []) throws {
        let normalizedAlias = try normalizeAliasOrThrow(alias)
        let normalizedTarget = try normalizeAliasTargetOptionOrThrow(target)
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
        let command = try normalizePrimaryHandlerOptionOrThrow(option)
        try upsertCommand(&commands,
                          command: command,
                          binding: makeFlagBinding(handler, description: description))
    }

    public func setHandler(_ option: String,
                           handler: @escaping ValueHandler,
                           description: String) throws {
        let command = try normalizePrimaryHandlerOptionOrThrow(option)
        try upsertCommand(&commands,
                          command: command,
                          binding: makeValueBinding(handler,
                                                    description: description,
                                                    arity: .required))
    }

    public func setOptionalValueHandler(_ option: String,
                                        handler: @escaping ValueHandler,
                                        description: String) throws {
        let command = try normalizePrimaryHandlerOptionOrThrow(option)
        try upsertCommand(&commands,
                          command: command,
                          binding: makeValueBinding(handler,
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
            try parseOrThrow(arguments)
        } catch let error as CliError {
            io.stderr("[error] [cli] \(error.message)\n")
            exit(2)
        } catch {
            io.stderr("[error] [cli] \(String(describing: error))\n")
            exit(2)
        }
    }

    public func parseOrThrow(_ arguments: [String]) throws {
        try parse(self, arguments, io: io)
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

private enum ValueArity {
    case required
    case optional
}

private enum RegisteredHandler {
    case flag(FlagHandler)
    case value(ValueHandler, ValueArity)
}

private struct CommandBinding {
    let handler: RegisteredHandler
    let description: String
}

private struct AliasBinding {
    let alias: String
    let targetToken: String
    let presetTokens: [String]
}

private typealias HelpRow = (String, String)

private enum Invocation {
    case flag(context: HandlerContext, handler: FlagHandler)
    case value(context: HandlerContext, handler: ValueHandler)
    case positional(context: HandlerContext, handler: PositionalHandler)
    case printHelp(root: String, helpRows: [HelpRow])
}

private struct CollectedValues {
    var hasValue = false
    var parts: [String] = []
    var lastIndex: Int
}

private enum InlineTokenMatchKind {
    case none
    case bareRoot
    case dashOption
}

private struct InlineTokenMatch {
    var kind: InlineTokenMatchKind = .none
    var parser: InlineParser?
    var suffix = ""
}

private func parse(_ parser: Parser, _ arguments: [String], io: ParserIO) throws {
    if arguments.isEmpty {
        return
    }

    var consumed = Array(repeating: false, count: arguments.count)
    var invocations: [Invocation] = []
    var tokens = arguments

    var index = 1
    while index < tokens.count {
        if consumed[index] {
            index += 1
            continue
        }

        var arg = tokens[index]
        if arg.isEmpty {
            index += 1
            continue
        }

        var aliasBinding: AliasBinding?
        if arg.first == "-", !arg.hasPrefix("--") {
            aliasBinding = findAliasBinding(in: parser.aliases, token: arg)
            if let aliasBinding {
                arg = aliasBinding.targetToken
                tokens[index] = arg
            }
        }

        guard arg.first == "-" else {
            index += 1
            continue
        }

        if arg == "--" {
            index += 1
            continue
        }

        if arg.hasPrefix("--") {
            let inlineMatch = matchInlineToken(in: parser.inlineParsers, arg: arg)
            switch inlineMatch.kind {
            case .bareRoot:
                guard let inlineParser = inlineMatch.parser else {
                    break
                }

                consumeIndex(&consumed, index)
                let collected = collectValueTokens(optionIndex: index,
                                                   tokens: tokens,
                                                   consumed: &consumed,
                                                   allowOptionLikeFirstValue: false)

                if !collected.hasValue && !hasAliasPresetTokens(aliasBinding) {
                    invocations.append(.printHelp(root: inlineParser.rootName,
                                                  helpRows: buildHelpRows(for: inlineParser)))
                    index += 1
                    continue
                }

                guard let rootHandler = inlineParser.rootValueHandler else {
                    throw CliError(option: arg, message: "unknown value for option '\(arg)'")
                }

                let context = HandlerContext(root: inlineParser.rootName,
                                             option: arg,
                                             command: "",
                                             valueTokens: buildEffectiveValueTokens(aliasBinding,
                                                                                   collected.parts))
                invocations.append(.value(context: context, handler: rootHandler))

                index = collected.hasValue ? (collected.lastIndex + 1) : (index + 1)
                continue

            case .dashOption:
                if let inlineParser = inlineMatch.parser,
                   !inlineMatch.suffix.isEmpty,
                   let binding = findCommand(in: inlineParser.commands, command: inlineMatch.suffix) {
                    index = try scheduleInvocation(binding,
                                                   aliasBinding: aliasBinding,
                                                   root: inlineParser.rootName,
                                                   command: inlineMatch.suffix,
                                                   optionToken: arg,
                                                   currentIndex: index,
                                                   tokens: tokens,
                                                   consumed: &consumed,
                                                   invocations: &invocations) + 1
                    continue
                }

            case .none:
                let command = String(arg.dropFirst(2))
                if let binding = findCommand(in: parser.commands, command: command) {
                    index = try scheduleInvocation(binding,
                                                   aliasBinding: aliasBinding,
                                                   root: "",
                                                   command: command,
                                                   optionToken: arg,
                                                   currentIndex: index,
                                                   tokens: tokens,
                                                   consumed: &consumed,
                                                   invocations: &invocations) + 1
                    continue
                }
            }
        }

        index += 1
    }

    schedulePositionals(parser,
                        tokens: tokens,
                        consumed: &consumed,
                        invocations: &invocations)

    for index in 1..<tokens.count where !consumed[index] {
        let token = tokens[index]
        if token.isEmpty {
            continue
        }
        if token.first == "-" {
            throw CliError(option: token, message: "unknown option \(token)")
        }
    }

    try executeInvocations(invocations, io: io)
}

private func scheduleInvocation(_ binding: CommandBinding,
                                aliasBinding: AliasBinding?,
                                root: String,
                                command: String,
                                optionToken: String,
                                currentIndex: Int,
                                tokens: [String],
                                consumed: inout [Bool],
                                invocations: inout [Invocation]) throws -> Int {
    consumeIndex(&consumed, currentIndex)

    switch binding.handler {
    case .flag(let handler):
        if hasAliasPresetTokens(aliasBinding) {
            throw CliError(option: aliasBinding?.alias ?? optionToken,
                           message: "alias '\(aliasBinding?.alias ?? "")' presets values for option '\(optionToken)' which does not accept values")
        }

        let context = HandlerContext(root: root,
                                     option: optionToken,
                                     command: command,
                                     valueTokens: [])
        invocations.append(.flag(context: context, handler: handler))
        return currentIndex

    case .value(let handler, let arity):
        let collected = collectValueTokens(optionIndex: currentIndex,
                                           tokens: tokens,
                                           consumed: &consumed,
                                           allowOptionLikeFirstValue: arity == .required)

        if !collected.hasValue && !hasAliasPresetTokens(aliasBinding) && arity == .required {
            throw CliError(option: optionToken,
                           message: "option '\(optionToken)' requires a value")
        }

        let context = HandlerContext(root: root,
                                     option: optionToken,
                                     command: command,
                                     valueTokens: buildEffectiveValueTokens(aliasBinding,
                                                                           collected.parts))
        invocations.append(.value(context: context, handler: handler))
        return collected.hasValue ? collected.lastIndex : currentIndex
    }
}

private func schedulePositionals(_ parser: Parser,
                                 tokens: [String],
                                 consumed: inout [Bool],
                                 invocations: inout [Invocation]) {
    guard let positionalHandler = parser.positionalHandler, tokens.count > 1 else {
        return
    }

    var values: [String] = []
    for index in 1..<tokens.count where !consumed[index] {
        let token = tokens[index]
        if token.isEmpty || token.first != "-" {
            consumed[index] = true
            values.append(token)
        }
    }

    if !values.isEmpty {
        invocations.append(.positional(context: HandlerContext(valueTokens: values),
                                       handler: positionalHandler))
    }
}

private func executeInvocations(_ invocations: [Invocation], io: ParserIO) throws {
    for invocation in invocations {
        switch invocation {
        case .printHelp(let root, let helpRows):
            printHelp(root: root, helpRows: helpRows, io: io)

        case .flag(let context, let handler):
            do {
                try handler(context)
            } catch let error as CliError {
                throw CliError(option: context.option,
                               message: formatOptionErrorMessage(context.option,
                                                                 error.message))
            } catch {
                throw CliError(option: context.option,
                               message: formatOptionErrorMessage(context.option,
                                                                 describe(error)))
            }

        case .value(let context, let handler):
            let value = context.valueTokens.joined(separator: " ")
            do {
                try handler(context, value)
            } catch let error as CliError {
                throw CliError(option: context.option,
                               message: formatOptionErrorMessage(context.option,
                                                                 error.message))
            } catch {
                throw CliError(option: context.option,
                               message: formatOptionErrorMessage(context.option,
                                                                 describe(error)))
            }

        case .positional(let context, let handler):
            do {
                try handler(context)
            } catch let error as CliError {
                throw CliError(option: context.option,
                               message: formatOptionErrorMessage(context.option,
                                                                 error.message))
            } catch {
                throw CliError(option: context.option,
                               message: formatOptionErrorMessage(context.option,
                                                                 describe(error)))
            }
        }
    }
}

private func printHelp(root: String, helpRows: [HelpRow], io: ParserIO) {
    io.stdout("\nAvailable --\(root)-* options:\n")

    let maxLeftWidth = helpRows.map(\.0.count).max() ?? 0
    if helpRows.isEmpty {
        io.stdout("  (no options registered)\n")
        io.stdout("\n")
        return
    }

    for row in helpRows {
        let padding = max(0, maxLeftWidth - row.0.count) + 2
        io.stdout("  \(row.0)\(String(repeating: " ", count: padding))\(row.1)\n")
    }
    io.stdout("\n")
}

private func buildHelpRows(for parser: InlineParser) -> [HelpRow] {
    var rows: [HelpRow] = []
    if parser.rootValueHandler != nil && !parser.rootValueDescription.isEmpty {
        var lhs = "--\(parser.rootName)"
        if !parser.rootValuePlaceholder.isEmpty {
            lhs += " \(parser.rootValuePlaceholder)"
        }
        rows.append((lhs, parser.rootValueDescription))
    }

    for (command, binding) in parser.commands {
        var lhs = "--\(parser.rootName)-\(command)"
        switch binding.handler {
        case .flag:
            break
        case .value(_, let arity):
            lhs += (arity == .optional) ? " [value]" : " <value>"
        }
        rows.append((lhs, binding.description))
    }
    return rows
}

private func collectValueTokens(optionIndex: Int,
                                tokens: [String],
                                consumed: inout [Bool],
                                allowOptionLikeFirstValue: Bool) -> CollectedValues {
    var collected = CollectedValues(lastIndex: optionIndex)
    let firstValueIndex = optionIndex + 1

    guard firstValueIndex < tokens.count, !consumed[firstValueIndex] else {
        return collected
    }

    let first = tokens[firstValueIndex]
    if !allowOptionLikeFirstValue && first.hasPrefix("-") {
        return collected
    }

    collected.hasValue = true
    collected.parts.append(first)
    consumed[firstValueIndex] = true
    collected.lastIndex = firstValueIndex

    if allowOptionLikeFirstValue && first.hasPrefix("-") {
        return collected
    }

    var scan = firstValueIndex + 1
    while scan < tokens.count {
        if consumed[scan] {
            scan += 1
            continue
        }

        let next = tokens[scan]
        if next.hasPrefix("-") {
            break
        }

        collected.parts.append(next)
        consumed[scan] = true
        collected.lastIndex = scan
        scan += 1
    }

    return collected
}

private func matchInlineToken(in inlineParsers: [InlineParser], arg: String) -> InlineTokenMatch {
    for parser in inlineParsers {
        let rootOption = "--\(parser.rootName)"
        if arg == rootOption {
            return InlineTokenMatch(kind: .bareRoot, parser: parser)
        }

        let prefix = "\(rootOption)-"
        if arg.hasPrefix(prefix) {
            return InlineTokenMatch(kind: .dashOption,
                                    parser: parser,
                                    suffix: String(arg.dropFirst(prefix.count)))
        }
    }
    return InlineTokenMatch()
}

private func findCommand(in commands: [(String, CommandBinding)], command: String) -> CommandBinding? {
    commands.first(where: { $0.0 == command })?.1
}

private func findAliasBinding(in aliases: [AliasBinding], token: String) -> AliasBinding? {
    aliases.first(where: { $0.alias == token })
}

private func consumeIndex(_ consumed: inout [Bool], _ index: Int) {
    guard index >= 0 && index < consumed.count else {
        return
    }
    consumed[index] = true
}

private func buildEffectiveValueTokens(_ aliasBinding: AliasBinding?,
                                       _ collectedParts: [String]) -> [String] {
    guard let aliasBinding, !aliasBinding.presetTokens.isEmpty else {
        return collectedParts
    }
    return aliasBinding.presetTokens + collectedParts
}

private func hasAliasPresetTokens(_ aliasBinding: AliasBinding?) -> Bool {
    !(aliasBinding?.presetTokens.isEmpty ?? true)
}

private func formatOptionErrorMessage(_ option: String, _ message: String) -> String {
    if option.isEmpty {
        return message
    }
    return "option '\(option)': \(message)"
}

private func makeFlagBinding(_ handler: @escaping FlagHandler,
                             description: String) throws -> CommandBinding {
    return CommandBinding(handler: .flag(handler),
                          description: try normalizeDescriptionOrThrow(description))
}

private func makeValueBinding(_ handler: @escaping ValueHandler,
                              description: String,
                              arity: ValueArity) throws -> CommandBinding {
    return CommandBinding(handler: .value(handler, arity),
                          description: try normalizeDescriptionOrThrow(description))
}

private func upsertCommand(_ commands: inout [(String, CommandBinding)],
                           command: String,
                           binding: CommandBinding) throws {
    if let index = commands.firstIndex(where: { $0.0 == command }) {
        commands[index] = (command, binding)
        return
    }
    commands.append((command, binding))
}

private func trimWhitespace(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines)
}

private func containsWhitespace(_ value: String) -> Bool {
    value.unicodeScalars.contains { CharacterSet.whitespacesAndNewlines.contains($0) }
}

private func startsWith(_ value: String, prefix: String) -> Bool {
    value.hasPrefix(prefix)
}

private func normalizeRootNameOrThrow(_ rawRoot: String) throws -> String {
    let root = trimWhitespace(rawRoot)
    if root.isEmpty {
        throw CliConfigurationError("kcli root must not be empty")
    }
    if root.first == "-" {
        throw CliConfigurationError("kcli root must not begin with '-'")
    }
    if containsWhitespace(root) {
        throw CliConfigurationError("kcli root is invalid")
    }
    return root
}

private func normalizeInlineRootOptionOrThrow(_ rawRoot: String) throws -> String {
    var root = trimWhitespace(rawRoot)
    if root.isEmpty {
        throw CliConfigurationError("kcli root must not be empty")
    }
    if startsWith(root, prefix: "--") {
        root.removeFirst(2)
    } else if root.first == "-" {
        throw CliConfigurationError("kcli root must use '--root' or 'root'")
    }
    return try normalizeRootNameOrThrow(root)
}

private func normalizeInlineHandlerOptionOrThrow(_ rawOption: String,
                                                 rootName: String) throws -> String {
    var option = trimWhitespace(rawOption)
    if option.isEmpty {
        throw CliConfigurationError("kcli inline handler option must not be empty")
    }

    if startsWith(option, prefix: "--") {
        let fullPrefix = "--\(rootName)-"
        if !startsWith(option, prefix: fullPrefix) {
            throw CliConfigurationError("kcli inline handler option must use '-name' or '\(fullPrefix)name'")
        }
        option.removeFirst(fullPrefix.count)
    } else if option.first == "-" {
        option.removeFirst()
    } else {
        throw CliConfigurationError("kcli inline handler option must use '-name' or '--\(rootName)-name'")
    }

    if option.isEmpty {
        throw CliConfigurationError("kcli command must not be empty")
    }
    if option.first == "-" {
        throw CliConfigurationError("kcli command must not start with '-'")
    }
    if containsWhitespace(option) {
        throw CliConfigurationError("kcli command must not contain whitespace")
    }
    return option
}

private func normalizePrimaryHandlerOptionOrThrow(_ rawOption: String) throws -> String {
    var option = trimWhitespace(rawOption)
    if option.isEmpty {
        throw CliConfigurationError("kcli end-user handler option must not be empty")
    }

    if startsWith(option, prefix: "--") {
        option.removeFirst(2)
    } else if option.first == "-" {
        throw CliConfigurationError("kcli end-user handler option must use '--name' or 'name'")
    }

    if option.isEmpty {
        throw CliConfigurationError("kcli command must not be empty")
    }
    if option.first == "-" {
        throw CliConfigurationError("kcli command must not start with '-'")
    }
    if containsWhitespace(option) {
        throw CliConfigurationError("kcli command must not contain whitespace")
    }
    return option
}

private func normalizeAliasOrThrow(_ rawAlias: String) throws -> String {
    let alias = trimWhitespace(rawAlias)
    if alias.count < 2 || alias.first != "-" || startsWith(alias, prefix: "--") || containsWhitespace(alias) {
        throw CliConfigurationError("kcli alias must use single-dash form, e.g. '-v'")
    }
    return alias
}

private func normalizeAliasTargetOptionOrThrow(_ rawTarget: String) throws -> String {
    let target = trimWhitespace(rawTarget)
    if target.count < 3 || !startsWith(target, prefix: "--") || containsWhitespace(target) {
        throw CliConfigurationError("kcli alias target must use double-dash form, e.g. '--verbose'")
    }
    let index = target.index(target.startIndex, offsetBy: 2)
    if target[index] == "-" {
        throw CliConfigurationError("kcli alias target must use double-dash form, e.g. '--verbose'")
    }
    return target
}

private func normalizeHelpPlaceholderOrThrow(_ rawPlaceholder: String) throws -> String {
    let placeholder = trimWhitespace(rawPlaceholder)
    if placeholder.isEmpty {
        throw CliConfigurationError("kcli help placeholder must not be empty")
    }
    return placeholder
}

private func normalizeDescriptionOrThrow(_ rawDescription: String) throws -> String {
    let description = trimWhitespace(rawDescription)
    if description.isEmpty {
        throw CliConfigurationError("kcli command description must not be empty")
    }
    return description
}

private func describe(_ error: Error) -> String {
    if let localized = error as? LocalizedError, let message = localized.errorDescription {
        return message
    }
    return String(describing: error)
}
