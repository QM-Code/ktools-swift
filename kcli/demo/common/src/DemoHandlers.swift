import Kcli

func printProcessingLine(_ context: HandlerContext,
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

func handleMessage(_ context: HandlerContext,
                   _ value: String,
                   emit: DemoEmitter) throws {
    printProcessingLine(context, value: value, emit: emit)
}

func handleEnable(_ context: HandlerContext,
                  _ value: String,
                  emit: DemoEmitter) throws {
    printProcessingLine(context, value: value, emit: emit)
}

func handleProfile(_ context: HandlerContext,
                   _ value: String,
                   emit: DemoEmitter) throws {
    printProcessingLine(context, value: value, emit: emit)
}

func handleWorkers(_ context: HandlerContext,
                   _ value: String,
                   emit: DemoEmitter) throws {
    if !value.isEmpty && Int(value) == nil {
        throw DemoRuntimeError("expected an integer")
    }
    printProcessingLine(context, value: value, emit: emit)
}

func handleStrict(_ context: HandlerContext,
                  _ value: String,
                  emit: DemoEmitter) throws {
    printProcessingLine(context, value: value, emit: emit)
}

func handleTag(_ context: HandlerContext,
               _ value: String,
               emit: DemoEmitter) throws {
    printProcessingLine(context, value: value, emit: emit)
}

func handleBuildProfile(_ context: HandlerContext, _ value: String) throws {}
func handleBuildClean(_ context: HandlerContext) throws {}
func handleVerbose(_ context: HandlerContext) throws {}
func handleOutput(_ context: HandlerContext, _ value: String) throws {}
func handleArgs(_ context: HandlerContext) throws {}
