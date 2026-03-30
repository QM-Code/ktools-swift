# Swift Demos

`demo/` is a standalone SwiftPM package. Demo sources and demo tests live here to match the C++ component layout. Direct SwiftPM commands should stage scratch output under `../build/latest/swiftpm-demo`.

Each SDK demo is self-contained. The executable demos compose those SDK entities locally rather than through a shared demo support layer.

Executable demo products:

- `kcli-demo-bootstrap`
- `kcli-demo-core`
- `kcli-demo-omega`

SDK demo products:

- `KcliDemoAlpha`
- `KcliDemoBeta`
- `KcliDemoGamma`

Useful commands:

```bash
cd demo
swift run --scratch-path ../build/latest/swiftpm-demo kcli-demo-bootstrap
swift run --scratch-path ../build/latest/swiftpm-demo kcli-demo-core --alpha-message hello
swift run --scratch-path ../build/latest/swiftpm-demo kcli-demo-core --output stdout
swift run --scratch-path ../build/latest/swiftpm-demo kcli-demo-omega --beta-workers 8
swift run --scratch-path ../build/latest/swiftpm-demo kcli-demo-omega --newgamma-tag prod
swift run --scratch-path ../build/latest/swiftpm-demo kcli-demo-omega --build
swift run --scratch-path ../build/latest/swiftpm-demo kcli-demo-omega -a
swift run --scratch-path ../build/latest/swiftpm-demo kcli-demo-omega -b release
swift test --scratch-path ../build/latest/swiftpm-demo
```
