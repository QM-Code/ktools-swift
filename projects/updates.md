# Swift Updates

## Mission

Keep `ktools-swift/` clean, parity-checked, and easy to review while
preserving the current split between the library packages and demo packages for
both `kcli` and `ktrace`.

## Required Reading

- `../ktools/AGENTS.md`
- `AGENTS.md`
- `README.md`
- `kcli/AGENTS.md`
- `kcli/README.md`
- `kcli/src/Package.swift`
- `kcli/demo/Package.swift`
- `ktrace/AGENTS.md`
- `ktrace/README.md`
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

- Remove `kcli/demo/common/`. There should never be a shared demo layer here.
- Keep `demo/bootstrap`, `demo/sdk/{alpha,beta,gamma}`, and
  `demo/exe/{core,omega}` readable as separate entities with local ownership.
- Re-audit parser parity with C++ for help output, alias semantics,
  required and optional values, bare inline roots, double-dash rejection, and
  validation-before-handler execution.
- Make sure `README.md`, `src/Package.swift`, and `demo/Package.swift` all
  describe the current layout directly.

## ktrace Focus

- Remove `ktrace/demo/common/`. There should never be a shared demo layer here.
- Review whether `src/Sources/Ktrace/Ktrace.swift` should be split into smaller
  coherent pieces.
- Re-audit selector parsing, output options, operational logging,
  `traceChanged(...)`, and logger-bound inline parser behavior against the C++
  contract.
- Make sure `README.md`, `src/Package.swift`, and `demo/Package.swift` all
  describe the current layout directly.

## Cross-Cutting Rules

- Preserve Swift-idiomatic usage at the call site.
- Keep the package layout understandable to a non-Swift reviewer.
- Do not replace `demo/common/` with another disguised shared demo layer.
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

- `demo/common/` is gone from both repos.
- Library tests and demo package checks together cover the contract cleanly.
- Swift `kcli` and `ktrace` are both easy to compare with C++.
