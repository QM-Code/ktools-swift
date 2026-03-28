# Swift Package

`src/` contains the standalone SwiftPM library package for `ktrace`.

## Targets

Library targets:

- `Ktrace`

Test targets:

- `KtraceTests`

## Source Layout

- `Sources/Ktrace/`: public trace and logging library
- `Tests/`: API and selector coverage
- `../demo/`: separate SwiftPM demo package and demo tests

## Typical Commands

```bash
cd src
swift test
```
