import XCTest
@testable import Kcli

final class KcliTests: XCTestCase {
    func testParserEmptyParseSucceeds() throws {
        let argv = ["prog"]
        let parser = Parser()

        try parser.parseOrThrow(argv)
        XCTAssertEqual(argv, ["prog"])
    }

    func testEndUserKnownOptionsWithUnknownOptionError() throws {
        let argv = ["prog", "--verbose", "pos1", "--output", "stdout", "--bogus", "pos2"]
        let parser = Parser()
        var verbose = false
        var output = ""
        var positionals: [String] = []

        try parser.setHandler("verbose", handler: { _ in
            verbose = true
        }, description: "Enable verbose logging.")

        try parser.setHandler("output", handler: { _, value in
            output = value
        }, description: "Set output target.")

        try parser.setPositionalHandler { context in
            positionals = context.valueTokens
        }

        do {
            try parser.parseOrThrow(argv)
            XCTFail("expected parse to fail")
        } catch let error as CliError {
            XCTAssertFalse(verbose)
            XCTAssertEqual(output, "")
            XCTAssertEqual(positionals, [])
            XCTAssertEqual(error.option(), "--bogus")
            XCTAssertEqual(error.message, "unknown option --bogus")
        }
    }

    func testInlineParserRejectsSingleDashRoot() {
        XCTAssertThrowsError(try InlineParser("-build")) { error in
            XCTAssertEqual(error as? CliConfigurationError,
                           CliConfigurationError("kcli root must use '--root' or 'root'"))
        }
    }

    func testAddAliasRewritesTokens() throws {
        let argv = ["prog", "-v", "tail"]
        let parser = Parser()
        var seenOption = ""

        try parser.addAlias("-v", target: "--verbose")
        try parser.setHandler("--verbose", handler: { context in
            seenOption = context.option
        }, description: "Enable verbose logging.")

        try parser.parseOrThrow(argv)
        XCTAssertEqual(seenOption, "--verbose")
        XCTAssertEqual(argv, ["prog", "-v", "tail"])
    }

    func testAddAliasPresetTokensSatisfyRequiredValues() throws {
        let argv = ["prog", "-p"]
        let parser = Parser()
        var value = ""
        var tokens: [String] = []

        try parser.addAlias("-p", target: "--profile", presetTokens: ["release"])
        try parser.setHandler("--profile", handler: { context, captured in
            value = captured
            tokens = context.valueTokens
        }, description: "Set the active profile.")

        try parser.parseOrThrow(argv)
        XCTAssertEqual(value, "release")
        XCTAssertEqual(tokens, ["release"])
    }

    func testAddAliasPresetTokensApplyToInlineRootValues() throws {
        let argv = ["prog", "-c"]
        let parser = Parser()
        var handled = false
        var value = ""
        var tokens: [String] = []

        var config = try InlineParser("--config")
        try config.setRootValueHandler({ context, captured in
            handled = true
            value = captured
            tokens = context.valueTokens
        }, valuePlaceholder: "<assignment>", description: "Store a config assignment.")

        try parser.addInlineParser(config)
        try parser.addAlias("-c", target: "--config", presetTokens: ["user-file=/tmp/user.json"])

        try parser.parseOrThrow(argv)
        XCTAssertTrue(handled)
        XCTAssertEqual(value, "user-file=/tmp/user.json")
        XCTAssertEqual(tokens, ["user-file=/tmp/user.json"])
    }

    func testInlineBareRootPrintsHelp() throws {
        let argv = ["prog", "--build"]
        let parser = Parser()
        var output = ""
        parser.io = ParserIO(
            stdout: { output += $0 },
            stderr: { _ in }
        )

        var build = try InlineParser("build")
        try build.setHandler("-flag", handler: { _ in }, description: "Enable build flag.")
        try build.setHandler("-value", handler: { _, _ in }, description: "Set build value.")
        try parser.addInlineParser(build)

        try parser.parseOrThrow(argv)
        XCTAssertTrue(output.contains("Available --build-* options:"))
        XCTAssertTrue(output.contains("--build-flag"))
        XCTAssertTrue(output.contains("--build-value <value>"))
    }

    func testInlineBareRootHelpIncludesRootValueHandlerRow() throws {
        let argv = ["prog", "--config"]
        let parser = Parser()
        var output = ""
        parser.io = ParserIO(
            stdout: { output += $0 },
            stderr: { _ in }
        )

        var config = try InlineParser("config")
        try config.setRootValueHandler({ _, _ in
        }, valuePlaceholder: "<assignment>", description: "Store a config assignment.")
        try config.setHandler("-load", handler: { _, _ in
        }, description: "Load config from a file.")
        try parser.addInlineParser(config)

        try parser.parseOrThrow(argv)
        XCTAssertTrue(output.contains("--config <assignment>"))
        XCTAssertTrue(output.contains("Store a config assignment."))
        XCTAssertTrue(output.contains("--config-load <value>"))
    }

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

