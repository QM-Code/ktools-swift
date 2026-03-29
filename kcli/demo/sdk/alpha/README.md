# Alpha SDK Demo

Reusable alpha inline parser used by the Swift demo executables.

This demo shows the library-side `kcli` pattern:

- construct one `InlineParser("--alpha")`
- register inline handlers such as `--alpha-message` and `--alpha-enable`
- return the parser so an executable can compose it with other roots
- keep the parser, handlers, and emitted behavior local to the alpha demo itself

Implementation:

- [`src/KcliDemoAlpha.swift`](src/KcliDemoAlpha.swift)
