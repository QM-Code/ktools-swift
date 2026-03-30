import Foundation
import Kcli

public typealias TraceEmitter = (String) -> Void

public struct OutputOptions: Equatable {
    public var filenames: Bool
    public var lineNumbers: Bool
    public var functionNames: Bool
    public var timestamps: Bool

    public init(_ filenames: Bool = false,
                _ lineNumbers: Bool = false,
                _ functionNames: Bool = false,
                _ timestamps: Bool = false) {
        self.filenames = filenames
        self.lineNumbers = filenames && lineNumbers
        self.functionNames = filenames && functionNames
        self.timestamps = timestamps
    }
}

public struct TraceConfigurationError: Error, CustomStringConvertible, LocalizedError, Equatable {
    public let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var description: String { message }
    public var errorDescription: String? { message }
}

public struct TraceRuntimeError: Error, CustomStringConvertible, LocalizedError, Equatable {
    public let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var description: String { message }
    public var errorDescription: String? { message }
}

public enum TraceColors {
    public static let defaultColor = 0xFFFF

    private static let palette = [
        "Black",
        "Red",
        "Green",
        "Yellow",
        "Blue",
        "Magenta",
        "Cyan",
        "White",
        "BrightBlack",
        "BrightRed",
        "BrightGreen",
        "BrightYellow",
        "BrightBlue",
        "BrightMagenta",
        "BrightCyan",
        "BrightWhite",
        "DeepSkyBlue1",
        "Gold3",
        "MediumSpringGreen",
        "Orange3",
        "MediumOrchid1",
        "LightSkyBlue1",
        "LightSalmon1",
    ]

    public static func named(_ colorName: String) throws -> Int {
        let token = trimWhitespace(colorName)
        if token.isEmpty {
            throw TraceConfigurationError("trace color name must not be empty")
        }
        if token == "Default" || token == "default" {
            return defaultColor
        }
        guard let index = palette.firstIndex(of: token) else {
            throw TraceConfigurationError("unknown trace color '\(token)'")
        }
        return index
    }

    public static var names: [String] {
        palette
    }
}

public func defaultTraceEmit(_ text: String) {
    print(text, terminator: "")
}

struct ChannelSpec {
    let name: String
    var color: Int
}

private struct TraceLoggerState {
    var channels: [ChannelSpec] = []
    var changedKeys: [String: String] = [:]
}

final class TraceLoggerStorage {
    let traceNamespace: String
    private let state = LockedState(TraceLoggerState())
    weak var attachedLogger: LoggerStorage?

    init(traceNamespace: String) {
        self.traceNamespace = traceNamespace
    }

    fileprivate func withState<T>(_ body: (inout TraceLoggerState) throws -> T) rethrows -> T {
        try state.withValue(body)
    }

    fileprivate func readState<T>(_ body: (TraceLoggerState) throws -> T) rethrows -> T {
        try state.read(body)
    }
}

private struct LoggerRegistry {
    var namespaces: Set<String> = []
    var channelsByNamespace: [String: [String]] = [:]
    var colorsByNamespace: [String: [String: Int]] = [:]
}

private struct LoggerOutputState {
    var emit: TraceEmitter
    var options = OutputOptions()
}

final class LoggerStorage {
    private let registry = LockedState(LoggerRegistry())
    private let enabledChannels = LockedState(Set<String>())
    private let output: LockedState<LoggerOutputState>

    init(output: @escaping TraceEmitter) {
        self.output = LockedState(LoggerOutputState(emit: output))
    }

    fileprivate func withRegistry<T>(_ body: (inout LoggerRegistry) throws -> T) rethrows -> T {
        try registry.withValue(body)
    }

    fileprivate func readRegistry<T>(_ body: (LoggerRegistry) throws -> T) rethrows -> T {
        try registry.read(body)
    }

    func withEnabledChannels<T>(_ body: (inout Set<String>) throws -> T) rethrows -> T {
        try enabledChannels.withValue(body)
    }

