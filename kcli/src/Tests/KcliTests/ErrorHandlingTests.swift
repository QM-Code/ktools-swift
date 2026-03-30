import XCTest
@testable import Kcli

final class ErrorHandlingTests: XCTestCase {
    func testLiteralDoubleDashRejected() throws {
        let parser = Parser()
        try parser.addAlias("-v", target: "--verbose")
        try parser.setHandler("--verbose", handler: { _ in }, description: "Enable verbose logging.")

        do {
            try parser.parse(["prog", "--", "-v"])
            XCTFail("expected parse to fail")
        } catch let error as CliError {
            XCTAssertEqual(error.option, "--")
            XCTAssertEqual(error.message, "unknown option --")
        }
    }

    func testUnknownOptionThrowsCliError() {
        let parser = Parser()

        do {
            try parser.parse(["prog", "--bogus"])
            XCTFail("expected parse to fail")
        } catch let error as CliError {
            XCTAssertEqual(error.option, "--bogus")
            XCTAssertEqual(error.message, "unknown option --bogus")
        } catch {
            XCTFail("expected CliError, got \(error)")
        }
    }

    func testHandlerExceptionWrappedAsCliError() throws {
        let parser = Parser()
        try parser.setHandler("--profile", handler: { _, _ in
            throw CliConfigurationError("bad profile")
        }, description: "Set build profile.")

        do {
            try parser.parse(["prog", "--profile", "dev"])
            XCTFail("expected parse to fail")
        } catch let error as CliError {
            XCTAssertEqual(error.option, "--profile")
            XCTAssertEqual(error.message, "option '--profile': bad profile")
        }
    }

    func testPositionalHandlerExceptionWrappedAsCliError() throws {
        let parser = Parser()
        try parser.setPositionalHandler { _ in
            throw CliConfigurationError("positional boom")
        }

        do {
            try parser.parse(["prog", "tail"])
            XCTFail("expected parse to fail")
        } catch let error as CliError {
            XCTAssertEqual(error.option, "")
            XCTAssertEqual(error.message, "positional boom")
        }
    }
}
