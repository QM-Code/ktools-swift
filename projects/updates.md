# Swift Updates

## Mission

Keep `ktools-swift/` as an explicit, parity-audited peer to the C++ reference
while preserving Swift-idiomatic APIs and the current split between the library
packages and demo packages for both `kcli` and `ktrace`.

Both Swift components still have a `demo/common/` directory on disk. Treat that
as an open architectural problem. Do not normalize it away in the brief again.

## Required Reading

- `../ktools/AGENTS.md`
- `AGENTS.md`
- `README.md`
- `kcli/AGENTS.md`
- `kcli/README.md`
- `kcli/docs/behavior.md`
- `kcli/src/Package.swift`
- `kcli/demo/Package.swift`
- `ktrace/AGENTS.md`
- `ktrace/README.md`
- `ktrace/src/README.md`
- `ktrace/tests/swift/README.md`
- `ktrace/src/Package.swift`
- `ktrace/demo/Package.swift`
- `../ktools-cpp/kcli/README.md`
- `../ktools-cpp/kcli/docs/behavior.md`
- `../ktools-cpp/kcli/cmake/tests/kcli_api_cases.cpp`
- `../ktools-cpp/ktrace/README.md`
- `../ktools-cpp/ktrace/include/ktrace.hpp`
- `../ktools-cpp/ktrace/src/ktrace/cli.cpp`
- `../ktools-cpp/ktrace/cmake/tests/ktrace_channel_semantics_test.cpp`
- `../ktools-cpp/ktrace/cmake/tests/ktrace_format_api_test.cpp`
- `../ktools-cpp/ktrace/cmake/tests/ktrace_log_api_test.cpp`

## kcli Focus

- Remove `kcli/demo/common/`. There should not be a shared demo layer here.
- Keep the current explicit demo layout: `demo/bootstrap`,
  `demo/sdk/{alpha,beta,gamma}`, and `demo/exe/{core,omega}` should stay
  readable as separate entities with local ownership.
- Do not reintroduce a shared demo support layer in disguise.
- Re-audit parser parity with C++ for help output, alias semantics, root value
  handlers, required and optional values, bare inline roots, double-dash
  rejection, and validation-before-handler execution.
- Make sure `README.md`, `docs/behavior.md`, `src/Package.swift`, and
  `demo/Package.swift` all describe the current layout directly.
- Keep library tests and demo-package tests explicit enough that a reviewer can
  map the Swift behavior back to the C++ API cases without guesswork.

## ktrace Focus

- Remove `ktrace/demo/common/`. There should not be a shared demo layer here.
- Keep executable support code obviously owned by the executable that uses it:
  `demo/exe/core/support/` and `demo/exe/omega/support/` should stay local.
- Review whether `src/Sources/Ktrace/Ktrace.swift` should be split into smaller
  coherent pieces. If so, split by responsibility rather than doing a broad
  reshuffle.
- Re-audit selector parsing, output options, operational logging,
  `traceChanged(...)`, and logger-bound inline parser behavior against the C++
  contract.
- Make sure unmatched-selector warnings, informational `--trace-*` options, and
  bootstrap/core/omega demo behavior are all covered explicitly enough for
  parity review.
- Make sure `README.md`, `src/Package.swift`, `src/README.md`, and
  `demo/Package.swift` all describe the current layout directly.

## Cross-Cutting Rules

- Preserve Swift-idiomatic usage at the call site.
- Keep the package layout understandable to a non-Swift reviewer.
- Prefer focused docs, tests, and navigability cleanup over another broad
  structural rewrite.
- Do not replace the current explicit demo ownership with a disguised shared
  layer.
- Keep source-tree build noise out of version control.

## Validation

- `cd ktools-swift/kcli && kbuild --build-latest`
- `cd ktools-swift/kcli/src && swift test`
- `cd ktools-swift/kcli/demo && swift test`
- `cd ktools-swift/ktrace && kbuild --build-latest`
- `cd ktools-swift/ktrace/src && swift test`
- `cd ktools-swift/ktrace/demo && swift test`
- Run the demo commands listed in each repo README

## Done When

- Swift `kcli` and `ktrace` are both easy to compare with the C++ reference.
- Library tests and demo-package checks together cover the contract cleanly.
- Docs, tests, and package layout all point at the same current structure.
- `demo/common/` is gone from both Swift components.
