# Swift Language Conventions

## Mission

Refactor `ktools-swift/` so the public `kcli` and `ktrace` APIs follow Swift
API design conventions more consistently instead of carrying obvious Java/C++
surface patterns.

Preserve behavior and capability, but make the public API feel intentionally
Swift.

## Required Reading

- `../ktools/AGENTS.md`
- `AGENTS.md`
- `README.md`
- `kcli/AGENTS.md`
- `kcli/README.md`
- `kcli/src/Sources/Kcli/Parser.swift`
- `kcli/src/Sources/Kcli/InlineParser.swift`
- `kcli/src/Sources/Kcli/HandlerTypes.swift`
- `ktrace/AGENTS.md`
- `ktrace/README.md`
- `ktrace/src/Sources/Ktrace/Ktrace.swift`
- `../ktools-cpp/kcli/README.md`
- `../ktools-cpp/kcli/docs/behavior.md`
- `../ktools-cpp/kcli/cmake/tests/kcli_api_cases.cpp`
- `../ktools-cpp/ktrace/README.md`
- `../ktools-cpp/ktrace/include/ktrace.hpp`
- `../ktools-cpp/ktrace/src/ktrace/cli.cpp`

## Primary Goals

- Audit the public API for Java-style `get*` names and other imported naming
  that should become more Swifty.
- Revisit the parse entrypoints so the throwing path reads like Swift rather
  than preserving `parseOrThrow(...)` purely for cross-language symmetry.
- Revisit public method names, argument labels, and helper spellings such as
  `addTraceLogger`, `getNamespace`, `getOutputOptions`, `getNamespaces`,
  `getChannels`, `makeInlineParser`, and `traceChanged`.
- Prefer properties over trivial `get*` methods where that materially improves
  the public API.
- Update docs, demos, and tests so they demonstrate the final Swift surface.

## Scope

### `kcli`

- Refactor the public parser and inline-parser APIs toward Swift API design
  guidelines.
- Keep call sites readable with good argument labels rather than just renaming
  symbols mechanically.
- Update README examples and tests so they exercise the final Swift API.

### `ktrace`

- Refactor the public logger and trace-source APIs toward Swift API design
  guidelines.
- Revisit whether `TraceColors` and related helpers expose the right public
  names for Swift callers.
- Make sure the `kcli` integration examples use the final Swift `kcli` API.

## Rules

- Do not keep a permanent second API surface just to preserve translated names.
- Preserve behavior, validation rules, and demo topology.
- Keep parity with the C++ behavior contract while making the Swift surface
  more native.
- Favor clear, reviewable API cleanup over a broad unrelated rewrite.

## Validation

- `cd ktools-swift/kcli/src && swift test`
- `cd ktools-swift/kcli/demo && swift test`
- `cd ktools-swift/ktrace/src && swift test`
- `cd ktools-swift/ktrace/demo && swift test`
- Run the demo commands listed in each component README.

## Done When

- The public Swift APIs feel designed for Swift call sites.
- Public docs and tests no longer center obviously imported `get*` and
  `OrThrow` naming.
- `kcli` and `ktrace` docs, demos, and tests all use the same final Swift API
  consistently.
