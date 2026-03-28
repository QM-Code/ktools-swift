# Swift Demos

The Swift demos are implemented as SwiftPM products under [`src/`](../src/README.md), while the `demo/` directory keeps the same layout used by the C++ repo.

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
cd src
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
```
