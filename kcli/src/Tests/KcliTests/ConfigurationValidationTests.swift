import XCTest
@testable import Kcli

final class ConfigurationValidationTests: XCTestCase {
    func testAddAliasRejectsInvalidAlias() {
        let parser = Parser()

        XCTAssertThrowsError(try parser.addAlias("--verbose", target: "--output")) { error in
            XCTAssertEqual(error as? CliConfigurationError,
                           CliConfigurationError("kcli alias must use single-dash form, e.g. '-v'"))
        }
    }

    func testAddAliasRejectsInvalidTarget() {
        let parser = Parser()

        XCTAssertThrowsError(try parser.addAlias("-v", target: "--bad target")) { error in
            XCTAssertEqual(error as? CliConfigurationError,
                           CliConfigurationError("kcli alias target must use double-dash form, e.g. '--verbose'"))
        }
    }

    func testAddAliasRejectsSingleDashTarget() {
        let parser = Parser()

        XCTAssertThrowsError(try parser.addAlias("-a", target: "-b")) { error in
            XCTAssertEqual(error as? CliConfigurationError,
                           CliConfigurationError("kcli alias target must use double-dash form, e.g. '--verbose'"))
        }
    }

    func testEndUserHandlerNormalizationRejectsSingleDash() {
        let parser = Parser()

        XCTAssertThrowsError(try parser.setHandler("-verbose", handler: { _ in
        }, description: "Enable verbose logging.")) { error in
            XCTAssertEqual(error as? CliConfigurationError,
                           CliConfigurationError("kcli end-user handler option must use '--name' or 'name'"))
        }
    }

    func testInlineHandlerNormalizationRejectsWrongRoot() throws {
        var parser = try InlineParser("--build")

        XCTAssertThrowsError(try parser.setHandler("--other-flag", handler: { _ in
        }, description: "Enable other flag.")) { error in
            XCTAssertEqual(error as? CliConfigurationError,
                           CliConfigurationError("kcli inline handler option must use '-name' or '--build-name'"))
        }
    }
}
