# Karma CLI Parsing SDK

`kcli` is the Swift implementation of the ktools CLI parsing layer.

It is designed around the same two CLI shapes as the C++ implementation:

- top-level options such as `--verbose` and `--output`
- inline roots such as `--trace-*`, `--config-*`, and `--build-*`

The library exposes two main parse entry points:

- `parseOrExit(_:)` for normal executable startup
- `parseOrThrow(_:)` when callers want to intercept `CliError`

## Documentation

- [Overview and quick start](docs/index.md)
- [API guide](docs/api.md)
- [Parsing behavior](docs/behavior.md)
- [Examples](docs/examples.md)

## Quick Start

```swift
import Kcli

func handleVerbose(_ context: HandlerContext) throws {
}

func handleProfile(_ context: HandlerContext, _ value: String) throws {
}

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

parser.parseOrExit()
```

## Behavior Highlights

- The full command line is validated before any registered handler runs.
- `parseOrExit()` reports invalid CLI input to `stderr` and exits with code `2`.
- `parseOrThrow()` preserves the input arguments and throws `CliError`.
- Bare inline roots such as `--build` print inline help unless a root value is provided.
- `setHandler(..., handler: ValueHandler, ...)` registers a required-value option.
- `setOptionalValueHandler(...)` registers an optional-value option.
- Required values may consume a first token that begins with `-`.
- Literal `--` is rejected as an unknown option; it is not treated as an option terminator.

For the full parsing rules, see [docs/behavior.md](docs/behavior.md).

## Build SDK

Workspace-style build:

```bash
kbuild --build-latest
```

Direct SwiftPM flow:

```bash
cd src
swift test
cd ../demo
swift run kcli-demo-core --alpha-message hello
```

## Demos

Demo source and build files live in the `demo/` SwiftPM package, matching the C++ layout:

- Bootstrap compile/import check: [demo/bootstrap/README.md](demo/bootstrap/README.md)
- SDK demos: [demo/sdk/alpha/README.md](demo/sdk/alpha/README.md), [demo/sdk/beta/README.md](demo/sdk/beta/README.md), [demo/sdk/gamma/README.md](demo/sdk/gamma/README.md)
- Executable demos: [demo/exe/core/README.md](demo/exe/core/README.md), [demo/exe/omega/README.md](demo/exe/omega/README.md)

Useful demo commands:

```bash
cd demo
swift run kcli-demo-bootstrap
swift run kcli-demo-core --alpha
swift run kcli-demo-core --alpha-message hello
swift run kcli-demo-core --output stdout
swift run kcli-demo-omega --beta-workers 8
swift run kcli-demo-omega --newgamma-tag prod
swift run kcli-demo-omega --build
```

## Repository Layout

- Public API: `src/Sources/Kcli/Kcli.swift`
- Library tests: `src/Tests/`
- Demo package and demo tests: `demo/`
- Additional docs: `docs/`

## Coding Agents

If you are using a coding agent, paste the following prompt:

```bash
Read AGENTS.md and README.md, then inspect src/Package.swift, src/Sources/, and src/Tests/ before editing code.
```
