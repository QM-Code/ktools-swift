import XCTest
@testable import KcliDemoCoreSupport
@testable import KcliDemoOmegaSupport

final class KcliDemoTests: XCTestCase {
    func testCoreDemoRunsWithAlphaMessage() {
        var output = ""
        let exitCode = runCoreDemo(arguments: ["demo", "--alpha-message", "hello"]) { text in
            output += text
        }

        XCTAssertEqual(exitCode, 0)
        XCTAssertTrue(output.contains("Processing --alpha-message with value \"hello\""))
        XCTAssertTrue(output.contains("KCLI Swift demo core import/integration check passed"))
        XCTAssertTrue(output.contains("Enabled inline roots:"))
    }

    func testOmegaDemoRunsWithRenamedGammaRoot() {
        var output = ""
        let exitCode = runOmegaDemo(arguments: ["demo", "--newgamma-tag", "prod", "--beta-workers", "8"]) { text in
            output += text
        }

        XCTAssertEqual(exitCode, 0)
        XCTAssertTrue(output.contains("Processing --newgamma-tag with value \"prod\""))
        XCTAssertTrue(output.contains("Processing --beta-workers with value \"8\""))
        XCTAssertTrue(output.contains("Enabled --<root> prefixes:"))
    }

    func testOmegaDemoSupportsAlphaAlias() {
        var output = ""
        let exitCode = runOmegaDemo(arguments: ["demo", "-a"]) { text in
            output += text
        }

        XCTAssertEqual(exitCode, 0)
        XCTAssertTrue(output.contains("Processing --alpha-enable"))
    }
}
