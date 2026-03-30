import Foundation

enum LogSeverity: String {
    case info
    case warning
    case error
}

struct SourceContext {
    let file: String
    let line: Int
    let function: String
}

func trimWhitespace(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines)
}

func isIdentifierToken(_ value: String) -> Bool {
    !value.isEmpty && value.allSatisfy { character in
        character.isLetter || character.isNumber || character == "_" || character == "-"
    }
}

final class LockedState<Value> {
    private var value: Value
    private let lock = NSLock()

    init(_ value: Value) {
        self.value = value
    }

    func withValue<T>(_ body: (inout Value) throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body(&value)
    }

    func read<T>(_ body: (Value) throws -> T) rethrows -> T {
        try withValue { value in
            try body(value)
        }
    }
}

func basename(_ path: String) -> String {
    path.split(separator: "/").last.map(String.init) ?? path
}
