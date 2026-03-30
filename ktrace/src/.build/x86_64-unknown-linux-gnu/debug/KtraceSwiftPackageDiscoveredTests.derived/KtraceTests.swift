import XCTest
@testable import KtraceTests

fileprivate extension KtraceTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__KtraceTests = [
        ("testConflictingColorsRejected", testConflictingColorsRejected),
        ("testFormatErrorsMirrorContract", testFormatErrorsMirrorContract),
        ("testFormatMessageAndEscapes", testFormatMessageAndEscapes),
        ("testLocalNamespaceSelectorSemantics", testLocalNamespaceSelectorSemantics),
        ("testNamespacesAndChannelsAreSorted", testNamespacesAndChannelsAreSorted),
        ("testOperationalLoggingIncludesSeverity", testOperationalLoggingIncludesSeverity),
        ("testOperationalLoggingIncludesSourceLocationWhenEnabled", testOperationalLoggingIncludesSourceLocationWhenEnabled),
        ("testSelectorSemantics", testSelectorSemantics),
        ("testTraceChangedSuppressesDuplicates", testTraceChangedSuppressesDuplicates),
        ("testUnmatchedSelectorLogsWarningButDoesNotThrow", testUnmatchedSelectorLogsWarningButDoesNotThrow)
    ]
}
@available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
func __KtraceTests__allTests() -> [XCTestCaseEntry] {
    return [
        testCase(KtraceTests.__allTests__KtraceTests)
    ]
}