    func readEnabledChannels<T>(_ body: (Set<String>) throws -> T) rethrows -> T {
        try enabledChannels.read(body)
    }

    var outputOptions: OutputOptions {
        get {
            output.read { $0.options }
        }
        set {
            let next = OutputOptions(newValue.filenames,
                                     newValue.lineNumbers,
                                     newValue.functionNames,
                                     newValue.timestamps)
            output.withValue { $0.options = next }
        }
    }

    func emit(_ payload: String) {
        output.read { state in
            state.emit(payload)
        }
    }
}

public final class TraceLogger {
    fileprivate let storage: TraceLoggerStorage

    public init(_ traceNamespace: String) throws {
        storage = TraceLoggerStorage(traceNamespace: try normalizeNamespace(traceNamespace))
    }

    public func addChannel(_ channel: String, color: Int = TraceColors.defaultColor) throws {
        let normalizedChannel = try normalizeChannel(channel)
        try storage.withState { state in
            if let separator = normalizedChannel.lastIndex(of: ".") {
                let parent = String(normalizedChannel[..<separator])
                guard state.channels.contains(where: { $0.name == parent }) else {
                    throw TraceConfigurationError(
                        "cannot add unparented trace channel '\(normalizedChannel)' (missing parent '\(parent)')"
                    )
                }
            }

            if let existingIndex = state.channels.firstIndex(where: { $0.name == normalizedChannel }) {
                let merged = try mergeColor(
                    existing: state.channels[existingIndex].color,
                    incoming: color,
                    traceNamespace: storage.traceNamespace,
                    channel: normalizedChannel
                )
                state.channels[existingIndex].color = merged
                return
            }

            if color != TraceColors.defaultColor && !(0...255).contains(color) {
                throw TraceConfigurationError("invalid trace color id '\(color)'")
            }

            state.channels.append(ChannelSpec(name: normalizedChannel, color: color))
        }
    }

    public var namespace: String {
        storage.traceNamespace
    }

    public func shouldTraceChannel(_ channel: String) -> Bool {
        guard let logger = storage.attachedLogger else {
            return false
        }
        guard let normalized = try? normalizeChannel(channel) else {
            return false
        }
        return shouldTrace(logger, traceNamespace: storage.traceNamespace, channel: normalized)
    }

    public func trace(_ channel: String,
                      _ format: String,
                      _ args: Any...,
                      file: String = #fileID,
                      line: Int = #line,
                      function: String = #function) throws {
        guard let logger = storage.attachedLogger else {
            return
        }
        let normalizedChannel = try normalizeChannel(channel)
        guard shouldTrace(logger, traceNamespace: storage.traceNamespace, channel: normalizedChannel) else {
            return
        }
        let message = try formatMessage(format, args)
        emitTrace(logger,
                  traceNamespace: storage.traceNamespace,
                  channel: normalizedChannel,
                  source: SourceContext(file: file, line: line, function: function),
                  message: message)
    }

    public func traceIfChanged(_ channel: String,
                             key keyExpr: Any,
                             _ format: String,
                             _ args: Any...,
                             file: String = #fileID,
                             line: Int = #line,
                             function: String = #function) throws {
        let normalizedChannel = try normalizeChannel(channel)
        let key = String(describing: keyExpr)
        let siteKey = "\(storage.traceNamespace)|\(normalizedChannel)|\(file)|\(line)|\(function)"
        let shouldEmit = storage.withState { state in
            let previous = state.changedKeys[siteKey]
            state.changedKeys[siteKey] = key
            return previous != key
        }
        guard shouldEmit else {
            return
        }
        guard let logger = storage.attachedLogger else {
            return
        }
        guard shouldTrace(logger, traceNamespace: storage.traceNamespace, channel: normalizedChannel) else {
            return
        }
        let message = try formatMessage(format, args)
        emitTrace(logger,
                  traceNamespace: storage.traceNamespace,
                  channel: normalizedChannel,
                  source: SourceContext(file: file, line: line, function: function),
                  message: message)
    }

