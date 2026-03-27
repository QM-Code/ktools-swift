# Swift Package

`src/` contains the standalone SwiftPM implementation of `ktrace`.

## Targets

Library targets:

- `Ktrace`
- `KtraceDemoAlpha`
- `KtraceDemoBeta`
- `KtraceDemoGamma`
- `KtraceDemoSupport`

Executable targets:

- `ktrace-demo-bootstrap`
- `ktrace-demo-core`
- `ktrace-demo-omega`

Test targets:

- `KtraceTests`
- `KtraceDemoTests`

## Source Layout

- `Sources/Ktrace/`: public trace and logging library
- `Sources/KtraceDemoAlpha/`: alpha SDK trace source
- `Sources/KtraceDemoBeta/`: beta SDK trace source
- `Sources/KtraceDemoGamma/`: gamma SDK trace source
- `Sources/KtraceDemoSupport/`: reusable demo assembly
- `Sources/KtraceDemoBootstrap/`: import/integration smoke test
- `Sources/KtraceDemoCore/`: executable demo matching `demo/exe/core`
- `Sources/KtraceDemoOmega/`: executable demo matching `demo/exe/omega`
- `Tests/`: API, selector, and demo coverage

## Typical Commands

```bash
cd src
swift test
swift run ktrace-demo-bootstrap
swift run ktrace-demo-core --trace '*.*'
swift run ktrace-demo-omega --trace '*.{net,io}'
```
