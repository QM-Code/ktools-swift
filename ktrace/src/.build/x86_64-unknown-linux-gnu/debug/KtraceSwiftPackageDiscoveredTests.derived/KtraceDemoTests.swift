import XCTest
@testable import KtraceDemoTests

fileprivate extension KtraceDemoTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__KtraceDemoTests = [
        ("testCoreDemoBareTraceRootPrintsHelp", testCoreDemoBareTraceRootPrintsHelp),
        ("testCoreDemoImportedSelectorShowsImportedTrace", testCoreDemoImportedSelectorShowsImportedTrace),
        ("testOmegaDemoBadSelectorFails", testOmegaDemoBadSelectorFails),
        ("testOmegaDemoBraceSelectorFiltersChannels", testOmegaDemoBraceSelectorFiltersChannels)
    ]
}
@available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
func __KtraceDemoTests__allTests() -> [XCTestCaseEntry] {
    return [
        testCase(KtraceDemoTests.__allTests__KtraceDemoTests)
    ]
}