# ktools-swift

Assume `../ktools/AGENTS.md` has already been read.

`ktools-swift/` is the Swift workspace for the ktools ecosystem.

## What This Level Owns

This workspace owns Swift-specific concerns such as:

- package/module layout
- Swift build and test flow
- Swift-specific API naming and integration patterns
- coordination across Swift tool implementations when more than one component is present

Cross-language conceptual definitions belong at the overview/spec level, not here.

## Current Scope

This workspace currently contains:

- `kcli/`
- `ktrace/`

## Guidance For Agents

1. First determine whether the task belongs at the workspace root or inside a specific implementation component.
2. Prefer making changes in the narrowest component that actually owns the behavior.
3. Use the root workspace only for Swift-workspace-wide concerns such as root docs or cross-component coordination.
4. Read the relevant child component `AGENTS.md` and `README.md` files before changing code in that component.
5. Use the `kbuild` command as the active Swift-workspace build entrypoint when validating Swift build flow changes.

## Git Sync

Use the shared `kbuild` workflow for commit/push sync from this workspace root:

```bash
kbuild --git-sync "<message>"
```

Treat that as the standard sync command unless a more local doc explicitly
overrides it.
After a coherent batch of changes in this workspace or one of its child components,
return to `ktools-swift/` and run that sync command promptly.