    public func info(_ format: String,
                     _ args: Any...,
                     file: String = #fileID,
                     line: Int = #line,
                     function: String = #function) throws {
        try log(.info, format, args, file: file, line: line, function: function)
    }

    public func warn(_ format: String,
                     _ args: Any...,
                     file: String = #fileID,
                     line: Int = #line,
                     function: String = #function) throws {
        try log(.warning, format, args, file: file, line: line, function: function)
    }

    public func error(_ format: String,
                      _ args: Any...,
                      file: String = #fileID,
                      line: Int = #line,
                      function: String = #function) throws {
        try log(.error, format, args, file: file, line: line, function: function)
    }

    fileprivate var attachedLogger: LoggerStorage? {
        storage.attachedLogger
    }

    fileprivate var channelSpecs: [ChannelSpec] {
        storage.readState { $0.channels }
    }

    private func log(_ severity: LogSeverity,
                     _ format: String,
                     _ args: [Any],
                     file: String,
                     line: Int,
                     function: String) throws {
        guard let logger = storage.attachedLogger else {
            return
        }
        let message = try formatMessage(format, args)
        emitLog(logger,
                traceNamespace: storage.traceNamespace,
                severity: severity,
                source: SourceContext(file: file, line: line, function: function),
                message: message)
    }
}

public final class Logger {
    private let storage: LoggerStorage
    private let internalTrace: TraceLogger

    public init(output: @escaping TraceEmitter = defaultTraceEmit) {
        storage = LoggerStorage(output: output)
        internalTrace = try! TraceLogger("ktrace")
        try! internalTrace.addChannel("api", color: (try? TraceColors.named("Cyan")) ?? TraceColors.defaultColor)
        try! internalTrace.addChannel("api.channels")
        try! internalTrace.addChannel("api.cli")
        try! internalTrace.addChannel("api.output")
        try! internalTrace.addChannel("selector", color: (try? TraceColors.named("Yellow")) ?? TraceColors.defaultColor)
        try! internalTrace.addChannel("selector.parse")
        try! internalTrace.addChannel("registry", color: (try? TraceColors.named("Magenta")) ?? TraceColors.defaultColor)
        try! internalTrace.addChannel("registry.query")
        try! attach(internalTrace)
    }

    public func attach(_ traceLogger: TraceLogger) throws {
        if let attached = traceLogger.attachedLogger, attached !== storage {
            throw TraceConfigurationError("trace logger is already attached to another logger")
        }

        try storage.withRegistry { registry in
            let traceNamespace = traceLogger.namespace
            registry.namespaces.insert(traceNamespace)
            var registeredChannels = registry.channelsByNamespace[traceNamespace] ?? []
            var registeredColors = registry.colorsByNamespace[traceNamespace] ?? [:]

            for channel in traceLogger.channelSpecs {
                if let separator = channel.name.lastIndex(of: ".") {
                    let parent = String(channel.name[..<separator])
                    guard registeredChannels.contains(parent) else {
                        throw TraceConfigurationError(
                            "cannot register unparented trace channel '\(channel.name)' (missing parent '\(parent)')"
                        )
                    }
                }

                if !registeredChannels.contains(channel.name) {
                    registeredChannels.append(channel.name)
                }

                let existing = registeredColors[channel.name] ?? TraceColors.defaultColor
                let merged = try mergeColor(
                    existing: existing,
                    incoming: channel.color,
                    traceNamespace: traceNamespace,
                    channel: channel.name
                )
                if merged != TraceColors.defaultColor {
                    registeredColors[channel.name] = merged
                }
            }

            registry.channelsByNamespace[traceNamespace] = registeredChannels
            registry.colorsByNamespace[traceNamespace] = registeredColors
            traceLogger.storage.attachedLogger = storage
        }
    }

    public func enableChannel(_ qualifiedChannel: String) throws {
        try enableChannel(qualifiedChannel, localNamespace: "")
    }

