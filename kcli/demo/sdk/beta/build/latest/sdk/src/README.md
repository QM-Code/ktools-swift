# Swift Package

`src/` contains the standalone SwiftPM implementation of `kcli`.

## Targets

Library targets:

- `Kcli`
- `KcliDemoSupport`
- `KcliDemoAlpha`
- `KcliDemoBeta`
- `KcliDemoGamma`

Executable targets:

- `kcli-demo-bootstrap`
- `kcli-demo-core`
- `kcli-demo-omega`

Test targets:

- `KcliTests`
- `KcliDemoTests`

## Source Layout

- `Sources/Kcli/`: public parsing library
- `Sources/KcliDemoSupport/`: reusable demo parser assembly
- `Sources/KcliDemoAlpha/`: alpha demo inline parser
- `Sources/KcliDemoBeta/`: beta demo inline parser
- `Sources/KcliDemoGamma/`: gamma demo inline parser
- `Sources/KcliDemoBootstrap/`: import/integration smoke test
- `Sources/KcliDemoCore/`: executable demo matching `demo/exe/core`
- `Sources/KcliDemoOmega/`: executable demo matching `demo/exe/omega`
- `Tests/`: parser and demo coverage

## Typical Commands

```bash
cd src
swift test
swift run kcli-demo-bootstrap
swift run kcli-demo-core --alpha-message hello
swift run kcli-demo-omega --newgamma-tag prod
```
