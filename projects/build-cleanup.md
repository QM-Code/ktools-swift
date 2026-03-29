# Swift Build Cleanup Project

## Mission

Add a Swift-specific residual checker to `kbuild`, then make the Swift
workspace stop generating SwiftPM artifacts outside `build/`.

This task spans both `ktools-swift/` and the sibling shared build repo
`../kbuild/`.

## Required Reading

- `../ktools/AGENTS.md`
- `AGENTS.md`
- `README.md`
- `../kbuild/AGENTS.md`
- `../kbuild/README.md`
- `../kbuild/docs/swift_backend.md`
- `../kbuild/libs/kbuild/residual_ops.py`
- `../kbuild/libs/kbuild/backend_ops.py`
- `../kbuild/libs/kbuild/swift_backend.py`
- `../kbuild/tests/test_java_residuals.py`
- `kcli/AGENTS.md`
- `kcli/README.md`
- `ktrace/AGENTS.md`
- `ktrace/README.md`

## Current Gaps

- `kbuild` does not yet have a Swift backend residual checker.
- The Swift workspace currently carries SwiftPM build output outside `build/`,
  notably `src/.build` and `demo/.build`.
- The build and validation flow needs to be corrected so SwiftPM output stays
  under the staged `build/<slot>/swiftpm*` directories.

## Work Plan

1. Add the Swift residual checker in `kbuild`.
- Follow the Java checker structure, but make it Swift-specific.
- Detect real SwiftPM build residuals outside `build/`, especially stray
  `.build/` directories and equivalent generated package output.
- Keep the checker narrow and tied to actual SwiftPM build behavior.

2. Add focused `kbuild` tests.
- Add tests for build refusal and `--git-sync` refusal when Swift build
  residuals appear outside `build/`.
- Add a positive case showing that staged output inside `build/` is allowed.

3. Audit the actual Swift workspace build flow.
- Build `kcli/` and `ktrace/` through normal `kbuild` entrypoints.
- Identify where SwiftPM is still writing `.build/` output into the source
  tree.
- Fix the build/test/demo flow so staged paths under `build/` are used
  consistently.

4. Clean up real residuals.
- Remove existing SwiftPM build artifacts from the source tree where they do
  not belong.
- Tighten ignore rules only after the actual generation path is fixed.

5. Keep docs aligned.
- Update `kbuild` docs if the checker needs backend-specific mention.
- Update local docs if they currently normalize source-tree SwiftPM output.

## Constraints

- Do not accept source-tree `.build/` output as normal.
- Prefer configuring SwiftPM correctly over ignoring the results.
- Keep the checker and tests precise and easy to justify.

## Validation

- Run the new Swift residual tests in `../kbuild`
- `cd ktools-swift && kbuild --batch --build-latest`
- `cd ktools-swift/kcli/src && swift test`
- `cd ktools-swift/ktrace/src && swift test`
- Confirm the workspace stays free of SwiftPM build output outside `build/`

## Done When

- `kbuild` rejects Swift residuals outside `build/`.
- The Swift workspace no longer generates those residuals in normal use.
- SwiftPM output is staged under `build/` instead of leaking into the repo
  tree.
