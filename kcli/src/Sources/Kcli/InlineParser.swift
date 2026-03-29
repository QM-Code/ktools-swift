public struct InlineParser {
    var rootName: String
    var rootValueHandler: ValueHandler?
    var rootValuePlaceholder = ""
    var rootValueDescription = ""
    var commands: [(String, CommandBinding)] = []

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
