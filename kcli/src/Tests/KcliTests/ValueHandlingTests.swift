import XCTest
@testable import Kcli

final class ValueHandlingTests: XCTestCase {
    func testOptionalValueHandlerAllowsMissingValue() throws {
        let argv = ["prog", "--color"]
        let parser = Parser()
        var captured = "unset"
        var tokens: [String] = ["unexpected"]

        try parser.setOptionalValueHandler("--color", handler: { context, value in
            captured = value
            tokens = context.valueTokens
        }, description: "Set output color mode.")

        try parser.parseOrThrow(argv)
        XCTAssertEqual(captured, "")
        XCTAssertEqual(tokens, [])
    }

    func testOptionalValueHandlerAcceptsExplicitEmptyValue() throws {
        let parser = Parser()
        var captured = "unset"
        var tokens: [String] = []

        try parser.setOptionalValueHandler("--color", handler: { context, value in
            captured = value
            tokens = context.valueTokens
        }, description: "Set output color mode.")

        try parser.parseOrThrow(["prog", "--color", ""])
        XCTAssertEqual(captured, "")
        XCTAssertEqual(tokens, [""])
    }

    func testRequiredValueHandlerRejectsMissingValue() throws {
        let parser = Parser()
        var build = try InlineParser("--build")
        try build.setHandler("-value", handler: { _, _ in
        }, description: "Set build value.")
        try parser.addInlineParser(build)

        do {
            try parser.parseOrThrow(["prog", "--build-value"])
            XCTFail("expected parse to fail")
        } catch let error as CliError {
            XCTAssertEqual(error.option(), "--build-value")
            XCTAssertEqual(error.message, "option '--build-value' requires a value")
        }
    }

    func testRequiredValueHandlerAcceptsDashPrefixedFirstValue() throws {
        let argv = ["prog", "--profile", "-debug"]
        let parser = Parser()
        var captured = ""

        try parser.setHandler("--profile", handler: { _, value in
            captured = value
        }, description: "Set build profile.")

        try parser.parseOrThrow(argv)
        XCTAssertEqual(captured, "-debug")
    }

    func testRequiredValueHandlerJoinsMultipleTokens() throws {
        let argv = ["prog", "--name", "Joe", "Smith"]
        let parser = Parser()
        var captured = ""
        var tokens: [String] = []

        try parser.setHandler("--name", handler: { context, value in
            captured = value
            tokens = context.valueTokens
        }, description: "Set display name.")

        try parser.parseOrThrow(argv)
        XCTAssertEqual(captured, "Joe Smith")
        XCTAssertEqual(tokens, ["Joe", "Smith"])
    }

    func testRequiredValueHandlerPreservesShellWhitespace() throws {
        let argv = ["prog", "--name", " Joe "]
        let parser = Parser()
        var captured = ""
        var tokens: [String] = []

        try parser.setHandler("--name", handler: { context, value in
            captured = value
            tokens = context.valueTokens
        }, description: "Set display name.")

        try parser.parseOrThrow(argv)
        XCTAssertEqual(captured, " Joe ")
        XCTAssertEqual(tokens, [" Joe "])
        XCTAssertEqual(argv, ["prog", "--name", " Joe "])
    }

    func testRequiredValueHandlerAcceptsExplicitEmptyValue() throws {
        let parser = Parser()
        var captured = "unset"
        var tokens: [String] = []

        try parser.setHandler("--name", handler: { context, value in
            captured = value
            tokens = context.valueTokens
        }, description: "Set display name.")

        try parser.parseOrThrow(["prog", "--name", ""])
        XCTAssertEqual(captured, "")
        XCTAssertEqual(tokens, [""])
    }

    func testFlagHandlerDoesNotConsumeFollowingTokens() throws {
        let parser = Parser()
        var called = false
        var positionals: [String] = []

        var build = try InlineParser("--build")
        try build.setHandler("-meta", handler: { _ in
            called = true
        }, description: "Record metadata.")
        try parser.addInlineParser(build)
        try parser.setPositionalHandler { context in
            positionals = context.valueTokens
        }

        let argv = ["prog", "--build-meta", "data"]
        try parser.parseOrThrow(argv)

        XCTAssertTrue(called)
        XCTAssertEqual(positionals, ["data"])
        XCTAssertEqual(argv, ["prog", "--build-meta", "data"])
    }

    func testPositionalHandlerPreservesExplicitEmptyTokens() throws {
        let parser = Parser()
        var positionals: [String] = []

        try parser.setPositionalHandler { context in
            positionals = context.valueTokens
        }

        try parser.parseOrThrow(["prog", "alpha", "", "omega"])
        XCTAssertEqual(positionals, ["alpha", "", "omega"])
    }
}
