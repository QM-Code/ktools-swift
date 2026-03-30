# Swift Conventions Refactor

## Mission

Refactor `ktools-swift/` so that `kcli` and `ktrace` preserve the shared ktools
behavior while reading like Swift libraries and packages designed for Swift
users, not like C++ APIs translated into Swift surface syntax.

Assume a fresh agent should perform a full audit and complete refactor pass.

## Scope

This brief applies to:

- `ktools-swift/kcli/`
- `ktools-swift/ktrace/`
- `ktools-swift/README.md`
- `ktools-swift/projects/updates.md`

## Required Reading

- `../ktools/AGENTS.md`
- `AGENTS.md`
- `README.md`
- `projects/updates.md`
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
- the matching C++ docs and tests for the same behavior

## Core Principle

Preserve semantics, not C++-shaped Swift.

Preserve:

- parser and selector behavior
- alias and inline-root behavior
- help and error behavior
- demo contract behavior

Do not preserve:

- argument labels or method names that feel translated instead of Swift-native
- unnecessary reference semantics
- monolithic source files kept only because the C++ code was monolithic
- shared demo support layers such as `demo/common/`

## Assignment Model

A fresh agent should assume:

- this is a full public-API and internal-layout audit
- `projects/updates.md` is active context and must be read
- both `kcli` and `ktrace` are in scope
- package layout and demo ownership are in scope

## Public API Refactor Goals

Prefer Swift-native surfaces:

- clear argument labels
- names that read naturally at the call site
- value semantics where appropriate
- `struct`, `enum`, and protocol-oriented design where it clarifies ownership
- explicit and readable package/module boundaries

`kcli` should feel like a Swift parser library.
`ktrace` should feel like a Swift tracing/logging library.

## Internal Refactor Goals

Review and refactor:

- monolithic source files
- unclear ownership splits
- unnecessary class/reference usage
- translated control-flow artifacts
- demo support layout

Prefer:

- cohesive files by responsibility
- local support owned by the demo that uses it
- Swift-native type design
- explicit package boundaries

## Demo, Test, And Docs Expectations

- `demo/common/` is not acceptable
- bootstrap, SDK, and executable demos must remain explicit
- executable support code should stay local to the executable that owns it
- docs and package manifests must describe the current layout directly
- parity behaviors must be covered explicitly across library tests and demo
  package checks

## Validation

At minimum:

- `cd ktools-swift/kcli && kbuild --build-latest`
- `cd ktools-swift/kcli/src && swift test`
- `cd ktools-swift/kcli/demo && swift test`
- `cd ktools-swift/ktrace && kbuild --build-latest`
- `cd ktools-swift/ktrace/src && swift test`
- `cd ktools-swift/ktrace/demo && swift test`
- run the documented demo commands

## Done When

- the public API reads naturally to a Swift reviewer
- package/source layout is easy to follow
- `demo/common/` is gone and no disguised replacement exists
- demo ownership is explicit
- docs, manifests, tests, and source layout all describe the same current
  structure
- validation passes

## Final Checklist

- read all required docs and `projects/updates.md`
- audit the entire public API and package layout
- refactor toward Swift call-site and type-system conventions
- remove shared demo support
- update tests and docs
- validate the workspace
