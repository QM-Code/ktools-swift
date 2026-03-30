# kcli-swift

Assume these have already been read:

- `../../ktools/AGENTS.md`
- `../AGENTS.md`

`ktools-swift/kcli/` is the Swift implementation of `kcli`.

## What This Component Owns

This component owns the Swift API and implementation details for `kcli`, including:

- the library SwiftPM package under `src/`
- parser and inline-parser behavior
- the separate demo SwiftPM package under `demo/`
- component-local build config for the Swift workspace

## Local Bootstrap

When familiarizing yourself with this component, read:

- [README.md](README.md)
- `src/Package.swift`
- `demo/Package.swift`
- `src/Sources/*`
- `src/Tests/*`
- `demo/**/*`

## Build And Test Expectations

- Use `kbuild` from this component root for workspace-style builds.
- Use `swift` directly only when validating package-local behavior.
- Keep behavior aligned with the cross-language parsing contract.

After a coherent batch of changes in `ktools-swift/kcli/`, return to the
`ktools-swift/` workspace root and run `kbuild --git-sync "<message>"`.
