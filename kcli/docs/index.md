# Kcli Swift Documentation

`kcli` is a compact Swift SDK for executable startup and command-line parsing.
It keeps the same behavior model as the C++ implementation:

- parse first
- fail early on invalid input
- do not run handlers until the full command line validates
- preserve the caller's argument list
- support grouped inline roots such as `--trace-*` and `--config-*`

## Start Here

- [API guide](api.md)
- [Parsing behavior](behavior.md)
- [Examples](examples.md)

## Typical Flow

```swift
import Kcli

let parser = Parser()
var build = try InlineParser("--build")

try build.setHandler("-profile",
                     handler: handleProfile,
                     description: "Set build profile.")

try parser.addInlineParser(build)
try parser.addAlias("-v", target: "--verbose")
try parser.setHandler("--verbose",
                      handler: handleVerbose,
                      description: "Enable verbose logging.")

try parser.parseOrThrow(CommandLine.arguments)
```

## Core Concepts

`Parser`

- Owns top-level handlers, aliases, inline parser registrations, and the parse pass.

`InlineParser`

- Defines one inline root namespace such as `--alpha`, `--trace`, or `--build`.

`HandlerContext`

- Exposes the effective option, command, root, and value tokens seen by the handler after alias expansion.

`CliError`

- Used by `parseOrThrow()` to surface invalid CLI input and handler failures.

## Which Entry Point Should I Use?

Use `parseOrExit()` when:

- you are in a normal executable entrypoint
- invalid CLI input should print a standardized error and exit with code `2`
- you do not need custom formatting or recovery

Use `parseOrThrow()` when:

- you want custom error formatting
- you want custom exit codes
- you want to intercept and test parse failures directly

## Build And Explore

```bash
cd src
swift test
swift run kcli-demo-core --alpha-message hello
swift run kcli-demo-omega --build
```

## Working References

If you want complete compiling examples, start with:

- [`../src/Sources/KcliDemoAlpha/KcliDemoAlpha.swift`](../src/Sources/KcliDemoAlpha/KcliDemoAlpha.swift)
- [`../src/Sources/KcliDemoCore/main.swift`](../src/Sources/KcliDemoCore/main.swift)
- [`../src/Sources/KcliDemoOmega/main.swift`](../src/Sources/KcliDemoOmega/main.swift)
- [`../src/Tests/KcliTests/KcliTests.swift`](../src/Tests/KcliTests/KcliTests.swift)

The public API contract lives in [`../src/Sources/Kcli/Kcli.swift`](../src/Sources/Kcli/Kcli.swift).
