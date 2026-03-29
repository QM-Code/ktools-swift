# Swift kcli Project

## Mission

Bring `ktools-swift/kcli/` up to the C++ reference standard. This is the
highest-priority structural cleanup in the stack. The current repo works, but
it is too monolithic and too noisy to serve as a strong implementation.

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

- The core library is concentrated in `kcli/src/Sources/Kcli/Kcli.swift`.
- Library tests are concentrated in `kcli/src/Tests/KcliTests/KcliTests.swift`.
- Demo support is concentrated in `kcli/demo/common/src/DemoSupport.swift`.
- The repo contains a very large amount of tracked generated output under
  `kcli/build/latest`, `kcli/src/.build`, and `kcli/demo/.build`.
- The top-level structure is harder to scan than the C++ reference because the
  real source tree is buried under build noise and large single files.

## Work Plan

1. Split the library into real modules.
- Break `Kcli.swift` into smaller files by responsibility: public API,
  model/types, normalization, registration, parse engine, and help rendering.
- Keep the public `Parser` and `InlineParser` API easy to discover.
- Avoid turning the package into a maze; use a small number of meaningful files.

2. Split the tests.
- Replace the single large test file with multiple focused test files grouped by
  API behavior, parsing rules, alias behavior, inline-root behavior, and error
  handling.
- Preserve or expand the current coverage during the split.

3. Refactor demo support.
- Break `DemoSupport.swift` into smaller pieces if the current file is carrying
  too many unrelated responsibilities.
- Preserve the bootstrap/sdk/exe demo roles and names.
- Keep the demo package easy to compare with the C++ layout even if SwiftPM
  requires some path differences.

4. Clean the repo aggressively.
- Remove tracked generated artifacts from `build/latest`, `src/.build`, and
  `demo/.build`.
- Add or tighten ignore rules so build products do not return.
- Make the hand-maintained source tree the dominant shape of the repo again.

5. Re-audit behavior against C++.
- Confirm parity for help output, alias semantics, required/optional values,
  bare inline roots, validation-before-handler execution, and error behavior.
- Add tests where the current implementation relies on implicit behavior.

6. Reconcile package/docs layout after the cleanup.
- Make sure `src/Package.swift`, `demo/Package.swift`, the README, and the file
  tree all tell the same story.
- Remove any stale documentation that reflects the monolithic layout.

## Constraints

- Preserve Swift-idiomatic usage at the call site.
- Keep the package layout understandable to a non-Swift reviewer.
- Do not trade one giant file for a large number of tiny files.

## Validation

- `cd ktools-swift/kcli && kbuild --build-latest`
- `cd ktools-swift/kcli/src && swift test`
- `cd ktools-swift/kcli/demo && swift test`
- Run the demo commands listed in `ktools-swift/kcli/README.md`

## Done When

- The library and tests are no longer monolithic.
- Generated build output no longer dominates the repo.
- The Swift repo can be read as a serious peer to the C++ reference instead of
  as a working prototype.
