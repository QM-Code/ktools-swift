import Kcli

public func makeKcliDemoAlphaParser(
    emit: @escaping (String) -> Void = defaultDemoEmit
) throws -> InlineParser {
    var parser = try InlineParser("--alpha")
    try parser.setHandler("-message",
                          handler: { context, value in
                              handleMessage(context, value, emit: emit)
                          },
                          description: "Set alpha message label.")
    try parser.setOptionalValueHandler("-enable",
                                       handler: { context, value in
                                           handleEnable(context, value, emit: emit)
                                       },
                                       description: "Enable alpha processing.")
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

private func handleMessage(_ context: HandlerContext,
                           _ value: String,
                           emit: (String) -> Void) {
    printProcessingLine(context, value: value, emit: emit)
}

private func handleEnable(_ context: HandlerContext,
                          _ value: String,
                          emit: (String) -> Void) {
    printProcessingLine(context, value: value, emit: emit)
}
