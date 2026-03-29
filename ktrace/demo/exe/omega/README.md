# Omega Demo

Full-featured trace showcase for `Ktrace` plus the alpha, beta, and gamma demo SDKs.

This demo exercises:

- local executable channels plus imported SDK `TraceLogger`s
- selector matching across multiple namespaces
- `--trace-files`, `--trace-functions`, and `--trace-timestamps`
- wildcard and brace-selector coverage across nested channels
- informational trace options such as `--trace-examples` and `--trace-namespaces`

Implementation:

- support logic: [`support/DemoOmega.swift`](support/DemoOmega.swift)
- executable entrypoint: [`src/main.swift`](src/main.swift)

Run from [`demo/`](../../README.md):

```bash
swift run ktrace-demo-omega --trace '*.*'
swift run ktrace-demo-omega --trace '*.{net,io}'
swift run ktrace-demo-omega --trace-examples
swift run ktrace-demo-omega --trace-files --trace '*.*'
swift run ktrace-demo-omega --trace-functions --trace '*.*'
swift run ktrace-demo-omega --trace-timestamps --trace '*.*'
```
