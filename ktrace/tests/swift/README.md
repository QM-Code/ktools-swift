# Swift Tests

Swift trace and demo coverage lives in the SwiftPM package under [`src/Tests/`](../../src/Tests/).

Test targets:

- `KtraceTests`: trace API, selector, and formatting coverage
- `KtraceDemoTests`: CLI integration and demo contract coverage

Run from the package root when a Swift toolchain is available:

```bash
cd src
swift test
swift test --filter KtraceTests
swift test --filter KtraceDemoTests
```
