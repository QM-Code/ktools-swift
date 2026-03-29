# Swift Demos

`demo/` is a standalone SwiftPM package. Demo sources, demo tests, and demo build output live here to match the C++ repo layout.

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
swift run kcli-demo-bootstrap
swift run kcli-demo-core --alpha-message hello
swift run kcli-demo-core --output stdout
swift run kcli-demo-omega --beta-workers 8
swift run kcli-demo-omega --newgamma-tag prod
swift run kcli-demo-omega --build
swift run kcli-demo-omega -a
swift run kcli-demo-omega -b release
swift test
```
