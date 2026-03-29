# Swift kcli Project

## Mission

Make `ktools-swift/kcli/` clean, reviewable, and free of build noise while
preserving the current split between the library package and demo package.

## Required Reading

- `../ktools/AGENTS.md`
- `AGENTS.md`
- `kcli/AGENTS.md`
- `kcli/README.md`
- `kcli/src/Package.swift`
- `kcli/demo/Package.swift`
- `../ktools-cpp/kcli/README.md`
- `../ktools-cpp/kcli/docs/behavior.md`
- `../ktools-cpp/kcli/cmake/tests/kcli_api_cases.cpp`

## Current Gaps

- A substantial amount of generated output is still tracked under
  `kcli/build/latest`, `kcli/src/.build`, `kcli/demo/.build`, and staged demo
  build trees.
- The demo package should be re-audited as contract material alongside the
  library package.
- README/docs/package metadata should be checked so they describe the current
  split structure directly.
- The demo common layer is now split across multiple files and should stay
  coherent instead of drifting into another hidden monolith.

## Work Plan

1. Clean the repo aggressively.
- Remove tracked generated artifacts from `build/latest`, `src/.build`,
  `demo/.build`, and staged demo build trees.
- Tighten ignore rules so build products do not return.

2. Re-audit behavior against C++.
- Verify help output, alias semantics, required/optional value handling, bare
  inline roots, double-dash rejection, validation-before-handler execution, and
  error behavior against the C++ docs/tests.
- Add focused tests where behavior is still implicit.

3. Treat the demo package as part of the contract.
- Run and review demo package tests and CLI entrypoints, not just library
  tests.
- Confirm that bootstrap/sdk/exe roles and naming remain aligned with C++.

4. Reconcile docs and package layout.
- Make sure `src/Package.swift`, `demo/Package.swift`, `README.md`, and the
  file tree all tell the same story.
- Remove any stale wording that reflects an older layout.

5. Keep demo support focused.
- Review the current `demo/common/src/*.swift` split for clarity.
- Avoid letting one demo-support file absorb unrelated responsibilities.

## Constraints

- Preserve Swift-idiomatic usage at the call site.
- Keep the package layout understandable to a non-Swift reviewer.
- Prefer a small number of clear files over another monolith or a maze of tiny
  ones.

## Validation

- `cd ktools-swift/kcli && kbuild --build-latest`
- `cd ktools-swift/kcli/src && swift test`
- `cd ktools-swift/kcli/demo && swift test`
- Run the demo commands listed in `ktools-swift/kcli/README.md`

## Done When

- Generated build output no longer dominates the repo.
- Library tests and demo package checks together cover the contract.
- Docs and package layout match the current source tree cleanly.
