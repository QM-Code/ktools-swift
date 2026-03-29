import XCTest
@testable import Kcli

final class ParseLifecycleTests: XCTestCase {
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

    func testSinglePassProcessingConsumesInlineEndUserAndPositionals() throws {
        let parser = Parser()
        var alphaMessage = ""
        var output = ""
        var positionals: [String] = []

        var alpha = try InlineParser("--alpha")
        try alpha.setHandler("-message", handler: { _, value in
            alphaMessage = value
        }, description: "Set alpha message.")
        try parser.addInlineParser(alpha)

        try parser.setHandler("--output", handler: { _, value in
            output = value
        }, description: "Set output target.")
        try parser.setPositionalHandler { context in
            positionals = context.valueTokens
        }

        let argv = ["prog", "tail", "--alpha-message", "hello", "--output", "stdout"]
        try parser.parseOrThrow(argv)

        XCTAssertEqual(alphaMessage, "hello")
        XCTAssertEqual(output, "stdout")
        XCTAssertEqual(positionals, ["tail"])
        XCTAssertEqual(argv, ["prog", "tail", "--alpha-message", "hello", "--output", "stdout"])
    }
}
