import Foundation

func runParse(_ parser: Parser, _ arguments: [String], io: ParserIO) throws {
    var runner = ParserRunner(parser: parser, arguments: arguments, io: io)
    try runner.run()
}

private struct ParserRunner {
    let parser: Parser
    let io: ParserIO
    var tokens: [String]
    var consumed: [Bool]
    var invocations: [Invocation] = []
    var cursor = 1

    init(parser: Parser, arguments: [String], io: ParserIO) {
        self.parser = parser
        self.io = io
        self.tokens = arguments
        self.consumed = Array(repeating: false, count: arguments.count)
    }

    mutating func run() throws {
        guard !tokens.isEmpty else {
            return
        }

        while cursor < tokens.count {
            try handleCurrentToken()
        }

        schedulePositionals(parser,
                            tokens: tokens,
                            consumed: &consumed,
                            invocations: &invocations)
        try validateRemainingTokens()
        try executeInvocations(invocations, io: io)
    }

    private mutating func handleCurrentToken() throws {
        guard !consumed[cursor] else {
            cursor += 1
            return
        }

        var token = tokens[cursor]
        guard !token.isEmpty else {
            cursor += 1
            return
        }

        let alias = rewrittenAliasBinding(for: &token)

        guard token.first == "-" else {
            cursor += 1
            return
        }

        guard token != "--" else {
            cursor += 1
            return
        }

        guard token.hasPrefix("--") else {
            cursor += 1
            return
        }

        let inlineMatch = inlineMatch(in: parser.inlineParsers, for: token)
        switch inlineMatch.kind {
        case .bareRoot:
            try scheduleBareRoot(token: token, inlineMatch: inlineMatch, aliasBinding: alias)
        case .dashOption:
            try scheduleInlineCommand(token: token, inlineMatch: inlineMatch, aliasBinding: alias)
        case .none:
            try scheduleTopLevelCommand(token: token, aliasBinding: alias)
        }
    }

    private mutating func rewrittenAliasBinding(for token: inout String) -> AliasBinding? {
        guard token.first == "-", !token.hasPrefix("--"),
              let aliasBinding = aliasBinding(in: parser.aliases, matching: token) else {
            return nil
        }

        token = aliasBinding.targetToken
        tokens[cursor] = token
        return aliasBinding
    }

    private mutating func scheduleBareRoot(token: String,
                                           inlineMatch: InlineTokenMatch,
                                           aliasBinding: AliasBinding?) throws {
        guard let inlineParser = inlineMatch.parser else {
            cursor += 1
            return
        }

        consumeIndex(&consumed, cursor)
        let collected = collectValueTokens(optionIndex: cursor,
                                           tokens: tokens,
                                           consumed: &consumed,
                                           allowOptionLikeFirstValue: false)

        if !collected.hasValue && !aliasHasPresetTokens(aliasBinding) {
            invocations.append(.printHelp(root: inlineParser.rootName,
                                          helpRows: buildHelpRows(for: inlineParser)))
            cursor += 1
            return
        }

        guard let rootHandler = inlineParser.rootValueHandler else {
            throw CliError(option: token, message: "unknown value for option '\(token)'")
        }

        let context = HandlerContext(root: inlineParser.rootName,
                                     option: token,
                                     command: "",
                                     valueTokens: effectiveValueTokens(from: aliasBinding,
                                                                      collected.parts))
        invocations.append(.value(context: context, handler: rootHandler))
        cursor = collected.hasValue ? (collected.lastIndex + 1) : (cursor + 1)
    }

    private mutating func scheduleInlineCommand(token: String,
                                                inlineMatch: InlineTokenMatch,
                                                aliasBinding: AliasBinding?) throws {
        guard let inlineParser = inlineMatch.parser,
              !inlineMatch.suffix.isEmpty,
              let binding = commandBinding(in: inlineParser.commands, matching: inlineMatch.suffix) else {
            cursor += 1
            return
        }

        cursor = try schedule(binding,
                              aliasBinding: aliasBinding,
                              root: inlineParser.rootName,
                              command: inlineMatch.suffix,
                              optionToken: token,
                              currentIndex: cursor,
                              tokens: tokens,
                              consumed: &consumed,
                              invocations: &invocations) + 1
    }

