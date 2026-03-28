# Alpha SDK Demo

Reusable alpha inline parser used by the Swift demo executables.

This demo shows the library-side `kcli` pattern:

- construct one `InlineParser("--alpha")`
- register inline handlers such as `--alpha-message` and `--alpha-enable`
- return the parser so an executable can compose it with other roots

Implementation:

- [`src/KcliDemoAlpha.swift`](src/KcliDemoAlpha.swift)
