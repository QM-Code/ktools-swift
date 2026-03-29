# Omega Demo

Full-featured CLI integration showcase for `Kcli` plus the alpha, beta, gamma, and build demo parsers.

This demo exercises:

- multiple imported inline roots in one executable
- local root renaming (`--gamma` to `--newgamma`)
- top-level aliases that target inline options
- bare-root help output for `--build`

Run from [`demo/`](../../README.md):

```bash
swift run --scratch-path ../build/latest/swiftpm-demo kcli-demo-omega --beta-workers 8
swift run --scratch-path ../build/latest/swiftpm-demo kcli-demo-omega --newgamma-tag prod
swift run --scratch-path ../build/latest/swiftpm-demo kcli-demo-omega --build
swift run --scratch-path ../build/latest/swiftpm-demo kcli-demo-omega -a
swift run --scratch-path ../build/latest/swiftpm-demo kcli-demo-omega -b release
```
