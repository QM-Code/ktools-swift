# Swift Demos

`demo/` is a standalone SwiftPM package. Demo sources, demo tests, and demo build output live here to match the C++ repo layout.

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
swift run ktrace-demo-bootstrap
swift run ktrace-demo-core --trace
swift run ktrace-demo-core --trace '*.*'
swift run ktrace-demo-omega --trace '*.{net,io}'
swift run ktrace-demo-omega --trace-examples
swift run ktrace-demo-omega --trace-namespaces
swift run ktrace-demo-omega --trace-channels
swift run ktrace-demo-omega --trace-colors
swift run ktrace-demo-omega --trace-files --trace '.app'
swift run ktrace-demo-omega --trace-functions --trace '.app'
swift run ktrace-demo-omega --trace-timestamps --trace '.app'
swift test
```
