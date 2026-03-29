# Swift ktrace Project

## Mission

Make `ktools-swift/ktrace/` clean, parity-checked, and free of build noise
while preserving the current split between the library package and demo
package.

## Required Reading

- `../ktools/AGENTS.md`
- `AGENTS.md`
- `ktrace/AGENTS.md`
- `ktrace/README.md`
- `ktrace/src/Package.swift`
- `ktrace/demo/Package.swift`
- `../ktools-cpp/ktrace/README.md`
- `../ktools-cpp/ktrace/include/ktrace.hpp`
- `../ktools-cpp/ktrace/src/ktrace/cli.cpp`
- `../ktools-cpp/ktrace/cmake/tests/ktrace_channel_semantics_test.cpp`
- `../ktools-cpp/ktrace/cmake/tests/ktrace_format_api_test.cpp`
- `../ktools-cpp/ktrace/cmake/tests/ktrace_log_api_test.cpp`

## Current Gaps

- Empty leftover `ktrace/demo/common/` directories are still present and should
  be removed.
- `src/Sources/Ktrace/Ktrace.swift` still carries a large amount of library
  behavior in one file.
- The demo package should be re-audited as contract material alongside the
  library package.
- README/docs/package metadata should be checked so they describe the current
  split structure directly and do not normalize source-tree build noise.

## Work Plan

1. Finish the demo cleanup cleanly.
- Remove the now-empty `ktrace/demo/common/` leftovers.
- Keep the demo package readable as bootstrap/sdk/exe entities with local
  composition support where needed.

2. Revisit the main library file.
- Review whether `src/Sources/Ktrace/Ktrace.swift` should be split into smaller,
  coherent pieces.
- Keep the public Swift package easy to follow for a non-Swift reviewer.

3. Re-audit behavior against C++.
- Verify channel registration, selector parsing, output options, operational
  logging, `traceChanged(...)`, and logger-bound inline parser behavior
  against the C++ contract.
- Add focused tests where behavior is still implicit.

4. Treat the demo package as part of the contract.
- Run and review demo package tests and CLI entrypoints, not just library
  tests.
- Confirm that bootstrap/sdk/exe roles and naming remain aligned with C++.

5. Reconcile docs and package layout.
- Make sure `src/Package.swift`, `demo/Package.swift`, `README.md`, and the
  file tree all tell the same story.
- Remove any stale wording that reflects an older layout.

## Constraints

- Preserve Swift-idiomatic usage at the call site.
- Keep the package layout understandable to a non-Swift reviewer.
- Keep the demos readable as separate entities that happen to work together.

## Validation

- `cd ktools-swift/ktrace && kbuild --build-latest`
- `cd ktools-swift/ktrace/src && swift test`
- `cd ktools-swift/ktrace/demo && swift test`
- Run the demo commands listed in `ktools-swift/ktrace/README.md`

## Done When

- Leftover demo-common directories are gone.
- The main library file is no longer carrying more responsibility than it
  should.
- Library tests and demo checks together cover the contract cleanly.
