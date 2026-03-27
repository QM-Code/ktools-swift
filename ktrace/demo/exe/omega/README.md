# Omega Demo

Full-featured trace showcase for `Ktrace` plus the alpha, beta, and gamma demo SDKs.

This demo exercises:

- local executable channels plus imported SDK `TraceLogger`s
- selector matching across multiple namespaces
- `--trace-files`, `--trace-functions`, and `--trace-timestamps`
- wildcard and brace-selector coverage across nested channels

Run from [`src/`](../../../src/README.md):

```bash
swift run ktrace-demo-omega --trace '*.*'
swift run ktrace-demo-omega --trace '*.{net,io}'
swift run ktrace-demo-omega --trace-files --trace '*.*'
swift run ktrace-demo-omega --trace-functions --trace '*.*'
swift run ktrace-demo-omega --trace-timestamps --trace '*.*'
```
