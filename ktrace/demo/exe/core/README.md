# Core Demo

Basic local-plus-imported tracing showcase for `Ktrace` and the alpha demo SDK.

This demo shows:

- executable-local tracing defined with a local `TraceLogger`
- imported SDK tracing added through `AlphaSdk.traceLogger`
- logger-managed selector state and output formatting
- local CLI integration through `parser.addInlineParser(logger.inlineParser(for: localTraceLogger))`
- bare-root trace help with `--trace`

Implementation:

- support logic: [`support/DemoCore.swift`](support/DemoCore.swift)
- executable entrypoint: [`src/main.swift`](src/main.swift)

Run from [`demo/`](../../README.md):

```bash
swift run --scratch-path ../build/latest/swiftpm-demo ktrace-demo-core --trace
swift run --scratch-path ../build/latest/swiftpm-demo ktrace-demo-core --trace '*.*'
swift run --scratch-path ../build/latest/swiftpm-demo ktrace-demo-core --trace '.*' --trace-timestamps
```
