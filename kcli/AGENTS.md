# kcli-swift

Assume these have already been read:

- `../../ktools/AGENTS.md`
- `../AGENTS.md`

`ktools-swift/kcli/` is the Swift implementation of `kcli`.

## What This Repo Owns

This repo owns the Swift API and implementation details for `kcli`, including:

- the SwiftPM package under `src/`
- parser and inline-parser behavior
- Swift demos and tests
- repo-local build config for the Swift workspace

## Local Bootstrap

When familiarizing yourself with this repo, read:

- [README.md](README.md)
- `src/Package.swift`
- `src/Sources/*`
- `src/Tests/*`

## Build And Test Expectations

- Use `kbuild` from this repo root for workspace-style builds.
- Use `swift` directly only when validating package-local behavior.
- Keep behavior aligned with the cross-language parsing contract.
