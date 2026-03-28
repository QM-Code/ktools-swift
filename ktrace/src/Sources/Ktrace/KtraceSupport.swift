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

func withLock<T>(_ lock: NSLock, _ body: () throws -> T) rethrows -> T {
    lock.lock()
    defer { lock.unlock() }
    return try body()
}

func basename(_ path: String) -> String {
    path.split(separator: "/").last.map(String.init) ?? path
}
