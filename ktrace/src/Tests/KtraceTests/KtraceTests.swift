import XCTest
@testable import Ktrace

final class KtraceTests: XCTestCase {
    func testFormatMessageAndEscapes() throws {
        var output = ""
        let logger = Logger(output: { output += $0 })
        let trace = try TraceLogger("tests")
        try trace.addChannel("trace")
        try logger.addTraceLogger(trace)
        try logger.enableChannel("tests.trace")

        try trace.trace("trace", "value {} {{ok}}", 42)
        XCTAssertTrue(output.contains("[tests] [trace]"))
        XCTAssertTrue(output.contains("value 42 {ok}"))
    }

    func testFormatErrorsMirrorContract() throws {
        XCTAssertThrowsError(try emitInvalidFormat("value {} {}", 7))
        XCTAssertThrowsError(try emitInvalidFormat("value", 7))
        XCTAssertThrowsError(try emitInvalidFormat("{", 7))
        XCTAssertThrowsError(try emitInvalidFormat("}", 7))
        XCTAssertThrowsError(try emitInvalidFormat("{:x}", 7))
    }

    func testOperationalLoggingIncludesSeverity() throws {
        var output = ""
        let logger = Logger(output: { output += $0 })
        let trace = try TraceLogger("tests")
        try logger.addTraceLogger(trace)
        logger.setOutputOptions(OutputOptions(true, true, false, false))

        try trace.info("info message")
        try trace.warn("warn value {}", 7)
        try trace.error("error message")

        XCTAssertTrue(output.contains("[tests] [info]"))
        XCTAssertTrue(output.contains("[tests] [warning]"))
        XCTAssertTrue(output.contains("[tests] [error]"))
        XCTAssertTrue(output.contains("warn value 7"))
    }

    func testOperationalLoggingIncludesSourceLocationWhenEnabled() throws {
        var output = ""
        let logger = Logger(output: { output += $0 })
        let trace = try TraceLogger("tests")
        try logger.addTraceLogger(trace)
        logger.setOutputOptions(OutputOptions(true, true, false, false))

        let infoLine = #line + 1
        try trace.info("info message")
        let warnLine = #line + 1
        try trace.warn("warn value {}", 7)
        let errorLine = #line + 1
        try trace.error("error message")

        XCTAssertTrue(output.hasPrefix("[tests] [info] "))
        XCTAssertTrue(output.contains("\n[tests] [warning] "))
        XCTAssertTrue(output.contains("\n[tests] [error] "))
        XCTAssertTrue(output.contains("KtraceTests.swift:\(infoLine)"))
        XCTAssertTrue(output.contains("KtraceTests.swift:\(warnLine)"))
        XCTAssertTrue(output.contains("KtraceTests.swift:\(errorLine)"))
        XCTAssertFalse(output.contains("[info] [tests] [info]"))
        XCTAssertFalse(output.contains("[warning] [tests] [warning]"))
        XCTAssertFalse(output.contains("[error] [tests] [error]"))
    }

    func testSelectorSemantics() throws {
        let logger = Logger(output: { _ in })
        let trace = try TraceLogger("tests")
        try trace.addChannel("net")
        try trace.addChannel("cache")
        try trace.addChannel("store")
        try trace.addChannel("store.requests")
        try logger.addTraceLogger(trace)

        try logger.enableChannels("tests.*")
        XCTAssertTrue(logger.shouldTraceChannel("tests.net"))
        XCTAssertTrue(logger.shouldTraceChannel("tests.cache"))

        try logger.disableChannels("tests.*")
        XCTAssertFalse(logger.shouldTraceChannel("tests.net"))

        try logger.enableChannel("tests.net")
        XCTAssertTrue(logger.shouldTraceChannel("tests.net"))
        XCTAssertFalse(logger.shouldTraceChannel("tests.cache"))

        try logger.enableChannels("*.*.*")
        XCTAssertTrue(logger.shouldTraceChannel("tests.store.requests"))
        XCTAssertTrue(logger.shouldTraceChannel("tests.net"))
        XCTAssertFalse(logger.shouldTraceChannel("tests.bad name"))

        try logger.enableChannel("tests.missing.child")
        XCTAssertFalse(logger.shouldTraceChannel("tests.missing.child"))

        try logger.enableChannels("tests.missing.child")
        XCTAssertFalse(logger.shouldTraceChannel("tests.missing.child"))
    }

    func testLocalNamespaceSelectorSemantics() throws {
        let logger = Logger(output: { _ in })
        let trace = try TraceLogger("tests")
        try trace.addChannel("net")
        try logger.addTraceLogger(trace)

        try logger.enableChannel(trace, ".net")
        XCTAssertTrue(logger.shouldTraceChannel(trace, ".net"))
        XCTAssertTrue(trace.shouldTraceChannel("net"))

        try logger.disableChannel(trace, ".net")
        XCTAssertFalse(logger.shouldTraceChannel(trace, ".net"))
        XCTAssertFalse(trace.shouldTraceChannel("net"))
    }

    func testUnmatchedSelectorLogsWarningButDoesNotThrow() throws {
        var output = ""
        let logger = Logger(output: { output += $0 })
        let trace = try TraceLogger("tests")
        try trace.addChannel("net")
        try logger.addTraceLogger(trace)

        try logger.enableChannels(trace, ".cache")

        XCTAssertTrue(output.contains("[tests] [warning]"))
        XCTAssertTrue(output.contains("matched no registered channels"))
        XCTAssertFalse(logger.shouldTraceChannel(trace, ".cache"))
    }

    func testConflictingColorsRejected() throws {
        let logger = Logger(output: { _ in })
        let first = try TraceLogger("tests")
        try first.addChannel("net")
        try logger.addTraceLogger(first)

        let explicit = try TraceLogger("tests")
        try explicit.addChannel("net", color: try TraceColors.color("Gold3"))
        try logger.addTraceLogger(explicit)

        let conflicting = try TraceLogger("tests")
        try conflicting.addChannel("net", color: try TraceColors.color("Orange3"))
        XCTAssertThrowsError(try logger.addTraceLogger(conflicting))
    }

    func testTraceChangedSuppressesDuplicates() throws {
        var output = ""
        let logger = Logger(output: { output += $0 })
        let trace = try TraceLogger("tests")
        try trace.addChannel("changed")
        try logger.addTraceLogger(trace)
        try logger.enableChannel("tests.changed")

        try emitChanged(trace, key: "key-1")
        try emitChanged(trace, key: "key-1")
        try emitChanged(trace, key: "key-2")

        XCTAssertEqual(output.split(separator: "\n").filter { $0.contains("changed") }.count, 2)
    }

    func testNamespacesAndChannelsAreSorted() throws {
        let logger = Logger(output: { _ in })
        let beta = try TraceLogger("beta")
        try beta.addChannel("store")
        let alpha = try TraceLogger("alpha")
        try alpha.addChannel("net")
        try alpha.addChannel("app")

        try logger.addTraceLogger(beta)
        try logger.addTraceLogger(alpha)

        XCTAssertEqual(logger.getNamespaces(), ["alpha", "beta", "ktrace"])
        XCTAssertEqual(logger.getChannels("alpha"), ["app", "net"])
    }

    private func emitChanged(_ trace: TraceLogger, key: String) throws {
        try trace.traceChanged("changed", key, "changed")
    }

    private func emitInvalidFormat(_ format: String, _ arg: Any) throws {
        let logger = Logger(output: { _ in })
        let trace = try TraceLogger("tests")
        try logger.addTraceLogger(trace)
        try trace.warn(format, arg)
    }
}