    public func enableChannel(_ qualifiedChannel: String, in localTraceLogger: TraceLogger) throws {
        try enableChannel(qualifiedChannel, localNamespace: localTraceLogger.namespace)
    }

    public func enableChannels(_ selectorsCSV: String) throws {
        try enableChannels(selectorsCSV, localNamespace: "")
    }

    public func enableChannels(_ selectorsCSV: String, in localTraceLogger: TraceLogger) throws {
        try enableChannels(selectorsCSV, localNamespace: localTraceLogger.namespace)
    }

    public func shouldTraceChannel(_ qualifiedChannel: String) -> Bool {
        shouldTraceChannel(qualifiedChannel, localNamespace: "")
    }

    public func shouldTraceChannel(_ qualifiedChannel: String, in localTraceLogger: TraceLogger) -> Bool {
        shouldTraceChannel(qualifiedChannel, localNamespace: localTraceLogger.namespace)
    }

    public func disableChannel(_ qualifiedChannel: String) throws {
        try disableChannel(qualifiedChannel, localNamespace: "")
    }

    public func disableChannel(_ qualifiedChannel: String, in localTraceLogger: TraceLogger) throws {
        try disableChannel(qualifiedChannel, localNamespace: localTraceLogger.namespace)
    }

    public func disableChannels(_ selectorsCSV: String) throws {
        try disableChannels(selectorsCSV, localNamespace: "")
    }

    public func disableChannels(_ selectorsCSV: String, in localTraceLogger: TraceLogger) throws {
        try disableChannels(selectorsCSV, localNamespace: localTraceLogger.namespace)
    }

    public var outputOptions: OutputOptions {
        get {
            storage.outputOptions
        }
        set {
            storage.outputOptions = newValue
        }
    }

    public var namespaces: [String] {
        storage.readRegistry { $0.namespaces.sorted() }
    }

    public func channels(in traceNamespace: String) -> [String] {
        guard let normalized = try? normalizeNamespace(traceNamespace) else {
            return []
        }
        return storage.readRegistry { ($0.channelsByNamespace[normalized] ?? []).sorted() }
    }

    public func inlineParser(for localTraceLogger: TraceLogger,
                             root traceRoot: String = "trace") throws -> InlineParser {
        let localNamespace = localTraceLogger.namespace
        var parser = try InlineParser(traceRoot.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "trace" : traceRoot)
        try parser.setRootValueHandler({ _, value in
            try self.enableChannels(value, localNamespace: localNamespace)
        }, valuePlaceholder: "<channels>", description: "Trace selected channels.")
        try parser.setHandler("-examples", handler: { context in
            self.printExamples(optionRoot: "--\(context.root)")
        }, description: "Show selector examples.")
        try parser.setHandler("-namespaces", handler: { _ in
            self.printNamespaces()
        }, description: "Show initialized trace namespaces.")
        try parser.setHandler("-channels", handler: { _ in
            self.printChannels()
        }, description: "Show initialized trace channels.")
        try parser.setHandler("-colors", handler: { _ in
            self.printColors()
        }, description: "Show available trace colors.")
        try parser.setHandler("-files", handler: { _ in
            let options = self.outputOptions
            self.outputOptions = OutputOptions(true, true, false, options.timestamps)
        }, description: "Include source file and line in trace output.")
        try parser.setHandler("-functions", handler: { _ in
            let options = self.outputOptions
            self.outputOptions = OutputOptions(true, true, true, options.timestamps)
        }, description: "Include function names in trace output.")
        try parser.setHandler("-timestamps", handler: { _ in
            let options = self.outputOptions
            self.outputOptions = OutputOptions(options.filenames,
                                               options.lineNumbers,
                                               options.functionNames,
                                               true)
        }, description: "Include timestamps in trace output.")
        return parser
    }