    func testLiteralDoubleDashRejected() throws {
        let parser = Parser()
        try parser.addAlias("-v", target: "--verbose")
        try parser.setHandler("--verbose", handler: { _ in }, description: "Enable verbose logging.")

        do {
            try parser.parseOrThrow(["prog", "--", "-v"])
            XCTFail("expected parse to fail")
        } catch let error as CliError {
            XCTAssertEqual(error.option(), "--")
            XCTAssertEqual(error.message, "unknown option --")
        }
    }

    func testAliasPresetTokensRejectedForFlagHandler() throws {
        let parser = Parser()
        try parser.addAlias("-v", target: "--verbose", presetTokens: ["on"])
        try parser.setHandler("--verbose", handler: { _ in
        }, description: "Enable verbose logging.")

        do {
            try parser.parseOrThrow(["prog", "-v"])
            XCTFail("expected parse to fail")
        } catch let error as CliError {
            XCTAssertEqual(error.option(), "-v")
            XCTAssertEqual(error.message,
                           "alias '-v' presets values for option '--verbose' which does not accept values")
        }
    }

    func testParserCanBeReusedAcrossParses() throws {
        let parser = Parser()
        var values: [String] = []

        try parser.setHandler("--name", handler: { _, value in
            values.append(value)
        }, description: "Set a display name.")

        try parser.parseOrThrow(["prog", "--name", "alice"])
        try parser.parseOrThrow(["prog", "--name", "bob"])

        XCTAssertEqual(values, ["alice", "bob"])
    }

    func testInlineHandlerFullFormNormalizesCommandAndOption() throws {
        let parser = Parser()
        var seenContext = HandlerContext()

        var build = try InlineParser("--build")
        try build.setHandler("--build-profile", handler: { context, _ in
            seenContext = context
        }, description: "Set build profile.")
        try parser.addInlineParser(build)

        try parser.parseOrThrow(["prog", "--build-profile", "release"])
        XCTAssertEqual(seenContext.root, "build")
        XCTAssertEqual(seenContext.option, "--build-profile")
        XCTAssertEqual(seenContext.command, "profile")
        XCTAssertEqual(seenContext.valueTokens, ["release"])
    }

    func testInlineMissingRootValueHandlerErrors() throws {
        let parser = Parser()
        try parser.addInlineParser(InlineParser("--build"))

        do {
            try parser.parseOrThrow(["prog", "--build", "release"])
            XCTFail("expected parse to fail")
        } catch let error as CliError {
            XCTAssertEqual(error.option(), "--build")
            XCTAssertEqual(error.message, "unknown value for option '--build'")
        }
    }

    func testDuplicateInlineRootRejected() throws {
        let parser = Parser()
        try parser.addInlineParser(InlineParser("build"))

        XCTAssertThrowsError(try parser.addInlineParser(InlineParser("--build"))) { error in
            XCTAssertEqual(error as? CliConfigurationError,
                           CliConfigurationError("kcli inline parser root '--build' is already registered"))
        }
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

    func testPositionalHandlerPreservesExplicitEmptyTokens() throws {
        let parser = Parser()
        var positionals: [String] = []

        try parser.setPositionalHandler { context in
            positionals = context.valueTokens
        }

        try parser.parseOrThrow(["prog", "alpha", "", "omega"])
        XCTAssertEqual(positionals, ["alpha", "", "omega"])
    }

    func testUnknownInlineOptionErrors() throws {
        let parser = Parser()
        var build = try InlineParser("--build")
        try build.setHandler("-profile", handler: { _, _ in
        }, description: "Set build profile.")
        try parser.addInlineParser(build)

        do {
            try parser.parseOrThrow(["prog", "--build-unknown"])
            XCTFail("expected parse to fail")
        } catch let error as CliError {
            XCTAssertEqual(error.option(), "--build-unknown")
            XCTAssertEqual(error.message, "unknown option --build-unknown")
        }
    }

    func testHandlerExceptionWrappedAsCliError() throws {
        let parser = Parser()
        try parser.setHandler("--profile", handler: { _, _ in
            throw CliConfigurationError("bad profile")
        }, description: "Set build profile.")

        do {
            try parser.parseOrThrow(["prog", "--profile", "dev"])
            XCTFail("expected parse to fail")
        } catch let error as CliError {
            XCTAssertEqual(error.option(), "--profile")
            XCTAssertEqual(error.message, "option '--profile': bad profile")
        }
    }
}
