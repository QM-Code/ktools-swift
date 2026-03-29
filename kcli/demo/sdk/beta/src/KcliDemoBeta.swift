import Foundation
import Kcli

public func makeKcliDemoBetaParser(
    emit: @escaping (String) -> Void = defaultDemoEmit
) throws -> InlineParser {
    var parser = try InlineParser("--beta")
    try parser.setHandler("-profile",
                          handler: { context, value in
                              handleProfile(context, value, emit: emit)
                          },
                          description: "Select beta runtime profile.")
    try parser.setHandler("-workers",
                          handler: { context, value in
                              try handleWorkers(context, value, emit: emit)
                          },
                          description: "Set beta worker count.")
    return parser
}

public func defaultDemoEmit(_ text: String) {
    print(text, terminator: "")
}

private func printProcessingLine(_ context: HandlerContext,
                                 value: String,
                                 emit: (String) -> Void) {
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

private func handleProfile(_ context: HandlerContext,
                           _ value: String,
                           emit: (String) -> Void) {
    printProcessingLine(context, value: value, emit: emit)
}

private func handleWorkers(_ context: HandlerContext,
                           _ value: String,
                           emit: (String) -> Void) throws {
    if !value.isEmpty && Int(value) == nil {
        throw DemoRuntimeError("expected an integer")
    }
    printProcessingLine(context, value: value, emit: emit)
}

private struct DemoRuntimeError: Error, CustomStringConvertible, LocalizedError, Equatable {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var description: String {
        message
    }

    var errorDescription: String? {
        message
    }
}
