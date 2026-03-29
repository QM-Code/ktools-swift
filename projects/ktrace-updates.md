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

- A substantial amount of generated output is still tracked under
  `ktrace/build/latest`, `ktrace/src/.build`, `ktrace/demo/.build`, and staged
  demo build trees.
- `ktrace/demo/common/` and the `KtraceDemoSupport` target exist and are the
  wrong demo structure.
- The demo package should be re-audited as contract material alongside the
  library package.
- README/docs/package metadata should be checked so they describe the current
  split structure directly.

## Work Plan

1. Clean the repo aggressively.
- Remove tracked generated artifacts from `build/latest`, `src/.build`,
  `demo/.build`, and staged demo build trees.
- Tighten ignore rules so build products do not return.

2. Eliminate shared demo code.
- Remove `ktrace/demo/common/`.
- Remove the `KtraceDemoSupport` shared demo target.
- Make `demo/sdk/alpha`, `demo/sdk/beta`, and `demo/sdk/gamma` self-contained.
- Keep bootstrap-specific logic under `demo/bootstrap/`.
- Keep executable composition logic under `demo/exe/core/` and
  `demo/exe/omega/`.
- Do not replace the current shared support target with another disguised demo
  common layer.

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

- Generated build output no longer dominates the repo.
- Shared demo code is gone from the Swift demo package.
- Library tests and demo checks together cover the contract cleanly.
