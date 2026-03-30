# Swift Demos

`demo/` is a standalone SwiftPM package. Demo sources and demo tests live here to match the C++ component layout. Direct SwiftPM commands should stage scratch output under `../build/latest/swiftpm-demo`.

Executable support code lives with the executable that owns it:

- `exe/core/support/DemoCore.swift`
- `exe/omega/support/DemoOmega.swift`

Executable demo products:

- `ktrace-demo-bootstrap`
- `ktrace-demo-core`
- `ktrace-demo-omega`

SDK demo products:

- `KtraceDemoAlpha`
- `KtraceDemoBeta`
- `KtraceDemoGamma`

Useful commands:

```bash
cd demo
swift run --scratch-path ../build/latest/swiftpm-demo ktrace-demo-bootstrap
swift run --scratch-path ../build/latest/swiftpm-demo ktrace-demo-core --trace
swift run --scratch-path ../build/latest/swiftpm-demo ktrace-demo-core --trace '*.*'
swift run --scratch-path ../build/latest/swiftpm-demo ktrace-demo-omega --trace '*.{net,io}'
swift run --scratch-path ../build/latest/swiftpm-demo ktrace-demo-omega --trace-examples
swift run --scratch-path ../build/latest/swiftpm-demo ktrace-demo-omega --trace-namespaces
swift run --scratch-path ../build/latest/swiftpm-demo ktrace-demo-omega --trace-channels
swift run --scratch-path ../build/latest/swiftpm-demo ktrace-demo-omega --trace-colors
swift run --scratch-path ../build/latest/swiftpm-demo ktrace-demo-omega --trace-files --trace '.app'
swift run --scratch-path ../build/latest/swiftpm-demo ktrace-demo-omega --trace-functions --trace '.app'
swift run --scratch-path ../build/latest/swiftpm-demo ktrace-demo-omega --trace-timestamps --trace '.app'
swift test --scratch-path ../build/latest/swiftpm-demo
```
