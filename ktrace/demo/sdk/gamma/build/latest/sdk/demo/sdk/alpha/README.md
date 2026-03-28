# Alpha SDK Demo

Reusable alpha trace source used by the Swift demo executables.

This SDK demonstrates the library-side pattern:

- expose a shared `TraceLogger("alpha")`
- register local channels once
- emit through that shared trace source from library code

Implementation:

- [`src/KtraceDemoAlpha.swift`](src/KtraceDemoAlpha.swift)
