# Swift Demos

The Swift demos are implemented as SwiftPM products under [`src/`](../src/README.md), while the `demo/` directory keeps the same layout used by the C++ repo.

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
cd src
swift run kcli-demo-bootstrap
swift run kcli-demo-core --alpha-message hello
swift run kcli-demo-core --output stdout
swift run kcli-demo-omega --beta-workers 8
swift run kcli-demo-omega --newgamma-tag prod
swift run kcli-demo-omega --build
swift run kcli-demo-omega -a
swift run kcli-demo-omega -b release
```
