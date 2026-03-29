# ktrace-swift

Assume these have already been read:

- `../../ktools/AGENTS.md`
- `../AGENTS.md`

`ktools-swift/ktrace/` is the Swift implementation of `ktrace`.

## What This Repo Owns

This repo owns the Swift API and implementation details for `ktrace`, including:

- the library SwiftPM package under `src/`
- selector parsing and logger runtime behavior
- `kcli` integration for `--trace-*`
- the separate demo SwiftPM package under `demo/`

## Local Bootstrap

When familiarizing yourself with this repo, read:

- [README.md](README.md)
- `src/Package.swift`
- `demo/Package.swift`
- `src/Sources/*`
- `src/Tests/*`
- `demo/**/*`

## Build And Test Expectations

- Use `kbuild` from this repo root for workspace-style builds.
- Prefer validating behavior through demo launchers and test coverage.
- Keep the CLI integration contract aligned with the cross-language `ktrace` docs.

After a coherent batch of changes in `ktools-swift/ktrace/`, return to the
`ktools-swift/` workspace root and run `kbuild --git-sync "<message>"`.
