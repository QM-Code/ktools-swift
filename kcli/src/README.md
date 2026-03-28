# Swift Package

`src/` contains the standalone SwiftPM library package for `kcli`.

## Targets

Library targets:

- `Kcli`

Test targets:

- `KcliTests`

## Source Layout

- `Sources/Kcli/`: public parsing library
- `Tests/`: parser coverage
- `../demo/`: separate SwiftPM demo package and demo tests

## Typical Commands

```bash
cd src
swift test
```
