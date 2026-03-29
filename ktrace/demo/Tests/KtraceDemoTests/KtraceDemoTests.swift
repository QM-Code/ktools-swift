import Foundation
import XCTest
@testable import KtraceDemoCoreSupport
@testable import KtraceDemoOmegaSupport

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

final class KtraceDemoTests: XCTestCase {
    func testCoreDemoBareTraceRootPrintsHelp() {
        let (exitCode, stdout) = captureStdout {
            runCoreDemo(arguments: ["demo", "--trace"]) { _ in
            }
        }

        XCTAssertEqual(exitCode, 0)
        XCTAssertTrue(stdout.contains("Available --trace-* options:"))
        XCTAssertTrue(stdout.contains("--trace <channels>"))
    }

    func testCoreDemoImportedSelectorShowsImportedTrace() {
        var output = ""
        let exitCode = runCoreDemo(arguments: ["demo", "--trace", "*.*"]) { text in
            output += text
        }

        XCTAssertEqual(exitCode, 0)
        XCTAssertTrue(output.contains("[core] [app] cli processing enabled"))
        XCTAssertTrue(output.contains("[alpha] [net] testing..."))
    }

    func testOmegaDemoExactMissingSelectorWarnsButSucceeds() {
        var output = ""
        let exitCode = runOmegaDemo(arguments: ["demo", "--trace", ".missing"]) { text in
            output += text
        }

        XCTAssertEqual(exitCode, 0)
        XCTAssertTrue(output.contains("[omega] [warning]"))
        XCTAssertTrue(output.contains("enable ignored channel selector 'omega.missing' because it matched no registered channels"))
    }

    func testOmegaDemoWildcardMissingSelectorWarnsButSucceeds() {
        var output = ""
        let exitCode = runOmegaDemo(arguments: ["demo", "--trace", "missing.*"]) { text in
            output += text
        }

        XCTAssertEqual(exitCode, 0)
        XCTAssertTrue(output.contains("[omega] [warning]"))
        XCTAssertTrue(output.contains("enable ignored channel selector 'missing.*' because it matched no registered channels"))
    }

    func testOmegaDemoBadSelectorFails() {
        var output = ""
        let exitCode = runOmegaDemo(arguments: ["demo", "--trace", "*"]) { text in
            output += text
        }

        XCTAssertEqual(exitCode, 2)
        XCTAssertTrue(output.contains("Invalid trace selector: '*'"))
    }

    func testOmegaDemoTraceExamplesPrintsSelectorExamples() {
        var output = ""
        let exitCode = runOmegaDemo(arguments: ["demo", "--trace-examples"]) { text in
            output += text
        }

        XCTAssertEqual(exitCode, 0)
        XCTAssertTrue(output.contains("Trace selector examples:"))
        XCTAssertTrue(output.contains("--trace '*.{net,io}'"))
    }

    func testOmegaDemoRemovedTraceLinesOptionIsRejected() {
        var output = ""
        let exitCode = runOmegaDemo(arguments: ["demo", "--trace-lines"]) { text in
            output += text
        }

        XCTAssertEqual(exitCode, 2)
        XCTAssertTrue(output.contains("[error] [cli] unknown option --trace-lines"))
    }

    func testOmegaDemoTraceTimestampsUseFractionalSeconds() {
        var output = ""
        let exitCode = runOmegaDemo(arguments: ["demo", "--trace", ".app", "--trace-timestamps"]) { text in
            output += text
        }

        XCTAssertEqual(exitCode, 0)
        XCTAssertRegex(output, #"\[omega\] \[[0-9]+\.[0-9]{6}\] \[app\] cli processing enabled, use --trace for options"#)
    }

    func testOmegaDemoTraceFilesIncludesSourceLocation() {
        var output = ""
        let exitCode = runOmegaDemo(arguments: ["demo", "--trace", ".app", "--trace-files"]) { text in
            output += text
        }

        XCTAssertEqual(exitCode, 0)
        XCTAssertRegex(output, #"\[omega\] \[app\] \[[A-Za-z0-9_]+\.swift:[0-9]+\] cli processing enabled, use --trace for options"#)
    }

    func testOmegaDemoTraceFunctionsIncludesSourceFunction() {
        var output = ""
        let exitCode = runOmegaDemo(arguments: ["demo", "--trace", ".app", "--trace-functions"]) { text in
            output += text
        }

        XCTAssertEqual(exitCode, 0)
        XCTAssertRegex(output, #"\[omega\] \[app\] \[[A-Za-z0-9_]+\.swift:[0-9]+:[^\]]+\] cli processing enabled, use --trace for options"#)
    }

    func testOmegaDemoBraceSelectorFiltersChannels() {
        var output = ""
        let exitCode = runOmegaDemo(arguments: ["demo", "--trace", "*.{net,io}"]) { text in
            output += text
        }

        XCTAssertEqual(exitCode, 0)
        XCTAssertTrue(output.contains("[alpha] [net] testing..."))
        XCTAssertTrue(output.contains("beta trace test on channel 'io'"))
        XCTAssertFalse(output.contains("[alpha] [cache] testing..."))
    }

    private func captureStdout(_ body: () -> Int) -> (Int, String) {
        let pipe = Pipe()
        let original = dup(STDOUT_FILENO)
        fflush(stdout)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

        let exitCode = body()

        fflush(stdout)
        dup2(original, STDOUT_FILENO)
        close(original)
        pipe.fileHandleForWriting.closeFile()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        pipe.fileHandleForReading.closeFile()
        return (exitCode, String(decoding: data, as: UTF8.self))
    }

    private func XCTAssertRegex(_ text: String,
                                _ pattern: String,
                                file: StaticString = #filePath,
                                line: UInt = #line) {
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let match = try? NSRegularExpression(pattern: pattern).firstMatch(in: text, range: range)
        XCTAssertNotNil(match, "expected output to match regex: \(pattern)\nactual: \(text)", file: file, line: line)
    }
}
