import XCTest
@testable import KcliDemoTests

fileprivate extension KcliDemoTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__KcliDemoTests = [
        ("testCoreDemoRunsWithAlphaMessage", testCoreDemoRunsWithAlphaMessage),
        ("testOmegaDemoRunsWithRenamedGammaRoot", testOmegaDemoRunsWithRenamedGammaRoot),
        ("testOmegaDemoSupportsAlphaAlias", testOmegaDemoSupportsAlphaAlias)
    ]
}
@available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
func __KcliDemoTests__allTests() -> [XCTestCaseEntry] {
    return [
        testCase(KcliDemoTests.__allTests__KcliDemoTests)
    ]
}