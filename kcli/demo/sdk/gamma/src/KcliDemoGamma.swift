import Kcli

public func makeKcliDemoGammaParser(
    emit: @escaping (String) -> Void = defaultDemoEmit
) throws -> InlineParser {
    var parser = try InlineParser("--gamma")
    try parser.setOptionalValueHandler("-strict",
                                       handler: { context, value in
                                           handleStrict(context, value, emit: emit)
                                       },
                                       description: "Enable strict gamma mode.")
    try parser.setHandler("-tag",
                          handler: { context, value in
                              handleTag(context, value, emit: emit)
                          },
                          description: "Set a gamma tag label.")
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

private func handleStrict(_ context: HandlerContext,
                          _ value: String,
                          emit: (String) -> Void) {
    printProcessingLine(context, value: value, emit: emit)
}

private func handleTag(_ context: HandlerContext,
                       _ value: String,
                       emit: (String) -> Void) {
    printProcessingLine(context, value: value, emit: emit)
}
