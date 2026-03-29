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