    private func enableChannel(_ qualifiedChannel: String, localNamespace: String) throws {
        let resolution = try resolveExactChannel(qualifiedChannel, localNamespace: localNamespace)
        guard isRegistered(traceNamespace: resolution.traceNamespace, channel: resolution.channel) else {
            try logLocalWarning(
                traceNamespace: localNamespace,
                message: "enable ignored channel '\(resolution.key)' because it is not registered"
            )
            return
        }
        _ = storage.withEnabledChannels { enabledChannels in
            enabledChannels.insert(resolution.key)
        }
    }

    private func enableChannels(_ selectorsCSV: String, localNamespace: String) throws {
        let resolution = try resolveSelectorExpression(selectorsCSV, localNamespace: localNamespace)
        storage.withEnabledChannels { enabledChannels in
            enabledChannels.formUnion(resolution.channelKeys)
        }
        for unmatched in resolution.unmatchedSelectors {
            try logLocalWarning(
                traceNamespace: localNamespace,
                message: "enable ignored channel selector '\(unmatched)' because it matched no registered channels"
            )
        }
    }

    private func shouldTraceChannel(_ qualifiedChannel: String, localNamespace: String) -> Bool {
        guard let resolution = try? resolveExactChannel(qualifiedChannel, localNamespace: localNamespace) else {
            return false
        }
        return shouldTrace(storage, traceNamespace: resolution.traceNamespace, channel: resolution.channel)
    }

    private func disableChannel(_ qualifiedChannel: String, localNamespace: String) throws {
        let resolution = try resolveExactChannel(qualifiedChannel, localNamespace: localNamespace)
        guard isRegistered(traceNamespace: resolution.traceNamespace, channel: resolution.channel) else {
            try logLocalWarning(
                traceNamespace: localNamespace,
                message: "disable ignored channel '\(resolution.key)' because it is not registered"
            )
            return
        }
        _ = storage.withEnabledChannels { enabledChannels in
            enabledChannels.remove(resolution.key)
        }
    }

    private func disableChannels(_ selectorsCSV: String, localNamespace: String) throws {
        let resolution = try resolveSelectorExpression(selectorsCSV, localNamespace: localNamespace)
        storage.withEnabledChannels { enabledChannels in
            enabledChannels.subtract(resolution.channelKeys)
        }
        for unmatched in resolution.unmatchedSelectors {
            try logLocalWarning(
                traceNamespace: localNamespace,
                message: "disable ignored channel selector '\(unmatched)' because it matched no registered channels"
            )
        }
    }

    private func isRegistered(traceNamespace: String, channel: String) -> Bool {
        storage.readRegistry { ($0.channelsByNamespace[traceNamespace] ?? []).contains(channel) }
    }

    private func resolveExactChannel(_ qualifiedChannel: String,
                                     localNamespace: String) throws -> ExactChannelResolution {
        let selector = trimWhitespace(qualifiedChannel)
        if selector == "*" {
            throw TraceConfigurationError("Invalid trace selector: '*' (did you mean '.*'?)")
        }
        guard let dotIndex = selector.firstIndex(of: ".") else {
            throw TraceConfigurationError(
                "invalid channel selector '\(selector)' (expected namespace.channel or .channel; use .channel for local namespace)"
            )
        }

        let namespacePart = dotIndex == selector.startIndex
            ? trimWhitespace(localNamespace)
            : String(selector[..<dotIndex])
        let channelPart = String(selector[selector.index(after: dotIndex)...])
        let normalizedNamespace = try normalizeNamespace(namespacePart)
        let normalizedChannel = try normalizeChannel(channelPart)
        return ExactChannelResolution(
            key: "\(normalizedNamespace).\(normalizedChannel)",
            traceNamespace: normalizedNamespace,
            channel: normalizedChannel
        )
    }

