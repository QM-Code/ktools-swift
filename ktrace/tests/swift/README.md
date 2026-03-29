# Swift Tests

Swift trace and demo coverage lives in the SwiftPM package under [`src/Tests/`](../../src/Tests/).

Test targets:

- `KtraceTests`: trace API, selector, and formatting coverage
- `KtraceDemoTests`: CLI integration and demo contract coverage

Run from the relevant package root when a Swift toolchain is available:

```bash
cd src
swift test --scratch-path ../build/latest/swiftpm
swift test --scratch-path ../build/latest/swiftpm --filter KtraceTests

cd ../demo
swift test --scratch-path ../build/latest/swiftpm-demo
swift test --scratch-path ../build/latest/swiftpm-demo --filter KtraceDemoTests
```
