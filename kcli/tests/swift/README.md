# Swift Tests

Swift parser coverage lives in [`src/Tests/`](../../src/Tests/). Demo wiring coverage lives in
[`demo/Tests/`](../../demo/Tests/).

Test targets:

- `KcliTests`: parser API and behavior coverage
- `KcliDemoTests`: demo wiring and CLI contract coverage

Run from the relevant package root when a Swift toolchain is available:

```bash
cd src
swift test --scratch-path ../build/latest/swiftpm
swift test --scratch-path ../build/latest/swiftpm --filter KcliTests

cd ../demo
swift test --scratch-path ../build/latest/swiftpm-demo
swift test --scratch-path ../build/latest/swiftpm-demo --filter KcliDemoTests
```
