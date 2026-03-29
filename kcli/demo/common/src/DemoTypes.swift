import Foundation

public typealias DemoEmitter = (String) -> Void

public struct DemoRuntimeError: Error, CustomStringConvertible, LocalizedError, Equatable {
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

public func defaultDemoEmit(_ text: String) {
    print(text, terminator: "")
}

func executableName(_ path: String?) -> String {
    if let path, !path.isEmpty {
        return path
    }
    return "app"
}
