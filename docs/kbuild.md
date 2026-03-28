# `kbuild` In `ktools-swift`

The Swift workspace uses the shared `kbuild` command model for workspace
operations.

## Current Status

- the checked-out workspace does not currently contain a separate `kbuild/`
  implementation directory
- the documented entrypoint is the shared `kbuild` command on `PATH`
- Swift-specific workspace notes should stay aligned with the shared `kbuild`
  behavior contract
