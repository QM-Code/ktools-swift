import XCTest
@testable import KcliTests

fileprivate extension AliasBehaviorTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__AliasBehaviorTests = [
        ("testAddAliasPresetTokensAppendToValueHandlers", testAddAliasPresetTokensAppendToValueHandlers),
        ("testAddAliasPresetTokensApplyToInlineRootValues", testAddAliasPresetTokensApplyToInlineRootValues),
        ("testAddAliasPresetTokensSatisfyRequiredValues", testAddAliasPresetTokensSatisfyRequiredValues),
        ("testAddAliasRewritesTokens", testAddAliasRewritesTokens),
        ("testAliasDoesNotRewriteRequiredValueTokens", testAliasDoesNotRewriteRequiredValueTokens),
        ("testAliasPresetTokensRejectedForFlagHandler", testAliasPresetTokensRejectedForFlagHandler),
        ("testLiteralDoubleDashRejectedWhenAliasExists", testLiteralDoubleDashRejectedWhenAliasExists)
    ]
}

fileprivate extension ConfigurationValidationTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__ConfigurationValidationTests = [
        ("testAddAliasRejectsInvalidAlias", testAddAliasRejectsInvalidAlias),
        ("testAddAliasRejectsInvalidTarget", testAddAliasRejectsInvalidTarget),
        ("testAddAliasRejectsSingleDashTarget", testAddAliasRejectsSingleDashTarget),
        ("testEndUserHandlerNormalizationRejectsSingleDash", testEndUserHandlerNormalizationRejectsSingleDash),
        ("testInlineHandlerNormalizationRejectsWrongRoot", testInlineHandlerNormalizationRejectsWrongRoot)
    ]
}

fileprivate extension ErrorHandlingTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__ErrorHandlingTests = [
        ("testHandlerExceptionWrappedAsCliError", testHandlerExceptionWrappedAsCliError),
        ("testLiteralDoubleDashRejected", testLiteralDoubleDashRejected),
        ("testPositionalHandlerExceptionWrappedAsCliError", testPositionalHandlerExceptionWrappedAsCliError),
        ("testUnknownOptionThrowsCliError", testUnknownOptionThrowsCliError)
    ]
}

fileprivate extension InlineParserTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__InlineParserTests = [
        ("testDuplicateInlineRootRejected", testDuplicateInlineRootRejected),
        ("testInlineBareRootHelpIncludesRootValueHandlerRow", testInlineBareRootHelpIncludesRootValueHandlerRow),
        ("testInlineBareRootPrintsHelp", testInlineBareRootPrintsHelp),
        ("testInlineHandlerFullFormNormalizesCommandAndOption", testInlineHandlerFullFormNormalizesCommandAndOption),
        ("testInlineMissingRootValueHandlerErrors", testInlineMissingRootValueHandlerErrors),
        ("testInlineParserRejectsSingleDashRoot", testInlineParserRejectsSingleDashRoot),
        ("testInlineParserRootOverrideApplies", testInlineParserRootOverrideApplies),
        ("testInlineRootValueHandlerJoinsTokens", testInlineRootValueHandlerJoinsTokens),
        ("testUnknownInlineOptionErrors", testUnknownInlineOptionErrors)
    ]
}

fileprivate extension ParseLifecycleTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__ParseLifecycleTests = [
        ("testEndUserKnownOptionsWithUnknownOptionError", testEndUserKnownOptionsWithUnknownOptionError),
        ("testParserCanBeReusedAcrossParses", testParserCanBeReusedAcrossParses),
        ("testParserEmptyParseSucceeds", testParserEmptyParseSucceeds),
        ("testSinglePassProcessingConsumesInlineEndUserAndPositionals", testSinglePassProcessingConsumesInlineEndUserAndPositionals)
    ]
}

fileprivate extension ValueHandlingTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__ValueHandlingTests = [
        ("testFlagHandlerDoesNotConsumeFollowingTokens", testFlagHandlerDoesNotConsumeFollowingTokens),
        ("testOptionalValueHandlerAcceptsExplicitEmptyValue", testOptionalValueHandlerAcceptsExplicitEmptyValue),
        ("testOptionalValueHandlerAllowsMissingValue", testOptionalValueHandlerAllowsMissingValue),
        ("testPositionalHandlerPreservesExplicitEmptyTokens", testPositionalHandlerPreservesExplicitEmptyTokens),
        ("testRequiredValueHandlerAcceptsDashPrefixedFirstValue", testRequiredValueHandlerAcceptsDashPrefixedFirstValue),
        ("testRequiredValueHandlerAcceptsExplicitEmptyValue", testRequiredValueHandlerAcceptsExplicitEmptyValue),
        ("testRequiredValueHandlerJoinsMultipleTokens", testRequiredValueHandlerJoinsMultipleTokens),
        ("testRequiredValueHandlerPreservesShellWhitespace", testRequiredValueHandlerPreservesShellWhitespace),
        ("testRequiredValueHandlerRejectsMissingValue", testRequiredValueHandlerRejectsMissingValue)
    ]
}
@available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
func __KcliTests__allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AliasBehaviorTests.__allTests__AliasBehaviorTests),
        testCase(ConfigurationValidationTests.__allTests__ConfigurationValidationTests),
        testCase(ErrorHandlingTests.__allTests__ErrorHandlingTests),
        testCase(InlineParserTests.__allTests__InlineParserTests),
        testCase(ParseLifecycleTests.__allTests__ParseLifecycleTests),
        testCase(ValueHandlingTests.__allTests__ValueHandlingTests)
    ]
}