    private func resolveSelectorExpression(_ selectorsCSV: String,
                                           localNamespace: String) throws -> SelectorResolution {
        let selectorText = trimWhitespace(selectorsCSV)
        if selectorText.isEmpty {
            throw TraceConfigurationError("EnableChannels requires one or more selectors")
        }

        let rawSelectors = splitCSV(selectorText)
        if rawSelectors.isEmpty {
            throw TraceConfigurationError("EnableChannels requires one or more selectors")
        }

        var allMatches = Set<String>()
        var unmatched: [String] = []
        let registered = registeredChannelKeys()

        for rawSelector in rawSelectors {
            let token = trimWhitespace(rawSelector)
            if token.isEmpty {
                throw TraceConfigurationError("EnableChannels requires one or more selectors")
            }
            for expanded in try expandBraceSelectors(token) {
                let canonical = try canonicalSelector(expanded, localNamespace: localNamespace)
                let matches = try registered.filter { try selectorMatches(canonical.pattern, candidate: $0) }
                if matches.isEmpty {
                    unmatched.append(canonical.display)
                    continue
                }
                for match in matches {
                    allMatches.insert(match)
                }
            }
        }

        return SelectorResolution(channelKeys: Array(allMatches).sorted(), unmatchedSelectors: unmatched)
    }

    private func registeredChannelKeys() -> [String] {
        storage.readRegistry { registry in
            var keys: [String] = []
            for traceNamespace in registry.namespaces {
                for channel in registry.channelsByNamespace[traceNamespace] ?? [] {
                    keys.append("\(traceNamespace).\(channel)")
                }
            }
            return keys.sorted()
        }
    }

    private func printExamples(optionRoot: String) {
        emit("")
        emit("General trace selector pattern:")
        emit("  \(optionRoot) <namespace>.<channel>[.<subchannel>[.<subchannel>]]")
        emit("")
        emit("Trace selector examples:")
        emit("  \(optionRoot) '.abc'           Select local 'abc' in current namespace")
        emit("  \(optionRoot) '.abc.xyz'       Select local nested channel in current namespace")
        emit("  \(optionRoot) 'otherapp.channel' Select explicit namespace channel")
        emit("  \(optionRoot) '*.*'            Select all <namespace>.<channel> channels")
        emit("  \(optionRoot) '*.*.*'          Select all channels up to 2 levels")
        emit("  \(optionRoot) '*.*.*.*'        Select all channels up to 3 levels")
        emit("  \(optionRoot) 'alpha.*'        Select all top-level channels in alpha")
        emit("  \(optionRoot) 'alpha.*.*'      Select all channels in alpha (up to 2 levels)")
        emit("  \(optionRoot) 'alpha.*.*.*'    Select all channels in alpha (up to 3 levels)")
        emit("  \(optionRoot) '*.net'          Select 'net' across all namespaces")
        emit("  \(optionRoot) '*.scheduler.tick' Select 'scheduler.tick' across namespaces")
        emit("  \(optionRoot) '*.net.*'        Select subchannels under 'net' across namespaces")
        emit("  \(optionRoot) '*.{net,io}'     Select 'net' and 'io' across all namespaces")
        emit("  \(optionRoot) '{alpha,beta}.*' Select all top-level channels in alpha and beta")
        emit("  \(optionRoot) alpha.net")
        emit("  \(optionRoot) beta.scheduler.tick")
        emit("  \(optionRoot) alpha.net,beta.io")
        emit("  \(optionRoot) gamma.physics.*")
        emit("  \(optionRoot) gamma.physics.*.*")
        emit("  \(optionRoot) alpha.{net,cache}")
        emit("  \(optionRoot) beta.{io,scheduler}.packet")
        emit("  \(optionRoot) '{alpha,beta}.net'")
        emit("")
    }

    private func printNamespaces() {
        let namespaces = namespaces
        if namespaces.isEmpty {
            emit("No trace namespaces defined.")
            emit("")
            return
        }

        emit("")
        emit("Available trace namespaces:")
        for traceNamespace in namespaces {
            emit("  \(traceNamespace)")
        }
        emit("")
    }

