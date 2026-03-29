import XCTest
@testable import Kcli

final class AliasBehaviorTests: XCTestCase {
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

    func testAddAliasPresetTokensAppendToValueHandlers() throws {
        let argv = ["prog", "-c", "settings.json"]
        let parser = Parser()
        var seenOption = ""
        var value = ""
        var tokens: [String] = []

        try parser.addAlias("-c", target: "--config-load", presetTokens: ["user-file"])
        try parser.setHandler("--config-load", handler: { context, captured in
            seenOption = context.option
            value = captured
            tokens = context.valueTokens
        }, description: "Load config.")

        try parser.parseOrThrow(argv)
        XCTAssertEqual(seenOption, "--config-load")
        XCTAssertEqual(value, "user-file settings.json")
        XCTAssertEqual(tokens, ["user-file", "settings.json"])
        XCTAssertEqual(argv, ["prog", "-c", "settings.json"])
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
            XCTAssertEqual(context.option, "--profile")
        }, description: "Set the active profile.")

        try parser.parseOrThrow(argv)
        XCTAssertEqual(value, "release")
        XCTAssertEqual(tokens, ["release"])
        XCTAssertEqual(argv, ["prog", "-p"])
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
            XCTAssertEqual(context.option, "--config")
        }, valuePlaceholder: "<assignment>", description: "Store a config assignment.")

        try parser.addInlineParser(config)
        try parser.addAlias("-c", target: "--config", presetTokens: ["user-file=/tmp/user.json"])

        try parser.parseOrThrow(argv)
        XCTAssertTrue(handled)
        XCTAssertEqual(value, "user-file=/tmp/user.json")
        XCTAssertEqual(tokens, ["user-file=/tmp/user.json"])
        XCTAssertEqual(argv, ["prog", "-c"])
    }

    func testAliasDoesNotRewriteRequiredValueTokens() throws {
        let argv = ["prog", "--output", "-v"]
        let parser = Parser()
        var verbose = false
        var output = ""

        try parser.addAlias("-v", target: "--verbose")
        try parser.setHandler("--verbose", handler: { _ in
            verbose = true
        }, description: "Enable verbose logging.")
        try parser.setHandler("--output", handler: { _, value in
            output = value
        }, description: "Set output target.")

        try parser.parseOrThrow(argv)
        XCTAssertFalse(verbose)
        XCTAssertEqual(output, "-v")
        XCTAssertEqual(argv, ["prog", "--output", "-v"])
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

    func testLiteralDoubleDashRejectedWhenAliasExists() throws {
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
}
