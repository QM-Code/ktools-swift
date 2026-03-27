# ktools-swift

`ktools-swift/` is the Swift workspace for the broader ktools ecosystem.

It is the root entrypoint for Swift implementations of the ktools libraries.

## Current Contents

This workspace currently contains:

- `kcli/`
- `ktrace/`

## Build Model

Use the relevant child repo when building or testing a specific Swift implementation.

Use the `kbuild` command as the Swift workspace build entrypoint.

Typical commands:

```bash
kbuild --batch --build-latest
kbuild --batch --clean-latest
```

## Where To Go Next

For concrete Swift API and implementation details, use the docs in the relevant child repo.

Current implementation:

- [kcli](kcli)
- [ktrace](ktrace)