    private mutating func scheduleTopLevelCommand(token: String,
                                                  aliasBinding: AliasBinding?) throws {
        let command = String(token.dropFirst(2))
        guard let binding = commandBinding(in: parser.commands, matching: command) else {
            cursor += 1
            return
        }

        cursor = try schedule(binding,
                              aliasBinding: aliasBinding,
                              root: "",
                              command: command,
                              optionToken: token,
                              currentIndex: cursor,
                              tokens: tokens,
                              consumed: &consumed,
                              invocations: &invocations) + 1
    }

    private func validateRemainingTokens() throws {
        for index in tokens.indices.dropFirst() where !consumed[index] {
            let token = tokens[index]
            guard !token.isEmpty else {
                continue
            }
            if token.first == "-" {
                throw CliError(option: token, message: "unknown option \(token)")
            }
        }
    }
}

func schedule(_ binding: CommandBinding,
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
        if aliasHasPresetTokens(aliasBinding) {
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

        if !collected.hasValue && !aliasHasPresetTokens(aliasBinding) && arity == .required {
            throw CliError(option: optionToken,
                           message: "option '\(optionToken)' requires a value")
        }

        let context = HandlerContext(root: root,
                                     option: optionToken,
                                     command: command,
                                     valueTokens: effectiveValueTokens(from: aliasBinding,
                                                                      collected.parts))
        invocations.append(.value(context: context, handler: handler))
        return collected.hasValue ? collected.lastIndex : currentIndex
    }
}

func schedulePositionals(_ parser: Parser,
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

func executeInvocations(_ invocations: [Invocation], io: ParserIO) throws {
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

func collectValueTokens(optionIndex: Int,
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

func inlineMatch(in inlineParsers: [InlineParser], for arg: String) -> InlineTokenMatch {
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

func commandBinding(in commands: [(String, CommandBinding)], matching command: String) -> CommandBinding? {
    commands.first(where: { $0.0 == command })?.1
}

func aliasBinding(in aliases: [AliasBinding], matching token: String) -> AliasBinding? {
    aliases.first(where: { $0.alias == token })
}

func consumeIndex(_ consumed: inout [Bool], _ index: Int) {
    guard index >= 0 && index < consumed.count else {
        return
    }
    consumed[index] = true
}

func effectiveValueTokens(from aliasBinding: AliasBinding?,
                          _ collectedParts: [String]) -> [String] {
    guard let aliasBinding, !aliasBinding.presetTokens.isEmpty else {
        return collectedParts
    }
    return aliasBinding.presetTokens + collectedParts
}

func aliasHasPresetTokens(_ aliasBinding: AliasBinding?) -> Bool {
    !(aliasBinding?.presetTokens.isEmpty ?? true)
}

func formatOptionErrorMessage(_ option: String, _ message: String) -> String {
    if option.isEmpty {
        return message
    }
    return "option '\(option)': \(message)"
}

func flagBinding(_ handler: @escaping FlagHandler,
                 description: String) throws -> CommandBinding {
    CommandBinding(handler: .flag(handler),
                   description: try normalizedDescription(description))
}

func valueBinding(_ handler: @escaping ValueHandler,
                  description: String,
                  arity: ValueArity) throws -> CommandBinding {
    CommandBinding(handler: .value(handler, arity),
                   description: try normalizedDescription(description))
}

func upsertCommandBinding(_ commands: inout [(String, CommandBinding)],
                         command: String,
                         binding: CommandBinding) throws {
    if let index = commands.firstIndex(where: { $0.0 == command }) {
        commands[index] = (command, binding)
        return
    }
    commands.append((command, binding))
}

func describe(_ error: Error) -> String {
    if let localized = error as? LocalizedError, let message = localized.errorDescription {
        return message
    }
    return String(describing: error)
}
