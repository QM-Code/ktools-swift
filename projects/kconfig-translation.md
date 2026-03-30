# Swift Kconfig Translation

## Mission

Create a new `ktools-swift/kconfig/` component that matches the C++ `kconfig`
behavior while presenting a distinctly Swift API and a clear SwiftPM package
layout.

Use the lessons from `kcli` and `ktrace`: keep the public API Swift-idiomatic,
avoid shared demo layers, and keep the package and demo layout understandable
to a reviewer who is not living in Swift every day.

## Required Reading

- `../ktools/AGENTS.md`
- `AGENTS.md`
- `README.md`
- `kcli/AGENTS.md`
- `kcli/README.md`
- `ktrace/AGENTS.md`
- `ktrace/README.md`
- `projects/language-conventions.md`
- `../ktools-cpp/kconfig/README.md`
- `../ktools-cpp/kconfig/include/kconfig.hpp`
- `../ktools-cpp/kconfig/include/kconfig/json.hpp`
- `../ktools-cpp/kconfig/include/kconfig/asset.hpp`
- `../ktools-cpp/kconfig/include/kconfig/cli.hpp`
- `../ktools-cpp/kconfig/include/kconfig/store.hpp`
- `../ktools-cpp/kconfig/include/kconfig/store/fs.hpp`
- `../ktools-cpp/kconfig/include/kconfig/store/read.hpp`
- `../ktools-cpp/kconfig/include/kconfig/store/user.hpp`
- `../ktools-cpp/kconfig/cmake/tests/kconfig_json_api_test.cpp`
- `../ktools-cpp/kconfig/demo/bootstrap/README.md`
- `../ktools-cpp/kconfig/demo/sdk/alpha/README.md`
- `../ktools-cpp/kconfig/demo/sdk/beta/README.md`
- `../ktools-cpp/kconfig/demo/sdk/gamma/README.md`
- `../ktools-cpp/kconfig/demo/exe/core/README.md`
- `../ktools-cpp/kconfig/demo/exe/omega/README.md`
- `../ktools-cpp/kconfig/src/kconfig/cli.cpp`
- `../ktools-cpp/kconfig/src/kconfig/store/access.cpp`
- `../ktools-cpp/kconfig/src/kconfig/store/layers.cpp`
- `../ktools-cpp/kconfig/src/kconfig/store/read.cpp`
- `../ktools-cpp/kconfig/src/kconfig/store/bindings.cpp`

## Deliverables

- Add a new `kconfig/` component to the Swift workspace.
- Update workspace docs and `.kbuild.json` so `kconfig` joins the normal batch
  order after `kcli` and `ktrace`.
- Keep the public API Swift-idiomatic from the start.
- Keep the SwiftPM package and demo-package layout readable.

## Translation Scope

- JSON value model, parse, dump, and typed access.
- Store registry, mutability, merge, get, set, erase, and typed read helpers.
- Filesystem-backed store helpers, asset roots, and user-config flows.
- `kcli` inline parser integration for config overrides.
- `ktrace` integration for warnings, errors, and operator-facing diagnostics.

## Demo Contract

- The demo tree must be:
  - `demo/bootstrap`
  - `demo/sdk/{alpha,beta,gamma}`
  - `demo/exe/{core,omega}`
- Do not create `demo/common` or any disguised shared demo support target.
- Keep SDK demos self-contained and executable support local to the executable
  that uses it.

## Swift Rules

- Follow Swift API design guidelines from the start.
- Keep package boundaries and target names clear to non-Swift reviewers.
- Split code by responsibility rather than collecting the whole component into
  one giant source file.
- Keep source-tree build noise out of version control.

## Validation

- `cd ktools-swift/kconfig && kbuild --build-latest`
- `cd ktools-swift/kconfig && kbuild --build-demos`
- `cd ktools-swift/kconfig/src && swift test`
- `cd ktools-swift/kconfig/demo && swift test`
- Run the demo commands documented in `ktools-swift/kconfig/README.md`.

## Done When

- `ktools-swift/kconfig/` exists as a normal workspace component.
- The public API feels designed for Swift call sites.
- The package and demo layout are clear and explicit.
- Demo code is self-contained and free of shared demo layers.
