# Core Demo

Basic local-plus-imported tracing showcase for `Ktrace` and the alpha demo SDK.

This demo shows:

- executable-local tracing defined with a local `TraceLogger`
- imported SDK tracing added through `AlphaSdk.getTraceLogger()`
- logger-managed selector state and output formatting
- local CLI integration through `parser.addInlineParser(logger.makeInlineParser(localTraceLogger))`
- bare-root trace help with `--trace`

Run from [`demo/`](../../README.md):

```bash
swift run ktrace-demo-core --trace
swift run ktrace-demo-core --trace '*.*'
swift run ktrace-demo-core --trace '.*' --trace-timestamps
```
