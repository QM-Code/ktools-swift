# Core Demo

Basic integration showcase for `Kcli` plus the alpha demo parser.

This demo shows:

- a local executable parser with top-level handlers and aliases
- one imported SDK parser (`--alpha`)
- help behavior for a bare inline root
- value and optional-value handling through the imported parser

Run from [`demo/`](../../README.md):

```bash
swift run kcli-demo-core --alpha
swift run kcli-demo-core --alpha-message hello
swift run kcli-demo-core --output stdout
swift run kcli-demo-core -a
```
