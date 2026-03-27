import Foundation
import XCTest
@testable import KtraceDemoSupport

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

    func testOmegaDemoBadSelectorFails() {
        var output = ""
        let exitCode = runOmegaDemo(arguments: ["demo", "--trace", "*"]) { text in
            output += text
        }

        XCTAssertEqual(exitCode, 2)
        XCTAssertTrue(output.contains("Invalid trace selector: '*'"))
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
}
