import XCTest
@testable import Kcli

final class InlineParserTests: XCTestCase {
    func testInlineParserRejectsSingleDashRoot() {
        XCTAssertThrowsError(try InlineParser("-build")) { error in
            XCTAssertEqual(error as? CliConfigurationError,
                           CliConfigurationError("kcli root must use '--root' or 'root'"))
        }
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

    func testInlineRootValueHandlerJoinsTokens() throws {
        let parser = Parser()
        var capturedValue = ""
        var capturedTokens: [String] = []
        var capturedOption = ""

        var build = try InlineParser("--build")
        try build.setRootValueHandler({ context, value in
            capturedValue = value
            capturedTokens = context.valueTokens
            capturedOption = context.option
        })
        try parser.addInlineParser(build)

        let argv = ["prog", "--build", "fast", "mode"]
        try parser.parseOrThrow(argv)

        XCTAssertEqual(capturedValue, "fast mode")
        XCTAssertEqual(capturedTokens, ["fast", "mode"])
        XCTAssertEqual(capturedOption, "--build")
        XCTAssertEqual(argv, ["prog", "--build", "fast", "mode"])
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

    func testInlineParserRootOverrideApplies() throws {
        let parser = Parser()
        var tag = ""

        var gamma = try InlineParser("--gamma")
        try gamma.setHandler("-tag", handler: { _, value in
            tag = value
        }, description: "Set gamma tag.")
        try gamma.setRoot("--newgamma")
        try parser.addInlineParser(gamma)

        let argv = ["prog", "--newgamma-tag", "prod"]
        try parser.parseOrThrow(argv)

        XCTAssertEqual(tag, "prod")
        XCTAssertEqual(argv, ["prog", "--newgamma-tag", "prod"])
    }

    func testDuplicateInlineRootRejected() throws {
        let parser = Parser()
        try parser.addInlineParser(InlineParser("build"))

        XCTAssertThrowsError(try parser.addInlineParser(InlineParser("--build"))) { error in
            XCTAssertEqual(error as? CliConfigurationError,
                           CliConfigurationError("kcli inline parser root '--build' is already registered"))
        }
    }
}
