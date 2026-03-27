# Swift Tests

Swift parser and demo coverage lives in the SwiftPM package under [`src/Tests/`](../../src/Tests/).

Test targets:

- `KcliTests`: parser API and behavior coverage
- `KcliDemoTests`: demo wiring and CLI contract coverage

Run from the package root when a Swift toolchain is available:

```bash
cd src
swift test
swift test --filter KcliTests
swift test --filter KcliDemoTests
```
