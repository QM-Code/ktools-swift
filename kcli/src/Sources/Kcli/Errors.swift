import Foundation

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

    public var option: String {
        optionToken
    }

    public var description: String {
        message
    }

    public var errorDescription: String? {
        message
    }
}