    private func printChannels() {
        var printedAny = false
        for traceNamespace in namespaces {
            for channel in channels(in: traceNamespace) {
                if !printedAny {
                    emit("")
                    emit("Available trace channels:")
                    printedAny = true
                }
                emit("  \(traceNamespace).\(channel)")
            }
        }
        if !printedAny {
            emit("No trace channels defined.")
            emit("")
            return
        }
        emit("")
    }

    private func printColors() {
        emit("")
        emit("Available trace colors:")
        for color in TraceColors.names {
            emit("  \(color)")
        }
        emit("")
    }

    private func logLocalWarning(traceNamespace: String, message: String) throws {
        let namespace = trimWhitespace(traceNamespace).isEmpty ? "ktrace" : trimWhitespace(traceNamespace)
        emitLog(storage,
                traceNamespace: namespace,
                severity: .warning,
                source: SourceContext(file: #fileID, line: #line, function: #function),
                message: message)
    }

    private func emit(_ line: String) {
        let payload = line.isEmpty ? "\n" : "\(line)\n"
        storage.emit(payload)
    }
}

private func shouldTrace(_ logger: LoggerStorage, traceNamespace: String, channel: String) -> Bool {
    let hasEnabledChannels = logger.readEnabledChannels { !$0.isEmpty }
    guard hasEnabledChannels else {
        return false
    }
    let key = "\(traceNamespace).\(channel)"
    let isRegistered = logger.readRegistry { ($0.channelsByNamespace[traceNamespace] ?? []).contains(channel) }
    guard isRegistered else {
        return false
    }
    return logger.readEnabledChannels { $0.contains(key) }
}

func mergeColor(existing: Int,
                incoming: Int,
                traceNamespace: String,
                channel: String) throws -> Int {
    if incoming == TraceColors.defaultColor {
        return existing
    }
    if existing == TraceColors.defaultColor {
        return incoming
    }
    if existing == incoming {
        return existing
    }
    throw TraceConfigurationError(
        "conflicting explicit trace colors for '\(traceNamespace).\(channel)'"
    )
}

func normalizeNamespace(_ traceNamespace: String) throws -> String {
    let token = trimWhitespace(traceNamespace)
    if !isIdentifierToken(token) {
        throw TraceConfigurationError("invalid trace namespace '\(token)'")
    }
    return token
}

func normalizeChannel(_ channel: String) throws -> String {
    let token = trimWhitespace(channel)
    let segments = token.split(separator: ".", omittingEmptySubsequences: false)
    if token.isEmpty || segments.isEmpty || segments.count > 3 {
        throw TraceConfigurationError("invalid trace channel '\(token)'")
    }
    for segment in segments {
        if !isIdentifierToken(String(segment)) {
            throw TraceConfigurationError("invalid trace channel '\(token)'")
        }
    }
    return token
}

private func formatMessage(_ format: String, _ args: [Any]) throws -> String {
    var output = ""
    var argIndex = 0
    var index = format.startIndex

    while index < format.endIndex {
        let character = format[index]
        if character == "{" {
            let next = format.index(after: index)
            guard next < format.endIndex else {
                throw TraceRuntimeError("unterminated '{' in trace format string")
            }
            if format[next] == "{" {
                output.append("{")
                index = format.index(after: next)
                continue
            }
            guard format[next] == "}" else {
                throw TraceRuntimeError("unsupported trace format token")
            }
            guard argIndex < args.count else {
                throw TraceRuntimeError("missing trace format argument")
            }
            output += String(describing: args[argIndex])
            argIndex += 1
            index = format.index(after: next)
            continue
        }

        if character == "}" {
            let next = format.index(after: index)
            guard next < format.endIndex, format[next] == "}" else {
                throw TraceRuntimeError("unescaped '}' in trace format string")
            }
            output.append("}")
            index = format.index(after: next)
            continue
        }

        output.append(character)
        index = format.index(after: index)
    }

    if argIndex != args.count {
        throw TraceRuntimeError("unused trace format argument")
    }
    return output
}
