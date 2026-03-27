import XCTest
@testable import KcliTests

fileprivate extension KcliTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__KcliTests = [
        ("testAddAliasPresetTokensApplyToInlineRootValues", testAddAliasPresetTokensApplyToInlineRootValues),
        ("testAddAliasPresetTokensSatisfyRequiredValues", testAddAliasPresetTokensSatisfyRequiredValues),
        ("testAddAliasRewritesTokens", testAddAliasRewritesTokens),
        ("testAliasPresetTokensRejectedForFlagHandler", testAliasPresetTokensRejectedForFlagHandler),
        ("testDuplicateInlineRootRejected", testDuplicateInlineRootRejected),
        ("testEndUserKnownOptionsWithUnknownOptionError", testEndUserKnownOptionsWithUnknownOptionError),
        ("testInlineBareRootHelpIncludesRootValueHandlerRow", testInlineBareRootHelpIncludesRootValueHandlerRow),
        ("testInlineBareRootPrintsHelp", testInlineBareRootPrintsHelp),
        ("testLiteralDoubleDashRejected", testLiteralDoubleDashRejected),
        ("testOptionalValueHandlerAllowsMissingValue", testOptionalValueHandlerAllowsMissingValue),
        ("testParserEmptyParseSucceeds", testParserEmptyParseSucceeds),
        ("testRequiredValueHandlerAcceptsDashPrefixedFirstValue", testRequiredValueHandlerAcceptsDashPrefixedFirstValue),
        ("testRequiredValueHandlerJoinsMultipleTokens", testRequiredValueHandlerJoinsMultipleTokens)
    ]
}
@available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
func __KcliTests__allTests() -> [XCTestCaseEntry] {
    return [
        testCase(KcliTests.__allTests__KcliTests)
    ]
}