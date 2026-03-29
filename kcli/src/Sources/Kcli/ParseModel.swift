enum ValueArity {
    case required
    case optional
}

enum RegisteredHandler {
    case flag(FlagHandler)
    case value(ValueHandler, ValueArity)
}

struct CommandBinding {
    let handler: RegisteredHandler
    let description: String
}

struct AliasBinding {
    let alias: String
    let targetToken: String
    let presetTokens: [String]
}

typealias HelpRow = (String, String)

enum Invocation {
    case flag(context: HandlerContext, handler: FlagHandler)
    case value(context: HandlerContext, handler: ValueHandler)
    case positional(context: HandlerContext, handler: PositionalHandler)
    case printHelp(root: String, helpRows: [HelpRow])
}

struct CollectedValues {
    var hasValue = false
    var parts: [String] = []
    var lastIndex: Int
}

enum InlineTokenMatchKind {
    case none
    case bareRoot
    case dashOption
}

struct InlineTokenMatch {
    var kind: InlineTokenMatchKind = .none
    var parser: InlineParser?
    var suffix = ""
}
